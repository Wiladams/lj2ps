package.path = "../?.lua;"..package.path

local PostscriptVM = require("lj2ps.ps_vm")
local OperatorStack = require("lj2ps.ps_OperatorStack")
local ops = require("lj2ps.ps_operators")

--[[
/ppi 72 def
10 ppi mul
--]]

local vm = PostscriptVM()
vm:pushStringLiteral("ppi")
vm:push(72)
vm:def()

vm:push(10)
vm:push("ppi")
vm:mul()

vm:pstack()
