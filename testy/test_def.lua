package.path = "../?.lua;"..package.path

local PostscriptVM = require("lj2ps.ps_vm")
local ops = require("lj2ps.ps_operators")

--[[
/ppi 72 def
10 ppi mul
--]]

local vm = PostscriptVM()
vm:pushLiteralName("ppi")
vm:push(72)
vm:def()

vm:push(10)
vm:push("ppi")
vm:mul()

vm:pstack()
