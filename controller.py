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

    def cli(self):
        while True:
            cli = raw_input('Controller> ')
            if cli == 'exit':
                for con in self.digest_thread.values():
                    con.end()
                break

    def run(self):
        self.init()
        self.cli()


if __name__ == '__main__':
    con = Controller()
    con.run()
