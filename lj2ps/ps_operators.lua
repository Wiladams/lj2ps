local bit = require("bit")
local band, bor = bit.band, bit.bor
local bnot, bxor = bit.bnot, bit.bxor

local DEGREES, RADIANS = math.deg, math.rad
local exports = {}
exports.MARK = "MARK"

--[[
-- Stack operators
--]]
local function dup(vm)
    vm:push(vm.OperandStack:top())
    return true
end
exports.dup = dup

local function exch(vm)
    local a = vm:pop()
    local b = vm:pop()
    vm:push(a)
    vm:push(b)

    return true
end
exports.exch = exch





local function pop(self)
    return self.OperandStack:pop()
end
exports.pop = pop



local function top(self)
    return self.OperandStack:top()
end
exports.top = top

local function pstack(vm)
    for _, item in vm.OperandStack:items() do 
        print(item)
    end
end
exports.pstack = pstack

--[[
-- BUGBUG
-- depends on what's atop the stack
local function copy(vm)
    -- create temporary stack
    local tmp = stack()

    -- get the n items into temp stack
    local n = vm:pop()
    for i=0,n-1 do 
        tmp:push(vm.OperandStack:nth(i))
    end

    -- push from temp stack back onto stk
    for i=0,n-1 do 
        vm:push(tmp:pop())
    end

    return true
end
exports.copy = copy
--]]


local function roll(vm)
end

local function index(vm)
    local n = vm:pop();
    return vm.OperandStack:nth(n)
end


local function mark(vm)
    vm:push(exports.MARK)
    return true;
end
exports.mark = mark

local function clear(vm)
    vm.OperandStack:clear()
    return true;
end
exports.clear = clear

local function count(vm)
    vm:push(vm.OperandStack:len())
    return true
end
exports.count = count

--counttomark
local function cleartomark(vm)
    while vm.OperandStack:length() > 0 do 
        local item = vm:pop()
        if item == exports.MARK then
            break
        end
    end

    return true
end
exports.cleartomark = cleartomark

--[[
-- Arithmetic and Mathematical Operators
-- two arguments, result on stack
--]]
local function add(vm)
    vm:push(vm:pop()+vm:pop())
    return true
end
exports.add = add

local function sub(vm)
    local num2 = vm:pop()
    local num1 = vm:pop()
    vm:push(num1-num2)
    
    return true
end
exports.sub = sub

local function mul(vm)
    vm:push(vm:pop()*vm:pop())
end
exports.mul = mul

local function div(vm)
    local num2 = vm:pop()
    local num1 = vm:pop()
    vm:push(num1/num2)
    
    return true
end
exports.div = div

local function idiv(vm)
    local b = vm:pop()
    local a = vm:pop()

    local q = a/b
    if q >=0 then
        vm:push(math.floor(q))
    else
        vm:push(math.ceil(q))
    end
    
    return true
end
exports.idiv = idiv

local function mod(vm)
    local b = vm:pop()
    local a = vm:pop()
    vm:push(a%b)

    return true
end
exports.mod = mod

--[[
-- one argument
--]]
local function abs(vm)
    vm:push(math.abs(vm:pop()))
    return true
end
exports.abs = abs

local function ceiling(vm)
    vm:push(math.ceil(vm:pop()))
    return true
end
exports.ceiling = ceiling

local function floor(vm)
    vm:push(math.floor(vm:pop()))
    return true
end
exports.floor = floor

local function neg(vm)
    vm:push(-(vm:pop()))
    return true
end
exports.neg = neg



local function round(vm)
    local n = vm:pop()
    if n >= 0 then
        vm:push(math.floor(n+0.5))
    else
        vm:push(math.ceil(n-0.5))
    end
end
exports.round = round

--truncate

local function sqrt(vm)
    vm:push(math.floor(vm:pop()))
    return true
end
exports.sqrt = sqrt

-- BUGBUG
local function exp(vm)
    local b = vm:pop()
    local a = vm:pop()
    vm:push(math.pow(a,b))

    return true
end
exports.exp = exp

local function ln(vm)
    vm:push(math.floor(vm:pop()))
    return true
end

local function log(vm)
    vm:push(math.log(vm:pop()))
    return true
end

local function sin(vm)
    vm:push(math.sin(RADIANS(vm:pop())))
    return true
end
exports.sin = sin

local function cos(vm)
    vm:push(math.cos(RADIANS(vm:pop())))
    return true
end
exports.cos = cos

local function atan(vm)
    local den = vm:pop()
    local num = vm:pop()
    vm:push(DEGREES(math.atan(num/den)))

    return true
end
exports.atan = atan

-- put random integer on the stack
local function rand(vm)
    vm:push(math.random())
    return true
end
exports.rand = rand

local function srand(vm)
    local seed = vm:pop()
    --math.randomseed(seed)

    return true
end

-- put random number seed on stack
local function rrand(vm)
    local seed = math.randomseed()
    vm:push(seed)

    return true
end


--[[
-- Array, Packed Array, Dictionary, and String Operators
--]]
--get

-- dict key value put -
local function put(vm)
    local value = vm:pop()
    local key = vm:pop()
    local dict = vm:pop()
    rawset(dict, key, value)
    
    return true
end
exports.put = put

--copy
--length
--forall
--getinterval
--putinterval


-- creation of composite objects
local function array(vm)
    vm:push({})
    return true
end

local function packedarray(vm)
end

local function dict(vm)
    local capacity = vm:pop()
    vm:push({})
    return true
end
exports.dict = dict

local function string(vm)
end
exports.string = string

--[[
-- apply to arrays
aload
astore

setpacking
currentpacking

-- dictionaries
begin -- in VM
end     -- in VM
def     -- in VM
store   -- in VM
load    -- in VM
where   -- in VM
countdictstack  -- in VM
cleardictstack  -- in VM
dictstack       -- in VM
--]]
-- known
-- dict key known bool
local function known(vm)
    local key = vm:pop()
    local dict = vm:pop()
    if dict[key] ~= nil then
        vm:push(true)
    else
        vm:push(false)
    end

    return true
end

--maxlength

--undef
-- dict key undef -
local function undef(vm)
    local key = vm:pop()
    local dict = vm:pop()
    dict[key] = nil;

    return true;
end

-- <<key1,value1, key2,value2...>>


--[[
-- String Operators
--]]
local function eq(vm)
    vm:push(vm:pop() == vm:pop())
    return true
end

local function ne(vm)
    vm:push(vm:pop() ~= vm:pop())
    return true
end

local function gt(vm)
    local any2 = vm:pop()
    local any1 = vm:pop()
    vm:push(any1 > any2)

    return true
end

local function ge(vm)
    local any2 = vm:pop()
    local any1 = vm:pop()
    vm:push(any1 >= any2)

    return true
end

local function lt(vm)
    local any2 = vm:pop()
    local any1 = vm:pop()
    vm:push(any1 < any2)

    return true
end

local function le(vm)
    local any2 = vm:pop()
    local any1 = vm:pop()
    vm:push(any1 <= any2)

    return true
end

--[[
-- for both boolean and bitwise
--]]

exports["and"] = function(vm)
    local any2 = vm:pop()
    local any1 = vm:pop()

    if type(any1 == "boolean") then
        vm:push(any1 and any2)
    else
        vm:push(band(any1, any2))
    end
    return true
end

exports["or"] = function(vm)
    local any2 = vm:pop()
    local any1 = vm:pop()

    if type(any1 == "boolean") then
        vm:push(any1 or any2)
    else
        vm:push(bor(any1, any2))
    end
    return true
end

local function xor(vm)
    local any2 = vm:pop()
    local any1 = vm:pop()

    if type(any1 == "boolean") then
        vm:push(any1 and any2)
    else
        vm:push(band(any1, any2))
    end
    return true
end

exports["true"] = function(vm)
    vm:push(true)
    return true
end

exports["false"] = function(vm)
    vm:push(false)
    return true
end

exports["not"] = function(vm)
    local a = vm:pop()
    if type(a) == "boolean" then
        vm:push(not a)
    else
        vm:push(bnot(a))
    end

    return true
end


local function bitshift(vm)
    local shift = vm:pop()
    local int1 = vm:pop()

    if shift < 0 then
        vm:push(rshift(int1,math.abs(shift)))
    else
        vm:push(lshift(int1,shift))
    end

    return true
end
exports.bitshift = bitshift

--[[
-- Control Operators
if
ifelse
exec
for
repeat
loop
forall
exit
countexecstack
execstack
stop
]]

--[[
-- Type, Attribute and Conversion Operators
type
xcheck
rcheck
wcheck
cvlit
cvx
readonly
executeonly
noaccess
--]]

local function cvi(vm)
    vm:push(tonumber(vm:pop()))
    return true
end

local function cvr(vm)
    vm:push(tonumber(vm:pop()))
    return true
end

local function cvn(vm)
end

local function cvs(vm)
    vm:push(tostring(vm:pop()))
    return true 
end

local function cvrs(vm)
end

-- miscellaneous
local function revision(vm)
    vm.OperandStack:push(1)
    
    return true
end
exports.revision = revision

return exports