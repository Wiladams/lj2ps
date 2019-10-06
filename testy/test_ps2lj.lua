package.path = "../?.lua;"..package.path

--[[
http://paulbourke.net/dataformats/postscript/
--]]


local PSVM = require("lj2ps.ps_vm")
--local Interpreter = require("lj2ps.ps_interpreter")

local vm = PSVM();              -- Create postscript virtual machine
--local interp = Interpreter(vm)  -- create an interpreter

vm:eval([[
1 2 add
3.7 mul
neg
floor
]])