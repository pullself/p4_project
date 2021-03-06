// 检验校验和
control verifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
        verify_checksum(
        hdr.ipv4.isValid(), { hdr.ipv4.version,
        		 hdr.ipv4.ihl,
        		 hdr.ipv4.diffServ,
        		 hdr.ipv4.totalLen,
        		 hdr.ipv4.identification,
        		 hdr.ipv4.flags,
        		 hdr.ipv4.fragOffset,
        		 hdr.ipv4.ttl,
        		 hdr.ipv4.protocol,
        		 hdr.ipv4.srcAddr,
        		 hdr.ipv4.dstAddr },
        hdr.ipv4.hdrCheckSum,
        HashAlgorithm.csum16);
    }
}

// 生成校验和
control createChecksum(inout headers  hdr, inout metadata meta) {
     apply {
        update_checksum(
            hdr.ipv4.isValid(),
                { hdr.ipv4.version,
              hdr.ipv4.ihl,
              hdr.ipv4.diffServ,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrCheckSum,
            HashAlgorithm.csum16);

        }
}