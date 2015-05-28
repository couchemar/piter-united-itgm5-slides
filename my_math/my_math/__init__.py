from operator import add
def plus(*args):
    return reduce(add, args)
