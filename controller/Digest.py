'''
Digest.py: digest function for controller

用于实现基本的nanomsg接收与处理功能，利用的是nanomsg的pubsub模式，交换机作为
需要运行在python2.7或3.4环境下

DigestController：用于实现一个消息控制类，具有建立连接，接受消息的功能
'''

import nnpy
import struct
import ipaddress

from p4utils.utils.topology import Topology
from p4utils.utils.sswitch_API import SimpleSwitchAPI


class DigestController(object):
    def __init__(self, sw_name):
        self.sw_name = sw_name
        self.topo = Topology(db='topology.db')
        self.thrift_port = self.topo.get_thrift_port(sw_name)
        self.controller = SimpleSwitchAPI(self.thrift_port)
        self.sub = None
        self.flag = 1

    def recv_msg_digest(self, msg, offset, typ):
        topic, device_id, ctx_id, list_id, buffer_id, num = struct.unpack(
            "<iQiiQi", msg[:32])
        msg = msg[32:]
        self.controller.client.bm_learning_ack_buffer(ctx_id, list_id,
                                                      buffer_id)
        return num, msg

    def unpack_digest(self, msg, offset, typ, num):
        data = list()
        for sub_message in range(num):
            data.append(struct.unpack(typ, msg[0:offset]))
            msg = msg[offset:0]
        return data

    def digest_connect(self):
        sub = nnpy.Socket(nnpy.AF_SP, nnpy.SUB)
        notifications_socket = self.controller.client.bm_mgmt_get_info(
        ).notifications_socket
        sub.connect(notifications_socket)
        sub.setsockopt(nnpy.SUB, nnpy.SUB_SUBSCRIBE, '')
        return sub

    def run(self, offset, typ):
        while self.flag == 1:
            self.sub = self.digest_connect()
            try:
                msg = self.sub.recv()
            except:
                pass
            else:
                num, msg = self.recv_msg_digest(msg)
                res = self.unpack_digest(msg, offset, typ, num)
                print(self.sw_name + ' message:', res)
        print(self.sw_name + ' running is over')

    def end(self):
        self.flag = 2
        self.sub.close()
        print(self.sw_name + '\'sub is close')


if __name__ == "__main__":
    DigestController('s1').run()
