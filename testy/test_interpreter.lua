package.path = "../?.lua;"..package.path


local ps_common = require("lj2ps.ps_common")
local TokenType = ps_common.TokenType
local PSVM = require("lj2ps.ps_vm")
local Scanner = require("lj2ps.ps_scanner")
local Interpreter = require("lj2ps.ps_interpreter")


local vm = PSVM();
local interp = Interpreter(vm)

--[=[
interp:run([[
/F { %def
  findfont exch scalefont setfont
} bind def
]])
--]=]

local function test_array()
  interp:run([[
[1 2 3]
]])
end

local function test_procedure()
  interp:run([[
{ 1 3 add}
]])
end

test_procedure()
