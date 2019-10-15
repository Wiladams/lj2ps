package.path = "../?.lua;"..package.path


local vm = require("lj2ps.ps_vm")()

vm:eval([[
newpath
0 0 moveto
612 792 lineto
stroke
showpage
]])