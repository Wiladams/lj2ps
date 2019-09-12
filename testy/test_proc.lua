package.path = "../?.lua;"..package.path


local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")

local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter

local function test_var()
interp:run([[
/ppi 72 def
10 ppi mul
pstack
]])
end

local function test_proc()
interp:run([[
/inch {
  72 mul
}  def
5 inch
pstack
]])
end

--test_var()
test_proc()