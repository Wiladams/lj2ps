package.path = "../?.lua;"..package.path

local OperatorStack = require("ps_OperatorStack")
local ops = require("ps_operators")

local function test_stack()
    print("==== test_stack ====")
    local stk = OperatorStack()

    stk:push(10)
    stk:push(20)
    print("length: ", stk:length())
    print("pop: ", stk:pop())
    print("pop: ", stk:pop())
end

local function test_add()
    print("==== test_add ====")
    local stk = OperatorStack()

    stk:push(10)
    stk:push(20)
    ops.add(stk)
    print("add: ", stk:top())
end

local function test_mark()
    print("==== test_mark ====")
    local stk = OperatorStack()

    stk:push(1)
    stk:push(3)
    print("Stack length, before mark: ", stk:length())
    ops.mark(stk)
    stk:push(5)
    stk:push(7)

    print("Stack length, after mark: ", stk:length())
    print("cleartomark")
    ops.cleartomark(stk)
    print("Stack length, after clear: ", stk:length())
end

--test_stack()
--test_add()
test_mark()
