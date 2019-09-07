package.path = "../?.lua;"..package.path

local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")


local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter

--[=[
interp:run([[
/F { %def
  findfont exch scalefont setfont
} bind def
]])
--]=]

local function test_simple()
  interp:run([[1 2 add pstack]])
end

local function test_array()
  interp:run([[
[1 2 3]
]])
end

local function test_procedure()
  interp:run([[
/sum { 1 3 add} def
]])
end

local function test_def()
  interp:run([[
/ppi 72 def
10 ppi mul
pstack
  ]])
end

--test_procedure()
--test_simple()
test_def()
