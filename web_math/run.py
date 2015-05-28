from operator import concat
from tornado import ioloop, web, version
import my_math

class PlusHandler(web.RequestHandler):
    def get(self):
        args = map(
            int, reduce(concat, self.request.query_arguments.itervalues())
        )
        self.write({'result': my_math.plus(*args)})

app = web.Application([
    (r'/plus', PlusHandler)
])

if __name__ == '__main__':
    print "Hey I'm Tornado version: ", version
    app.listen(9999)
    ioloop.IOLoop.instance().start()
