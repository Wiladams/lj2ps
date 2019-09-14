package.path = "../?.lua;"..package.path

local ps_common = require("lj2ps.ps_common")
local Stack = ps_common.Stack 

local s = Stack()

local function pstack(s)
    for _, item in s:items() do
        print(item)
    end
end

local function test_copy()
    local s = Stack()
    for i=1,10 do
        s:push(i)
    end

    s:copy(#s)
    pstack(s)
end

local function test_enumerate()
    local s = Stack()
    s:push(1)
    s:push(2)
    s:push(3)

    print("-- enumerate --")
    for idx, value in s:items() do 
        print(idx, value)
    end
end

local function test_length()
    print("stack length: ", s:length())
end

local function test_pop()
    local s = Stack()

s:push(1)
s:push(2)
s:push(3)

print("-- pop --")
print(s:pop())
print(s:pop())
print(s:pop())
end

local function pop(src, n)
    local tmp = {}
    for i=1,n do
        tmp[i] = src[#src-n+i]
    end

    return unpack(tmp)
end

local function test_popn()
    local src = {1,2,3,4,5,6,7,8,9}
    print(pop(src, 3))
end

local function test_roll()
    print("==== test_roll ====")
    local s = Stack()
    for i=1,10 do
        s:push(i)
    end

    print("roll(10,5)")
    s:roll(10, 5)
    pstack(s)

    print("roll(10,-5)")
    s:roll(10, -5)
    pstack(s)

    print("(a) (b) (c) (d) (e) 5 3 roll")
    s:push("a")
    s:push("b")
    s:push("c")
    s:push("d")
    s:push("e")
    s:roll(5, 3)
    pstack(s)
end

local function test_nth()
    print("==== test_nth ====")
    local s = Stack()

    s:push(1)
    s:push(2)
    s:push(3)

    print("nth(0): ", s:nth(0))
    print("nth(1): ", s:nth(1))
    print("nth(2): ", s:nth(2))
    print("nth(3): ", s:nth(3))
end

test_copy()
--test_nth()
--test_popn()
--test_roll()
