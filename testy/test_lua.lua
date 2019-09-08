package.path = "../?.lua;"..package.path

local ps_common = require("lj2ps.ps_common")
local Array = ps_common.Array

local function test_array()
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
end 

local function test_truncate()
    local v1 = 4.23
    local v2 = -3.8

    print("FLOOR")
    print(math.floor(v1))
    print(math.floor(v2))

    print("CEIL")
    print(math.ceil(v1))
    print(math.ceil(v2))
end

--test_array()
test_truncate()

