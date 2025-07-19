import gdb

class Index(gdb.Function):
    def __init__(self):
        super(Index, self).__init__("index")

    def invoke(self, val, *idxs):
        def recurse(val, idxs):
            if len(idxs) == 0:
                return val

            idx = idxs[0]
            printer = gdb.default_visualizer(val)
            for i, (name, child) in enumerate(printer.children()):
                if i == idx:
                    return recurse(child, idxs[1:])
            raise gdb.error(f"Index {idx} out of bounds")
        return recurse(val, idxs)

Index()
