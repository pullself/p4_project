/** Discovery.p4
  *
  * 进行拓扑发现控制，同openflow的洪泛拓扑发现。控制器会向所有连接的交换机
  * 发送一个拓扑发现报文，交换机在接收到这个拓扑发现报文后会将该报文发送到
  * 所有与该交换机直连的端口，除了控制器端口。然后邻居接收到该数据包后会发
  * 送给控制器，控制器就可以获得链路信息。也可以利用该机制来更新拓扑。
  *
  */

control TopologyDiscovery(inout headers hdr,
                          inout metadata meta,
                          inout standard_metadata_t standard_metadata) {
    
    apply {
        if(standard_metadata.ingress_port == CONTROLLER_PORT) {
            // 当数据报来自于控制器
            // 洪泛操作
            standard_metadata.mcast_grp = 1;
        }
        else {
            // 当数据报不来自于控制器
            // 将数据报发送给控制器
            standard_metadata.egress_spec = CONTROLLER_PORT;
            hdr.topology.port = (bit<16>) standard_metadata.ingress_port;
        }
    }
}