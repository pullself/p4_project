from p4utils.utils.topology import Topology
from p4utils.utils.sswitch_API import SimpleSwitchAPI
from scipy.special import comb


class FlowtableManager(object):
    def __init__(self):
        self.topo = Topology(db='topology.db')
        dic = self.topo.get_p4switches()
        self.sw_name = [sw for sw in dic.keys()]
        self.controller = {
            sw: SimpleSwitchAPI(self.topo.get_thrift_port(sw))
            for sw in self.sw_name
        }
        self.multicast_table = dict()

    def add_forward_table(self):
        host_list = [h for h in self.topo.get_hosts().keys()]
        for src in self.sw_name:
            self.controller[src].table_set_default('ingress.ipv4_c.ipv4',
                                                   'drop', [])
            direct_sw_list = self.topo.get_switch_connected_to(src)
            for sw in direct_sw_list:
                port = self.topo.node_to_node_port_num(src, sw)
                self.controller[src].table_add(
                    'egress.mac_c.adjust_mac', 'set_mac', [str(port)], [
                        str(self.topo.node_to_node_mac(src, sw)),
                        str(self.topo.node_to_node_mac(sw, src))
                    ])
            direct_host_list = self.topo.get_hosts_connected_to(src)
            for h in direct_host_list:
                ip = self.topo.get_host_ip(h)
                port = self.topo.node_to_node_port_num(src, h)
                self.controller[src].table_add('ingress.ipv4_c.ipv4',
                                               'forward', [str(ip) + '/32'],
                                               [str(port)])
                self.controller[src].table_add(
                    'egress.mac_c.adjust_mac', 'set_mac', [str(port)], [
                        str(self.topo.node_to_node_mac(src, h)),
                        str(self.topo.node_to_node_mac(h, src))
                    ])
            indirect_host_list = list(
                set(host_list).difference(direct_host_list))
            for h in indirect_host_list:
                ip = self.topo.get_host_ip(h)
                path = self.topo.get_shortest_paths_between_nodes(src, h)[0]
                port = self.topo.node_to_node_port_num(src, path[1])
                self.controller[src].table_add('ingress.ipv4_c.ipv4',
                                               'forward', [str(ip) + '/32'],
                                               [str(port)])

    def add_multicast_table(self):
        for sw in self.sw_name:
            self.multicast_table.update({sw: {}})
            port = self.topo.get_interfaces_to_port(sw)
            num = len(port) - 1
            if sw + '-cpu-eth0' in port.keys():
                num -= 1
            self.controller[sw].mc_mgrp_create('1')
            for i in range(int(comb(num, 2))):
                self.controller[sw].mc_mgrp_create(str(i + 2))
            port_list = []
            for i in range(num):
                port_list.append(str(i + 1))
            self.controller[sw].mc_node_create('0', port_list)
            self.controller[sw].mc_node_associate('1', '0')
            n = 2
            for i in range(num):
                for j in range(i + 1, num):
                    port_list = [str(i + 1), str(j + 1)]
                    self.controller[sw].mc_node_create(str(n - 1), port_list)
                    self.controller[sw].mc_node_associate(str(n), str(n - 1))
                    self.multicast_table[sw].update({
                        (str(i + 1), str(j + 1)): n
                    })
                    n += 1

    def add_forward_entry(self, sw, ip, port):
        self.controller[sw].table_add('ingress.ipv4_c.ipv4', 'forward',
                                      [str(ip)], [str(port)])
