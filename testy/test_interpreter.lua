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
  print("==== test_def ====")
  interp:run([[
/ppi 72 def
10 ppi mul
pstack
  ]])
end

local function test_index()
  print("===== test_index ====")
interp:run([[
1 2 3 1 index
pstack
]])
end

local function test_astore()
  print("==== test_astore ====")
  interp:run([[
(a) (bcd) (ef) 3 array astore
]])
  
print("-- items --")
  local topper = vm:top()
  local size = #topper
  print("topper: ", topper, size)

  for i = 0,size-1 do
    print(topper[i])
  end
end

local function test_string()
print("==== test_string ====")
  interp:run([[
(a) (bcd) (ef)
pstack
]])
end

function test_atan()
print("==== test_atan ====")
  interp:run([[
0 1 atan
1 0 atan
-100 0 atan
4 4 atan
pstack
]])
end

function test_cos()
  print("==== test_cos ====")
  interp:run([[
0 cos
90 cos
pstack
]])
end

function test_count()
  print("==== test_count ====")
  interp:run([[
clear count
pstack
clear 1 2 3 count
pstack
]])
end

function test_counttomark()
  print("==== test_counttomark ====")
  interp:run([[
1 2 3 mark
4 5 6
counttomark
pstack
]])
end

--test_procedure()
--test_simple()
--test_def()
--test_index()
--test_string()
test_astore()
--test_atan()
--test_cos()
--test_count()
--test_counttomark()
