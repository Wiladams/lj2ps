package.path = "../?.lua;"..package.path

local collections = require("wordplay.collections")
local Stack = collections.Stack 

local s = Stack()

s:push(1)
s:push(2)
s:push(3)

for idx, value in s:items() do 
    print(idx, value)
end


print("stack length: ", s:length())

print(s:pop())
print(s:pop())
print(s:pop())
