parser packetParser(packet_in packet,
                    out headers hdr,
                    inout metadata meta,
                    inout standard_metadata_t standard_metadata) {
    
    // 入口
    state start {
        transition parse_ethernet;
    }

    // 解析ethernet协议
    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            TYPE_DISCOVER: parse_topology_discover;
            TYPE_PROTECTION: parse_protection;
            TYPE_PROTECTION_RESET: parse_protection_reset;
            default: accept;
        }
    }

    // 解析ipv4协议
    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            TYPE_IP_PROTECTION: parse_protection;
            TYPE_TCP: parse_transport;
            TYPE_UDP: parse_transport;
            default: accept;
        }
    }

    state parse_ipv4_inner {
        packet.extract(hdr.ipv4_inner);
        transition accept;
    }

    // 解析保护协议
    state parse_protection {
        packet.extract(hdr.protection);
        transition select(hdr.protection.proto) {
            TYPE_IP_IP: parse_ipv4_inner;
            default: accept;
        }

    }

    // 解析运输层及以上协议
    state parse_transport {
        packet.extract(hdr.transport);
        transition accept;
    }

    // 解析保护重置协议
    state parse_protection_reset {
        packet.extract(hdr.protection_reset);
        transition accept;
    }

    // 解析拓扑发现协议
    state parse_topology_discover {
        packet.extract(hdr.topology);
        transition accept;
    }
}
