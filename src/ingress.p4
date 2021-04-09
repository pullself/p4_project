#include "controls/Ipv4.p4"
#include "controls/Discovery.p4"
#include "controls/Protect.p4"

control ingress(inout headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata){

    // 控制模块
    IPv4() ipv4_c;
    TopologyDiscovery() topology_c;
    Protect() protection_c;

    apply{
        // 常规IP报文或是源点保护重置报文
        if(hdr.ethernet.etherType == TYPE_IPV4 || (hdr.protection_reset.isValid() && hdr.protection_reset.device_type == 0)) {
			ipv4_c.apply(hdr, meta, standard_metadata);
        }
        // 拓扑发现报文
        else if(hdr.ethernet.etherType == TYPE_DISCOVER) {
            topology_c.apply(hdr, meta, standard_metadata);
        }
        // 保护报文或是目的点保护重置报文
		else if(hdr.ethernet.etherType == TYPE_PROTECTION || (hdr.protection_reset.isValid() && hdr.protection_reset.device_type == 1)) {
			protection_c.apply(hdr, meta, standard_metadata);
		}
    }
}