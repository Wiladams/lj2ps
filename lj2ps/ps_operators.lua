local bit = require("bit")
local band, bor = bit.band, bit.bor
local bnot, bxor = bit.bnot, bit.bxor

local DEGREES, RADIANS = math.deg, math.rad

local ps_common = require("lj2ps.ps_common")
local Stack = require("lj2ps.ps_stack")
local Array = require("lj2ps.array")
local Dictionary = require("lj2ps.dictionary")
local PSString = require("lj2ps.ps_string")




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
    vm.OperandStack:dup()
    return true
end
exports.dup = dup

local function exch(vm)
    vm.OperandStack:exch()
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
    local j = vm.OperandStack:pop()
    local n = vm.OperandStack:pop()

    vm.OperandStack:roll(n,j)

    return true
end
exports.roll = roll

local function top(self)
    return self.OperandStack:top()
end
exports.top = top

--[[
    Interactive Operators
]]




--[[
-- BUGBUG
-- depends on what's atop the stack
-- copy any1... anyn  n copy  any1..anyn any1..anyn
--]]
local function copy(vm)
    local n = vm.OperandStack:pop()
    vm.OperandStack:copy(n)

    return true
end
exports.copy = copy




-- any(n)..any(0) n index any(n)..any(0) any(n)
local function index(vm)
    local n = vm.OperandStack:pop();
    local value = vm.OperandStack:nth(n)
    vm.OperandStack:push(value)
    
    return true
end
exports.index = index

local function mark(vm)
    vm.OperandStack:push(ps_common.MARK)

    return true;
end
exports.mark = mark



local function count(vm)
    vm.OperandStack:push(vm.OperandStack:length())

    return true
end
exports.count = count

--counttomark
local function counttomark(vm)
    local n = vm.OperandStack:countToMark()

    vm.OperandStack:push(n)

    return true
end
exports.counttomark = counttomark

-- cleartomark
local function cleartomark(vm)
    while vm.OperandStack:length() > 0 do 
        local item = vm.OperandStack:pop()
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
    local num2 = vm.OperandStack:pop()
    local num1 = vm.OperandStack:pop()
    vm.OperandStack:push(num1+num2)

    return true
end
exports.add = add

local function sub(vm)
    local num2 = vm.OperandStack:pop()
    local num1 = vm.OperandStack:pop()
    vm.OperandStack:push(num1-num2)
    
    return true
end
exports.sub = sub

local function mul(vm)
    local num2 = vm.OperandStack:pop()
    local num1 = vm.OperandStack:pop()
    --print("MUL: ", num1, num2)
    vm.OperandStack:push(num1*num2)
end
exports.mul = mul

local function div(vm)
    local num2 = vm.OperandStack:pop()
    local num1 = vm.OperandStack:pop()
    --print("div: ", type(num1), type(num2), num2)
    
    -- BUGBUG, need to find cases where this happens
    if (type(num1) ~= "number") or (type(num2) ~= "number") then
        vm.OperandStack:push(0)
        return false
    end

    local value = num1/num2

    vm.OperandStack:push(value)
    
    return true
end
exports.div = div

local function idiv(vm)
    local b = vm.OperandStack:pop()
    local a = vm.OperandStack:pop()

    local q = a/b
    if q >=0 then
        vm.OperandStack:push(math.floor(q))
    else
        vm.OperandStack:push(math.ceil(q))
    end
    
    return true
end
exports.idiv = idiv

local function mod(vm)
    local b = vm.OperandStack:pop()
    local a = vm.OperandStack:pop()

    local value = a % b 
--print("OP:mod; ", a, b, value)
    vm.OperandStack:push(value)

    return true
end
exports.mod = mod

local function maximum(vm)
    --print("MAXIMUM")
    local b = vm.OperandStack:pop()
    local a = vm.OperandStack:pop()

    vm.OperandStack:push(math.max(a, b))
end
exports[".max"] = maximum
exports["max"] = maximum

local function minimum(vm)
    local b = vm.OperandStack:pop()
    local a = vm.OperandStack:pop()

    vm.OperandStack:push(math.min(a, b))
end
exports[".min"] = minimum
exports["min"] = minimum

--[[
-- one argument
--]]
local function abs(vm)
    vm.OperandStack:push(math.abs(vm.OperandStack:pop()))
    return true
end
exports.abs = abs

local function ceiling(vm)
    vm.OperandStack:push(math.ceil(vm.OperandStack:pop()))
    return true
end
exports.ceiling = ceiling

local function floor(vm)
    vm.OperandStack:push(math.floor(vm.OperandStack:pop()))
    return true
end
exports.floor = floor

local function neg(vm)
    vm.OperandStack:push(-(vm.OperandStack:pop()))
    return true
end
exports.neg = neg

local function round(vm)
    local n = vm.OperandStack:pop()
    --print("round: ", n)
    if n >= 0 then
        vm.OperandStack:push(math.floor(n+0.5))
    else
        vm.OperandStack:push(math.ceil(n-0.5))
    end
end
exports.round = round

--truncate
local function truncate(vm)
    local a = vm.OperandStack:pop()
    if a >= 0 then
        vm.OperandStack:push(math.floor(a))
    else
        vm.OperandStack:push(math.ceil(a))
    end

    return true
end
exports.truncate = truncate

local function sqrt(vm)
    vm.OperandStack:push(math.floor(vm.OperandStack:pop()))
    return true
end
exports.sqrt = sqrt

-- BUGBUG
local function exp(vm)
    local base = vm.OperandStack:pop()
    local exponent = vm.OperandStack:pop()
    vm.OperandStack:push(math.pow(base,exponent))

    return true
end
exports.exp = exp

local function ln(vm)
    vm.OperandStack:push(math.log(vm.OperandStack:pop()))
    return true
end
exports.ln = ln

local function log(vm)
    vm.OperandStack:push(math.log10(vm.OperandStack:pop()))
    return true
end
exports.log = log

local function sin(vm)
    vm.OperandStack:push(math.sin(RADIANS(vm.OperandStack:pop())))
    return true
end
exports.sin = sin

local function cos(vm)
    local value = math.cos(RADIANS(vm.OperandStack:pop()))
    vm.OperandStack:push(value)

    return true
end
exports.cos = cos

local function atan(vm)
    local den = vm.OperandStack:pop()
    local num = vm.OperandStack:pop()
    local value = DEGREES(math.atan(num/den))
    if value < 0 then
        value = value + 360
    end

    vm.OperandStack:push(value)
    return true
end
exports.atan = atan

-- put random integer on the stack
local function rand(vm)
    local value = math.random(0,0x7fffffff)
    vm.OperandStack:push(value)

    return true
end
exports.rand = rand

local function srand(vm)
    local seed = vm.OperandStack:pop()
    --math.randomseed(seed)

    return true
end
exports.srand = srand

-- put random number seed on stack
local function rrand(vm)
    local seed = math.randomseed()
    vm.OperandStack:push(seed)

    return true
end
exports.rrand = rrand

--[[
-- Array, Packed Array, Dictionary, and String Operators
--]]
-- get
-- array index get any
local function get(vm)
    local idx = vm.OperandStack:pop()
    local arr = vm.OperandStack:pop()
    local value = arr[idx]
--print('GET: ', arr, idx, value)

    vm.OperandStack:push(value)

    return true
end
exports.get = get

-- BUGBUG, resolve put overload based on type
-- of array, or dictionary
-- array index any -
local function put(vm)
    local item = vm.OperandStack:pop()
    local idx = vm.OperandStack:pop()
    local arr = vm.OperandStack:pop()
    arr[idx] = item

    return true
end
exports.put = put


-- getinterval
-- array  index  count getinterval  subarray
local function getinterval(vm)
    local count = vm.OperandStack:pop()
    local index = vm.OperandStack:pop()
    local array1 = vm.OperandStack:pop()

    local subarray = array1:getInterval(index, count)

    vm.OperandStack:push(subarray)
    
    return true
end
exports.getinterval = getinterval

-- putinterval
-- array1  index  array2 putinterval
local function putinterval(vm)
    local array2 = vm.OperandStack:pop()
    local index = vm.OperandStack:pop()
    local array1 = vm.OperandStack:pop()
--print("putinterval, array2:length(): ", index, array2:length())
    array1:putInterval(index, array2)

    return true
end
exports.putinterval = putinterval

-- Dictionary Operations
-- userdict
-- put userdict on the stack
-- userdict userdict
local function userdict(vm)
    local ud = vm.userdict
    print("OP:userdict; ", ud)
    vm.OperandStack:push(ud)

    return true
end
exports.userdict = userdict

-- def
-- key value def    Associate key with value in current dictionary
local function def(vm)
    local value = vm.OperandStack:pop()
    local key = vm.OperandStack:pop()
--print("DEF: ", key, value)
    return vm.DictionaryStack:def(key, value)
end
exports.def = def

-- load     % search stack for key, place value on operand stack
-- key load value        
local function load(vm)
    local key = vm.OperandStack:pop()
    local value = vm.DictionaryStack:load(key)
    --print("LOAD: ", key, value)
    if not value then
        error("OP:load; undefined key - "..key)
    else
        vm.OperandStack:push(value)
    end

    return true
end
exports.load = load

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
    local size = #arr

    for i=1,size do 
        local value = vm.OperandStack:pop()
        --print("astore, value: ", size-i, value)
        arr[size-i] = value
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

local function begin(vm)
    --print("BEGIN")
    -- pop the dictionary off the top of the 
    -- operand stack and make it the current dictionary
    -- by placing on top of dictionary stack
    local d = vm.OperandStack:pop()
    vm.DictionaryStack:pushDictionary(d)

    return true;
end
exports.begin = begin

-- Dictionary management

exports["end"] = function(vm)
    -- simply pop the dictionary stack
    vm.DictionaryStack:popDictionary()
end

--[[
    [5 4 3]  or
    mark 5 4 3 counttomark array astore exch pop
]]
-- alias for '[', mark
local function beginArray(vm)
    vm.OperandStack:push(ps_common.MARK)
    return true
end
exports.beginArray = beginArray

-- alias for ']'
local function endArray(vm)

    local n = vm.OperandStack:countToMark()
    local arr = Array(n)

    -- stuff the array with all the elements up until
    -- the mark
    for i=1,n do
        arr[n-i] = vm.OperandStack:pop()
    end

    -- then pop the mark itself
   vm.OperandStack:pop()

    -- put the finished array back the stack
    vm.OperandStack:push(arr)
end
exports.endArray = endArray


local function array(vm)
    local size = vm.OperandStack:pop()
    local arr = Array(size)

    vm.OperandStack:push(arr)

    return true
end
exports.array = array

local function packedarray(vm)
    local size = vm.OperandStack:pop()
    local arr = Array(size)
    for i=1,size do 
        arr[size-i] = vm.OperandStack:pop()
    end

    vm.OperandStack:push(arr)

    return true
end
exports.packedarray = packedarray

local function dict(vm)
    local capacity = vm.OperandStack:pop()
    local d = Dictionary(capacity)
    vm.OperandStack:push(d)

    return true
end
exports.dict = dict



exports["string"] = function(vm)
    local n = vm.OperandStack:pop()
    local str = PSString(n)
    vm.OperandStack:push(str)
end

-- search
--string  seek  search  post  match  pre  true
--                      string false
local function search(vm)
    local seek = vm.OperandStack:pop()
    local str = vm.OperandStack:pop()

    local startIdx,endIdx = string.find(str, seek)
    if not startIdx then
        vm.OperandStack:push(str)
        vm.OperandStack:push(false)
    else
        local pre = ""
        if startIdx > 1 then
            pre = str:sub(1,startIdx-1)
        end
        local post = str:sub(endIdx+1)
        post = PSString(post)
        pre = PSString(pre)
        vm.OperandStack:push(post)
        vm.OperandStack:push(seek)
        vm.OperandStack:push(pre)
        vm.OperandStack:push(true)
    end

    return true
end
exports.search = search

-- anchorsearch
-- string seek anchorsearch post match true
-- string seek anchorsearch string false

local function anchorsearch(vm)
    local seek = vm.OperandStack:pop()
    local str = vm.OperandStack:pop()

    local startIdx,endIdx = string.find(str, seek)
    if not startIdx or startIdx ~= 1 then
        vm.OperandStack:push(str)
        vm.OperandStack:push(false)
    else
        local post = str:sub(endIdx+1)
        vm.OperandStack:push(post)
        vm.OperandStack:push(seek)
        vm.OperandStack:push(true)
    end

    return true
end
exports.anchorsearch = anchorsearch


--[[
-- apply to arrays
--]]
--setpacking
--currentpacking

-- dictionaries
--countdictstack
--cleardictstack
local function cleardictstack(vm)
    vm.DictionaryStack:clearToMark();

    return true
end
exports.cleardictstack = cleardictstack


--dictstack


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
exports.known = known

--maxlength

--undef
-- dict key undef -
local function undef(vm)
    local key = vm.OperandStack:pop()
    local dict = vm.OperandStack:pop()
    dict[key] = nil;

    return true;
end
exports.undef = undef

-- <<key1,value1, key2,value2...>>
-- <<, alias for mark
local function beginDictionary(vm)
    vm.OperandStack:push(ps_common.MARK)
end

local function endDictionary(vm)
    local tmpDict = Dictionary()
    while vm.OperandStack:length() > 0 do 
        local value = vm.OperandStack:pop()
        if value == ps_common.MARK then
            break;
        end

        local key = vm.OperandStack:pop()
        if key ~= nil then
            tmpDict[key] = value;
        end
    end
    vm.OperandStack:push(tmpDict)
end

local function currentdict(vm)
    local d = vm.DictionaryStack:currentdict()
    if not d then
        vm.OperandStack:push(ps_common.NULL)
    else
        vm.OperandStack:push(d)
    end

    return true;
end
exports.currentdict = currentdict

--[[
-- String Operators
--]]
local function eq(vm)
    vm.OperandStack:push(vm.OperandStack:pop() == vm.OperandStack:pop())
    return true
end
exports.eq = eq

local function ne(vm)
    vm.OperandStack:push(vm.OperandStack:pop() ~= vm.OperandStack:pop())
    return true
end
exports.ne = ne

local function gt(vm)
    local any2 = vm.OperandStack:pop()
    local any1 = vm.OperandStack:pop()
    
    local value = any1 > any2

    --print("GT: ", any1, any2, value)

    vm.OperandStack:push(value)

    return true
end
exports.gt = gt

local function ge(vm)
    local any2 = vm.OperandStack:pop()
    local any1 = vm.OperandStack:pop()
    vm.OperandStack:push(any1 >= any2)

    return true
end
exports.ge = ge

local function lt(vm)
    local any2 = vm.OperandStack:pop()
    local any1 = vm.OperandStack:pop()
    vm.OperandStack:push(any1 < any2)

    return true
end
exports.lt = lt

local function le(vm)
    local any2 = vm.OperandStack:pop()
    local any1 = vm.OperandStack:pop()
    vm.OperandStack:push(any1 <= any2)

    return true
end
exports.le = le

--[[
-- for both boolean and bitwise
--]]

exports["and"] = function(vm)
    local any2 = vm.OperandStack:pop()
    local any1 = vm.OperandStack:pop()

    if type(any1 == "boolean") then
        vm.OperandStack:push(any1 and any2)
    else
        vm.OperandStack:push(band(any1, any2))
    end
    return true
end

exports["or"] = function(vm)
    local any2 = vm.OperandStack:pop()
    local any1 = vm.OperandStack:pop()

    if type(any1 == "boolean") then
        vm.OperandStack:push(any1 or any2)
    else
        vm.OperandStack:push(bor(any1, any2))
    end
    return true
end

local function xor(vm)
    local any2 = vm.OperandStack:pop()
    local any1 = vm.OperandStack:pop()

    if type(any1 == "boolean") then
        vm.OperandStack:push(any1 and any2)
    else
        vm.OperandStack:push(band(any1, any2))
    end
    return true
end
exports.xor = xor


exports["not"] = function(vm)
    local a = vm.OperandStack:pop()
    if type(a) == "boolean" then
        vm.OperandStack:push(not a)
    else
        vm.OperandStack:push(bnot(a))
    end

    return true
end


local function bitshift(vm)
    local shift = vm.OperandStack:pop()
    local int1 = vm.OperandStack:pop()

    if shift < 0 then
        vm.OperandStack:push(rshift(int1,math.abs(shift)))
    else
        vm.OperandStack:push(lshift(int1,shift))
    end

    return true
end
exports.bitshift = bitshift

--[[
-- Control Operators
--]]
-- if
-- bool proc if
exports["if"] = function(vm)
    local proc = vm.OperandStack:pop()
    local abool = vm.OperandStack:pop()

    if abool then
        vm:execArray(proc)
    end

    return true
end

--ifelse
-- bool  proc1  proc2 ifelse
exports["ifelse"] = function(vm)
    local proc2 = vm.OperandStack:pop()
    local proc1 = vm.OperandStack:pop()
    local abool = vm.OperandStack:pop()

    --print("IFELSE: ", abool, proc1, proc2)

    if abool then 
        --print("IFELSE, TRUE")
        vm:execArray(proc1)
    else
        --print("IFELSE, FALSE")
        vm:execArray(proc2)
    end

    return true
end

--exec

--for
-- initial  increment  limit  proc  for
exports["for"] = function(vm)
    local co = coroutine.create(function()
        local proc = vm.OperandStack:pop()
        local limit = vm.OperandStack:pop()
        local increment = vm.OperandStack:pop()
        local initial = vm.OperandStack:pop()

        --print("for: ", initial, limit, increment, proc)

        for i=initial, limit, increment do
            vm.OperandStack:push(i)
            vm:execArray(proc)
        end
    end)

    local res, val = coroutine.resume(co)
    if not res then
        print("OP:for, res: ", res, val)
    end

    return true
end

--repeat
-- n proc repeat -
exports["repeat"] = function(vm)
    local proc = vm.OperandStack:pop()
    local n = vm.OperandStack:pop()

    --print("REPEAT: ", n, proc)
    local co = coroutine.create(function(vm, proc, n)
        for i=1,n do 
            vm:execArray(proc)
        end
    end)

    local res, val = coroutine.resume(co, vm, proc, n)
    if not res then
        print("OP:repeat, res: ", res, val)
    end

    return true
end

--loop
local function loop(vm)
    local co = coroutine.create(function(vm)
        local proc = vm.OperandStack:pop()

        while true do
            local success, status = vm:execArray(proc)
        end
    end)

    local res, val = coroutine.resume(co, vm)

    if not res then
        print("OP:loop, res: ", res, val)
    end

    return true
end
exports.loop = loop

--forall
-- array proc forall -
local function forall(vm)
    local proc = vm.OperandStack:pop()
    local arr = vm.OperandStack:pop()

    --print("FORALL: ", proc, arr, arr.kind)
    -- do as coroutine to account for a 'exit'
    local co = coroutine.create(function(vm,proc, arr)
        --print("  ROUTINE: ", vm, proc, arr)
        for _, element in arr:elements() do 
            --print("ELEMENT: ", _, element)
            vm.OperandStack:push(element)
            vm:execArray(proc)
        end
    end)

    local res, val = coroutine.resume(co, vm, proc, arr)

    if not res then
        print("OP:forall, res: ", res, val)
    end

    return true
end
exports.forall = forall

--exit
local function exit(vm)

    local res, val = coroutine.yield("exit")
    print("OP:exit - ", res, val)
    
    return true
end
exports.exit = exit

--countexecstack
--execstack
--stop

-- stopped
-- any stopped bool
-- BUGBUG, need real implementation
local function stopped(vm)
    local any = vm.OperandStack:pop()
    vm.OperandStack:push(false)

    return true
end
exports.stopped = stopped

--[[
-- Type, Attribute and Conversion Operators
--]]
--type
--xcheck
--rcheck
--wcheck
--cvlit

--cvx
-- any cvx any
local function cvx(vm)
    -- pop a thing from the stack 
    -- set it as 'isExecutable = true'
    -- put it back on the stack

    local athing = vm.OperandStack:pop()
    print("cvx: ", athing)

    if type(athing == "table") then
        athing.isExecutable = true
        print("CVX: ",athing, athing.isExecutable, athing.kind)
        -- need to create a token that is executable?
    end

    vm.OperandStack:push(athing)

    return true
end
exports.cvx = cvx

--readonly
--executeonly
--noaccess


local function cvi(vm)
    local value = vm.OperandStack:pop()
    local num = tonumber(value)
--print("CVI: ", type(value), value)
    assert(num ~= nil)
    
    if num >= 0 then
        vm.OperandStack:push(math.floor(num))
    else
        vm.OperandStack:push(math.ceil(num))
    end

    return true
end
exports.cvi = cvi

local function cvr(vm)
    vm.OperandStack:push(tonumber(vm.OperandStack:pop()))
    return true
end
exports.cvr = cvr

local function cvn(vm)
end

-- cvs
-- any string cvs substring
local function cvs(vm)
    local str = vm.OperandStack:pop()
    local value = vm.OperandStack:pop()
    local valuestr 

    -- BUGBUG, deal with string precision
    if type(value) == "number" then
        valuestr = string.format("%3.1f", value)
    else
        valuestr = tostring(value)
    end

    local str2 = PSString(valuestr)

    str:reset()
    str:putInterval(0, str2)
    vm.OperandStack:push(str)

    return true 
end
exports.cvs = cvs

local function cvrs(vm)
end

--[[
    File Operators
]]

-- print
-- string print -
local function ps_print(vm)
    local str = vm.OperandStack:pop()
    print(str)
end
exports.print = ps_print

local function stack(vm)
    for _, item in vm.OperandStack:elements() do 
        print(item)
    end
end
exports.stack = stack

local function pstack(vm)
    for _, item in vm.OperandStack:elements() do 
        print(item)
    end
end
exports.pstack = pstack

--[[
    Resource Operators
]]

--[[
    Virtual Memory Operators
]]

--[[
    Miscellaneous Operators
--]]

--bind
local function bind(vm)
    -- pop a proc
    vm:bind()
    -- go through and bind everything
    -- put it back on the stack

    return true
end
exports.bind = bind


--null
local function null(vm)
    vm.OperandStack:push(ps_common.NULL)
    return true
end
exports.null = null

--version
local function version(vm)
    vm.OperandStack:push("3.0")
    return true
end
exports.version = version

--realtime
--usertime
local function usertime(vm)
    -- BUGBUG, should be real system time
    vm.OperandStack:push(5)

    return true
end
exports.usertime = usertime

--languagelevel
--product
--revision
local function revision(vm)
    vm.OperandStack:push(1)
    
    return true
end
exports.revision = revision

--serialnumber
local function serialnumber(vm)
    vm.OperandStack:push(1)
    return true;
end
exports.serialnumber = serialnumber

--executive
local function executive(vm)
    print("NYI: executive")
    return false
end
exports.executive = executive


--echo
--prompt

exports["="] = function(vm)
    local any = vm.OperandStack:pop()
    print(any)
end

exports["=="] = function(vm)
    local any = vm.OperandStack:pop()
    print(tostring(any))
end

local function save(vm)
    vm.OperandStack:push({})
    return true
end
exports.save = save

local function restore(vm)
    local vmstate = vm.OperandStack:pop()

    return true
end
exports.restore = restore

return exports