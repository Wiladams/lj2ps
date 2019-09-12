package.path = "../?.lua;"..package.path


local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")

local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter

local function test_hex1()
    interp:run([[
/hex <ff00ff00> def
hex
pstack
]])
end


test_hex1()
