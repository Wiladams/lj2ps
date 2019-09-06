local bit = require("bit")
local band, bor = bit.band, bit.bor
local bnot, bxor = bit.bnot, bit.bxor

local DEGREES, RADIANS = math.deg, math.rad

local collections = require("lj2ps.collections")
local Stack = collections.Stack

local ps_common = require("lj2ps.ps_common")

local Array = ps_common.Array
local Dictionary = ps_common.Dictionary

local exports = {}

--[[
-- Stack operators
--]]
local function clear(vm)
    vm.OperandStack:clear()
    return true;
end
exports.clear = clear

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

local function pop(vm)
    local item = vm.OperandStack:pop()
    --print("op.pop: ", item)
    return item
end
exports.pop = pop

local function roll(vm)
end

local function top(self)
    return self.OperandStack:top()
end
exports.top = top

--[[
    Interactive Operators
]]


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




local function index(vm)
    local n = vm:pop();
    return vm.OperandStack:nth(n)
end


local function mark(vm)
    vm:push(ps_common.MARK)
    return true;
end
exports.mark = mark



local function count(vm)
    vm:push(vm.OperandStack:len())
    return true
end
exports.count = count

--counttomark
local function counttomark(vm)
    local ct = 0

    for _, item in vm.OperandStack:items() do
        if item == exports.MARK then
            break
        end

        ct = ct + 1
    end

    vm.OperandStack:push(ct)

    return true
end
exports.counttomark = counttomark

-- cleartomark
local function cleartomark(vm)
    while vm.OperandStack:length() > 0 do 
        local item = vm:pop()
        if item == ps_common.MARK then
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
-- get
-- array index get any
local function get(vm)
    local index = vm.OperandStack:pop()
    local arr = vm.OperandStack:pop()
    vm.OperandStack:push(arr[index])

    return true
end
exports.get = get

--[[
-- BUGBUG, resolve put overload based on type
-- of array, or dictionary
-- array index any -
local function put(vm)
    local item = vm.OperandStack:pop()
    local index = vm.OperandStack:pop()
    local arr = vm.OperandStack:pop()
    arr[index] = item

    return true
end
--]]

exports.put = put
-- dict key value put -
local function put(vm)
    local value = vm:pop()
    local key = vm:pop()
    local dict = vm:pop()
    rawset(dict, key, value)
    
    return true
end
exports.put = put

-- getinterval
-- putinterval

-- copy
-- forall

-- Dictionary Operations


-- def
-- key value def    Associate key with value in current dictionary
local function def(vm)
    local value = vm.OperandStack:pop()
    local key = vm.OperandStack:pop()

    return vm.DictionaryStack:def(key, value)
end
exports.def = def

-- load
-- key load value        search stack for key, place value on operand stack
local function load(vm)
    local key = vm.OperandStack:pop()
    local value = vm.DictionaryStack:load(key)
    if not value then
        vm.OperandStack:push(ps_common.NULL)
    else
        vm.OperandStack:push(value)
    end

    return true
end

-- key value store -
-- Replace topmost definition of key
local function store(vm)
    local value = vm.OperandStack:pop()
    local key = vm.OperandStack:pop()

    return vm.DictionaryStack:store(key, value)
end
exports.store = store

local function where(vm)
    local key = vm.OperandStack:pop()
    local d = vm.DictionaryStack:where(key)
    if not d then
        vm.OperandStack:push(false)
    else
        vm.OperandStack:push(d)
        vm.OperandStack:push(true)
    end

    return true
end
exports.where = where


--length
-- array length int
local function length(vm)
    local arr = vm.OperandStack:pop()
    vm.OperandStack:push(#arr)
    
    return true
end
exports.length = length




-- creation of composite objects


-- Array Creation
-- astore
-- any0 ... any(n-1) array astore array
local function astore(vm)
    local arr = vm.OperandStack:pop()
    local n = #arr

    for i=1,n do
        local item = vm.OperandStack:pop()
        arr[i-1] = item
    end
    vm.OperandStack:push(arr)

    return truncate
end
exports.astore = astore

-- aload
-- array aload any0 ... any(n-1) array
local function aload(vm)
    local arr = vm.OperandStack:pop()
    local n = #arr

    for i=0,n-1 do
        vm.OperandStack:push(arr[i])
    end
    vm.OperandStack:push(arr)

    return true
end
exports.aload = aload


--[[
    [5 4 3]  or
    mark 5 4 3 counttomark array astore exch pop
]]
-- alias for '[', mark
local function beginArray(vm)
    vm:mark()
end
exports.beginArray = beginArray

-- alias for ']'
local function endArray(vm)
    -- pop all the objects until a mark


    local tmpStack = Stack()
    while vm.OperandStack:length() > 0 do 
        local item = vm.OperandStack:pop()
        if item == exports.MARK then
            break;
        end

        tmpStack:push(item)
    end

    -- put them into an array, reversing order
    local arr = {}
    for _, item in tmpStack:items() do 
        table.insert(arr, item)
    end

    -- put the array on the stack
    vm.OperandStack:push(arr)
end
exports.endArray = endArray

local function beginExecutableArray(vm)
    beginArray(vm)
end
exports.beginExecutableArray = beginExecutableArray

local function endExecutableArray(vm)
    --endArray(vm)
    counttomark(vm)
    array(vm)
    astore(vm)
    exch(vm)
    pop(vm)
    print("endExecutableArray, stack: ")
    pstack(vm)
end
exports.endExecutableArray = endExecutableArray

local function array(vm)
    local size = vm:pop()
    local arr = Array(size)

    vm:push(arr)

    return true
end
exports.array = array

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

setpacking
currentpacking

-- dictionaries
countdictstack  -- in VM
cleardictstack  -- in VM
dictstack       -- in VM
--]]

-- known
-- dict key known bool
local function known(vm)
    local key = vm.OperandStack:pop()
    local dict = vm.OperandStack:pop()
    if dict[key] ~= nil then
        vm.OperandStack:push(true)
    else
        vm.OperandStack:push(false)
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
-- <<, alias for mark
local function beginDictionary(vm)
    vm.OperandStack:push(exports.MARK)
end

local function endDictionary(vm)
    local tmpDict = Dictionary()
    while vm.OperandStack:length() > 0 do 
        local value = vm.OperandStack:pop()
        if value == exports.MARK then
            break;
        end

        local key = vm.OperandStack:pop()
        if key ~= nil then
            tmpDict[key] = value;
        end
    end
    vm.OperandStack:push(tmpDict)
end


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