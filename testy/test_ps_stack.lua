package.path = "../?.lua;"..package.path

local ps_common = require("lj2ps.ps_common")

local Stack = require("lj2ps.ps_stack")

local s1 = Stack()

s1:pushn(1,2,3)
print(s1:popn(3))

