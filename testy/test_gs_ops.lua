package.path = "../?.lua;"..package.path

local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")


local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter

local function test_1()
interp:run([[
10 20 moveto
33 44 lineto
currentpoint
pstack
]])
end

local function test_2()
    interp:run([[
        10 10 moveto
        5 3 rlineto
        currentpoint
        pstack
    ]])
end

--test_1()
test_2()