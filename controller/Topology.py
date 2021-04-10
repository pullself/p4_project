'''
'''

from scapy.all import sniff, sendp, hexdump, get_if_list, get_if_hwaddr
from scapy.all import Packet, IPOption, Ether
from scapy.all import Ether, IP, UDP, TCP


class DiscoverController(object):
    # 拓扑发现控制类
    def __init__(self):
        pass

    def send_discover_pkt(self):
        pass

    def recv_discover_pkt(self):
        pass

    def get_topo(self):
        pass

    def set_flowtable(self):
        pass


def SPF(node):
    pass
