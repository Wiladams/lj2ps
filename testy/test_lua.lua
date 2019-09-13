package.path = "../?.lua;"..package.path

local enum = require("lj2ps.enum")

local function test_enum()
local some = enum {
    [0]= "a",
    "b",
    [10] = "c",
    "d"
}

    print(some["a"])
    print(some["b"])
    print(some["c"])
    print(some["d"])
print("========")
    print(some[0])
    print(some[1])
    print(some[10])
    print(some[11])
end

test_enum()
