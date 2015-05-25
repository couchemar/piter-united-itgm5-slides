# coding: utf-8

from tornado import ioloop, web, version
import my_math


class PlusHandler(web.RequestHandler):
    def get(self, a, b):
        self.write({'result': my_math.plus(int(a), int(b))})


app = web.Application([
    (r'/plus/(\d+)/(\d+)', PlusHandler)
])


if __name__ == '__main__':
    print "Hey I'm Tornado version: ", version
    app.listen(9999)
    ioloop.IOLoop.instance().start()
