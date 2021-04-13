import sys
import socket

from controller.Flowtable import FlowtableManager


class Controller(object):
    # 总控制器类

    def __init__(self):
        self.manager = FlowtableManager()
        self.num = len(self.manager.sw_name)
        self.digest_thread = dict()

    def init(self):
        self.manager.add_forward_table()
        self.manager.add_multicast_table()

    def get_command(self, msg):
        order_list = msg.split(' ')
        return order_list

    def cli(self):
        while True:
            cli = raw_input('Controller> ')
            cmd = self.get_command(cli)
            if cmd[0] == 'exit':
                for con in self.digest_thread.values():
                    con.end()
                break
            elif cmd[0] == 'show':
                try:
                    self.manager.controller[cmd[1]].table_dump(
                        'ingress.ipv4_c.ipv4')
                    self.manager.controller[cmd[1]].table_dump(
                        'ingress.ipv4_c.ipv4_tunnel')
                    self.manager.controller[cmd[1]].table_dump(
                        'ingress.ipv4_c.l3_match_index')
                    self.manager.controller[cmd[1]].table_dump(
                        'ingress.ipv4_c.protected_services')
                    self.manager.controller[cmd[1]].table_dump(
                        'egress.mac_c.adjust_mac')
                    self.manager.controller[cmd[1]].mc_dump()
                except:
                    print('command\'s parameter is illegal')
            elif cmd[0] == 'add':
                try:
                    if cmd[1] == 'l3':
                        key = cmd[3:8]
                        act = cmd[8:]
                        self.manager.add_l3_entry(cmd[2], act, key)
                    elif cmd[1] == 'forward':
                        self.manager.add_forward_entry(cmd[2], cmd[3], cmd[4])
                except:
                    print('command\'s parameter is illegal')
            else:
                print('command is undefine')

    def run(self):
        self.init()
        self.cli()


if __name__ == '__main__':
    con = Controller()
    con.run()
