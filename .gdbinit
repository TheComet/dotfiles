set history save on
set history size 10000
set history filename ~/.gdb_history

python
import gdb
import glob
from os import getenv
from os.path import join

# Search the python dir for all .py files, and source each
for fname in glob.glob(join(getenv("HOME"), "gdb-scripts", "*.py")):
    gdb.execute(f"source {fname}")
end

