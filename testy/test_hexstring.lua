package.path = "../?.lua;"..package.path


local PSVM = require("lj2ps.ps_vm")

local vm = PSVM();              -- Create postscript virtual machine

local function test_hex1()
    vm:eval([[
/hex <41424344> def
hex
==
]])
end


test_hex1()
