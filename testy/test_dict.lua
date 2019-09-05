package.path = "../?.lua;"..package.path

local namespace = require("lj2ps.namespace")
local PostscriptVM = require("lj2ps.ps_vm")
local OperatorStack = require("lj2ps.ps_OperatorStack")
local ops = require("lj2ps.ps_operators")

local ns = namespace(ops)
-- put ops into a local namespace

--[[
3 dict begin  
 /proc1 { pop } def  
 /two 2 def  
 /three (trois) def 
currentdict 
end
--]]

local vm = PostscriptVM()

-- 3 dict begin 
-- {3, ops.push, ops.dict, ops.begin}
--vm:push(3):dict():begin()
vm:push(3)
vm:dict()
vm:BEGIN(vm)

-- /proc1 { pop } def  
vm:pushStringLiteral("proc1")
vm:push(ops.pop)
vm:def()

vm:currentdict()
vm:END()


vm:pstack()
