#include "controls/Ethernet.p4"

control egress(inout headers hdr,
               inout metadata meta,
               inout standard_metadata_t standard_metadata) {

    Ethernet() mac_c;
    
    apply {
        mac_c.apply(hdr, meta, standard_metadata); 
    }
}