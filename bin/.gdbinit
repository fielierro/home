#
# C++ related beautifiers
#

define trl
target remote localhost:5000
set scheduler-locking step
end
document trl
Use localhost:5000 as a remote target
end

define top
frame 0
end

document top
Move current frame to the top of the stack.
end

set print pretty on
set print object on
set print static-members on
set print vtbl on
set print demangle on
set demangle-style gnu-v3
set print sevenbit-strings off

python
import sys
sys.path.insert(0, '/usr/share/gcc-4.6/python')
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers(None)
end

set python print-stack full
