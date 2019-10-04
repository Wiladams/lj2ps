package.path = "../?.lua;"..package.path

local String = require("lj2ps.ps_string")

local s1 = String(5)

local B = string.byte

s1[0] = B'h'
s1[1] = B'e'
s1[2] = B'l'
s1[3] = B'l'
s1[4] = B'o'
s1[5] = B' '

print("s1: ", s1)
print(" capacity: ", s1.capacity)

local function test_iteration()
    for _, e in s1:elements() do
        print(string.char(e))
    end
end

local function test_put()
    s1:put(2,B'L')
    print(s1)
end

local function test_get()
    print(s1:get(2), s1:get(3), s1:get(4))
end

local function test_getInterval()
    print(s1:getInterval(2,3))
end

local function test_putInterval()
    local s2 = String("HELLO")
    print(s1:putInterval(2,s2))
end

--test_iteration()
--test_put()
--test_get()
--test_getInterval()
test_putInterval()


