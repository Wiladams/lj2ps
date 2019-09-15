package.path = "../?.lua;"..package.path

local ps_vm = require("lj2ps.ps_vm")

local vm = ps_vm()

print("PS VM, Revision: ")
vm:revision()
vm:pstack()
vm:clear()
print("-----------------")


local function test_aliasing()
vm:push(10)
vm:push(20)
vm:add()
print(vm:top())
print(vm:top())
end


local function test_dict()
    print("==== test_dict ====")
    vm:push(3)
    vm:dict()

    print(vm:top())
end

local function test_currentdict()
    vm:push(3)
    vm:dict()
    vm:BEGIN()
--[[
    vm:push("proc1")
    vm:beginProc()
    vm:pop()
    vm:endProc()
    vm:def()

    vm:push("two")
    vm:push(2)
    vm:def()

    vm:push("three")
    vm:push("trois")
    vm:def()
--]]
    vm:currentdict()
    vm:END()

    print(vm:top())
end

local function test_stack()
    vm:push(11)
    vm:push(12)
    vm:push(13)

    vm:pstack()
end

local function test_procedure()
    vm:push("average")
    vm:beginProcedure()
    vm:pushOperator('add')
    vm:push(2)
    vm:pushOperator('div')
    vm:endProcedure()
    vm:def()
    vm:push(40)
    vm:push(60)
    vm:push("average")
end

--test_aliasing()
--test_dict()
--test_currentdict()
test_stack()
