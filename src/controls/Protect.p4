/** Protect.p4
  * 数据报选择控制
  */
control Protetct(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    
    /**
      * 定义一个存储器 protection_assumed_next_seq
      * 用于记录预设的保护序列
      * 最多可存储 8192 个 8bit 标志
      */
    register<protectionSeq_t>(PROTECTION_STORAGE) protection_assumed_next_seq;
    
    apply {
        if(hdr.protection_reset.isValid() && hdr.protection_reset.device_type == 1){
            @atomic {
                // 写入内存
                protection_assumed_next_seq.write((bit<32>) hdr.protection_reset.conn_id, 0);
            }
        }
        else {
            @atomic {
                protectionSeq_t seq_in = hdr.protection.seq;
                protectionSeq_t seq_assumed; // 预设保护序列号
                protection_assumed_next_seq.read(seq_assumed, (bit<32>)hdr.protection.conn_id);
                bit<1> accepted = 0;

                // 待解决
                if((seq_in >= seq_assumed) && ((seq_in - seq_assumed) <= (SEQ_MAX / 2))){
                    accepted = 1;
                }
                else if((seq_in < seq_assumed) && ((seq_assumed - seq_in) >= (SEQ_MAX /2))) {
                    accepted = 1;
                }

                if(accepted == 1) {
                    // 写入内存
                    protection_assumed_next_seq.write((bit<32>)hdr.protection.conn_id, seq_in + 1);
                    
                    hdr.protection.setInvalid();

                    hdr.ipv4.setValid();
                    hdr.ipv4 = hdr.ipv4_inner;
                    hdr.ipv4_inner.setInvalid();

                    hdr.ethernet.etherType = TYPE_IPV4;

                    // 循环数据报
                    recirculate<metadata>(meta);
                } 
            }
        }
    }
}