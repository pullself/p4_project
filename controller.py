import sys
import socket

from controller.Flowtable import FlowtableManager


class Controller(object):
    # 总控制器类

    def __init__(self):
        self.manager = FlowtableManager()

    def run(self):
        self.manager.add_forward_table()
        self.manager.add_multicast_table()


if __name__ == '__main__':
    con = Controller()
    con.run()
