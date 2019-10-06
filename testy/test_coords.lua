package.path = "../?.lua;"..package.path


local PSVM = require("lj2ps.ps_vm")
--local Interpreter = require("lj2ps.ps_interpreter")

local vm = PSVM();              -- Create postscript virtual machine
--local interp = Interpreter(vm)  -- create an interpreter

vm:eval([[
newpath
0 0 moveto
612 792 lineto
stroke
showpage
]])