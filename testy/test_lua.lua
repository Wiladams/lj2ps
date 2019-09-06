package.path = "../?.lua;"..package.path

local ps_common = require("lj2ps.ps_common")
local Array = ps_common.Array

local arr = Array(3)
print("Size: ", #arr)
arr[0] = true
arr[2] = true
arr[3] = "fake"
print("Values")
print(arr[0])
print(arr[1])
print(arr[2])
print(arr[3])
print("Array Size, extended: ", #arr)

print("Array.kind: ", arr.kind)