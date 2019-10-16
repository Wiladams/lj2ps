package.path = "../?.lua;"..package.path

local PSVM = require("lj2ps.ps_vm")
local vm = PSVM();              -- Create postscript virtual machine


vm:eval([[
true 
false
pstack
]])