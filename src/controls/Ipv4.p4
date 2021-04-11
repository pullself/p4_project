/** Ipv4.p4
  *
  * 三层控制
  *
  */
control IPv4(inout headers hdr,
             inout metadata meta,
             inout standard_metadata_t standard_metadata) {

    /**
      * 定义一个存储器 protection_next_seq 
      * 用于记录保护序列
      * 最多可存储 8192 个 8bit 标志
      * 定义一个计数器 l3_match_to_index_stats 
      * 用于统计 l3_match_to_index 表匹配成功的包数
      */
    register<protectionSeq_t>(PROTECTION_STORAGE) protection_next_seq;
    direct_counter(CounterType.packets) l3_match_to_index_stats;

    // 测试用空动作
    action none() {}

    action drop() {
        mark_to_drop(standard_metadata);
    }

    // ip包转发
    action forward(egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    /** ip头移除
      * 为替换为保护头作准备
      */
    action decap() {
        hdr.ipv4.setInvalid(); //将原ipv4的头部设置为不可用
        hdr.ethernet.etherType = TYPE_PROTECTION; // 将第三层协议设置为保护协议头
        recirculate<metadata>(meta); // 将数据包再循环
    }

    table ipv4 {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            forward;
            decap;
            drop;
        }
    }

    table ipv4_tunnel {
        key = {
            hdr.ipv4.dstAddr: exact;
        }
        actions = {
            forward;
            decap;
            drop;
        }
    }

    // 设置组播号
    action set_mc_grp(mcastGrp_t grp) {
        standard_metadata.mcast_grp = grp;
    }
    
    action protect(protectionId_t id, mcastGrp_t grp, ip4Addr_t srcAddr, ip4Addr_t dstAddr) {
        l3_match_to_index_stats.count(); // 更新计数器
        @atomic {
            // 读下一个保护序列
            protectionSeq_t next_seq;
            protection_next_seq.read(next_seq, (bit<32>) id);

            // 设置保护头字段
            hdr.protection.setValid(); // 设置为可用
            hdr.protection.conn_id = id; // 赋值连接id
            hdr.protection.seq = next_seq; // 赋值序列号
            hdr.protection.proto = TYPE_IP_IP; // 赋值负载协议类型为ip

            // 更新保护序列
            protection_next_seq.write((bit<32>) id, next_seq + 1);
        }

        // 将ipv4的报文复制给隧道
        hdr.ipv4_inner.setValid();
        hdr.ipv4_inner = hdr.ipv4;
        hdr.ipv4.srcAddr = srcAddr;
        hdr.ipv4.dstAddr = dstAddr;
        hdr.ipv4.protocol = TYPE_IP_PROTECTION;

        set_mc_grp(grp);
    }

    table protected_services {
        key = {
            hdr.ipv4.srcAddr: ternary;
            hdr.ipv4.dstAddr: ternary;
            hdr.transport.src_port: ternary;
            hdr.transport.dst_port: ternary;
            hdr.ipv4.protocol: ternary;
        }
        actions = {
            none;
        }
    }

    table l3_match_to_index {
        key = {
            hdr.ipv4.srcAddr: exact;
            hdr.ipv4.dstAddr: exact;
            hdr.transport.src_port: exact;
            hdr.transport.dst_port: exact;
            hdr.ipv4.protocol: exact;
        }
        actions = {
            protect;
        }
        counters = l3_match_to_index_stats; // 声明计数器
    } 

    apply {
        // 待解决
        if(hdr.protection_reset.isValid() && hdr.protection_reset.device_type == 0) {
            @atomic {
                protection_next_seq.write((bit<32>) hdr.protection_reset.conn_id, 0);
            }
        }
        else if(!l3_match_to_index.apply().hit) {
            // l3_match_to_index的表未命中时，执行常规的ip转发
            if(protected_services.apply().hit) {
                /** 当前流表需要对指定流进行保护
                  * clone3的第一个参数在用于ingress时默认为CloneType.I2E
                  */
                clone3<metadata>(CloneType.I2E, 1000, meta);
            }
            if(!ipv4.apply().hit) { 
                ipv4_tunnel.apply();
            }
        }
    }
}