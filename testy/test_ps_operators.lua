package.path = "../?.lua;"..package.path

local PostscriptVM = require("lj2ps.ps_vm")
local OperatorStack = require("lj2ps.ps_OperatorStack")
local ops = require("lj2ps.ps_operators")

local vm = PostscriptVM()

local function test_stack()
    print("==== test_stack ====")
    local stk = OperatorStack()

    vm:push(10)
    vm:push(20)
    print("length: ", vm.OperatorStack:length())
    print("pop: ", vm:pop())
    print("pop: ", vm:pop())
end

local function test_add()
    print("==== test_add ====")

    vm:push(10)
    vm:push(20)
    ops.add(vm)
    print("add: ", vm.OperandStack:top())
end

local function test_mark()
    print("==== test_mark ====")

    vm:push(1)
    vm:push(3)
    print("Stack length, before mark: ", vm.OperandStack:length())
    ops.mark(vm)
    vm:push(5)
    vm:push(7)

    print("Stack length, after mark: ", vm.OperandStack:length())
    vm:pstack()
    print("cleartomark")
    ops.cleartomark(vm)
    print("Stack length, after clear: ", vm.OperandStack:length())
end

--test_stack()
--test_add()
test_mark()
