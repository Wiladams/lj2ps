package.path = "../?.lua;"..package.path

local ps_common = require("lj2ps.ps_common")
local Dictionary = require("lj2ps.Dictionary")

local d = Dictionary(30)

d.alpha = true
d.gamma = true
d.beta = true
d.delta = true

print(print("size: ", #d)
print("d.alpha: ", d.alpha)