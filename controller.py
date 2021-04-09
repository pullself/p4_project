import sys
import nnpy
import struct
import socket
import ipaddress

from p4utils.utils.topology import Topology
from p4utils.utils.sswitch_API import SimpleSwitchAPI

from scapy.all import sniff, sendp, hexdump, get_if_list, get_if_hwaddr, bind_laters
from scapy.all import Packet, IPOption, Ether
from scapy.all import Ether, IP, UDP, TCP


class Controller:
    pass
