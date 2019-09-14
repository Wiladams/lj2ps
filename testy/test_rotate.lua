package.path = "../?.lua;"..package.path


local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")

local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter

interp:run([[
%!
144 144 translate
30 rotate
newpath
0 0 moveto
144 0 lineto
144 144 lineto  
0 144 lineto 
0 0 lineto
stroke
showpage
]])
