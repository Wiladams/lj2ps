package.path = "../?.lua;"..package.path

local PSVM = require("lj2ps.ps_vm")


local vm = PSVM();              -- Create postscript virtual machine

--[=[
vm:eval([[
/F { %def
  findfont exch scalefont setfont
} bind def
]])
--]=]

local function test_simple()
  vm:eval([[1 2 add pstack]])
end

local function test_array()
  vm:eval([[
[1 2 3]
]])
end

local function test_procedure()
  vm:eval([[
/add3 { 3 add} def
5 add3
pstack
]])
end

local function test_if()
  vm:eval([[
3 4 lt { (3 is less than 4) } if
pstack
]])

end

local function test_ifelse()
vm:eval([[
4 3 lt {(TruePart)} {(FalsePart)} ifelse
pstack
]])
end

local function test_for()
  vm:eval([[
0 1 1 4 {add} for
pstack
  ]])
end

local function test_fork()
vm:eval([[
/Tahoma findfont
16 scalefont
setfont

newpath

0 12 600 {0 moveto (k) show } for
showpage
]])
end


local function test_def()
  print("==== test_def ====")
  vm:eval([[
/ppi 72 def
10 ppi mul
pstack
  ]])
end

local function test_index()
  print("===== test_index ====")
vm:eval([[
1 2 3 1 index
pstack
]])
end

local function test_astore()
  print("==== test_astore ====")
  vm:eval([[
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
  vm:eval([[
(a) (bcd) (ef)
pstack
]])
end

function test_atan()
print("==== test_atan ====")
  vm:eval([[
0 1 atan
1 0 atan
-100 0 atan
4 4 atan
pstack
]])
end

function test_cos()
  print("==== test_cos ====")
  vm:eval([[
0 cos
90 cos
pstack
]])
end

function test_count()
  print("==== test_count ====")
  vm:eval([[
clear count
pstack
clear 1 2 3 count
pstack
]])
end

function test_counttomark()
  print("==== test_counttomark ====")
  vm:eval([[
1 2 3 mark
4 5 6
counttomark
pstack
]])
end

--test_procedure()
--test_if()
--test_ifelse()
--test_for()
test_fork()

--test_simple()
--test_def()
--test_index()
--test_string()
--test_astore()
--test_atan()
--test_cos()
--test_count()
--test_counttomark()
