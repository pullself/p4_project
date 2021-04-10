from p4utils.utils.topology import Topology
from p4utils.utils.sswitch_API import SimpleSwitchAPI


class FlowtableManager(object):
    def __init__(self):
        self.topo = Topology(db='topology.db')
        dic = self.topo.get_p4switches()
        self.sw_name = [sw for sw in dic.keys()]
        self.controller = {
            sw: SimpleSwitchAPI(self.topo.get_thrift_port(sw))
            for sw in self.sw_name
        }

    def add_forward_table(self):
        host_list = [h for h in self.topo.get_hosts().keys()]
        for src in self.sw_name:
            self.controller[src].table_set_default('ingress.ipv4_c.ipv4',
                                                   'drop')
            direct_host_list = self.topo.get_hosts_connected_to(src)
            for h in direct_host_list:
                ip = self.topo.get_host_ip(h)
                port = self.topo.node_to_node_port_num(src, h)
                self.controller[src].table_add('ingress.ipv4_c.ipv4',
                                               'forward', [ip + '/24'], [port])
                self.controller[src].table_add(
                    'egress.mac_c.adjust_mac', 'set_mc', [port], [
                        self.topo.node_to_node_mac(src, h),
                        self.topo.node_to_node_mac(h, src)
                    ])
            indirect_host_list = list(
                set(host_list).difference(direct_host_list))
            for h in indirect_host_list:
                ip = self.topo.get_host_ip(h)
                path = self.topo.get_shortest_paths_between_nodes(src, h)[0]
                port = self.topo.node_to_node_port_num(src, path[1])
                self.controller[src].table_add('ingress.ipv4_c.ipv4',
                                               'forward', [ip + '/24'], [port])
                self.controller[src].table_add(
                    'egress.mac_c.adjust_mac', 'set_mc', [port], [
                        self.topo.node_to_node_mac(src, path[1]),
                        self.topo.node_to_node_mac(path[1], src)
                    ])

    def add_multicast_table(self):
        for sw in self.sw_name:
            self.controller[sw].mc_mgrp_create(1)
            num = len(self.topo.get_interfaces_to_port(sw)) - 1
            for i in range(num):
                self.controller[sw].mc_node_create(i, i + 1)
                self.controller[sw].mc_node_associate(1, i)

    def add_forward_entry(self, sw, ip, port):
        self.controller[sw].table_add('ingress.ipv4_c.ipv4', 'forward', [ip],
                                      [port])
