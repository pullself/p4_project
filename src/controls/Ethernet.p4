/** Ethernet.p4
  * 
  * 二层控制，实话说暂时有些多余，但是相当于将二层的mac地址转换独立了出来，
  * 而且放置在egress流水线增加灵活度
  *
  */
control Ethernet(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {

    // 设置Mac地址
    action set_mac(macAddr_t srcAddr,macAddr_t dstAddr) {
        hdr.ethernet.srcAddr = srcAddr;
        hdr.ethernet.dstAddr = dstAddr;
    }

    // 
    table adjust_mac {
        key = {
            standard_metadata.egress_port: exact;
        }
        actions = {
            set_mac;
        }
    }

    apply {
        adjust_mac.apply();
    }
}