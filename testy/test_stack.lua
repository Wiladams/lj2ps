package.path = "../?.lua;"..package.path

local collections = require("lj2ps.collections")
local Stack = collections.Stack 

local s = Stack()



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

test_nth()
