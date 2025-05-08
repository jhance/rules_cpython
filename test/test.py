import sys

import platform
assert platform.python_implementation() == "CPython"

assert sys.version_info.major == 3
assert sys.version_info.minor == 12
