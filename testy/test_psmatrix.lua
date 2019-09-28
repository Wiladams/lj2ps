package.path = "../?.lua;"..package.path

local Matrix = require("lj2ps.ps_matrix")

local function MAP(a, rlo, rhi, slo, shi) 
    return slo + (a - rlo) * (shi - slo) / (rhi - rlo)
end

local function test_identity()
    print("==== test_identity ====")
    local m1 = Matrix:createIdentity()
    print("m1:")
    print(m1)
end

local function test_scale()
    print("==== test_scale ====")
    local s = Matrix:createScaling(2.67, 2.67)
    print("m1 (2.67, 2.67):")
    print(s)

    local x1, y1 = s:transformPoint(72,72)
    print("transformPoint(72,72)->(192,192)")
    print(x1, y1)
end

local function test_translation()
    print("==== test_translation ====")

    local m1 = Matrix:createTranslation(2, 2)
    print("m1 (2,2")
    print(m1)

    local x1, y1 = m1:transformPoint(2,3)
    print("transformPoint(2,2)->(4,5)")
    print(x1, y1)
end

local function test_concat()
    print("==== test_concat ====")
    local i = Matrix:createIdentity()
    local t = Matrix:createTranslation(0, 11*192)
    local s1 = Matrix:createScaling(1,-1)
    local s2 = Matrix:createScaling(2.67, 2.67)
    local r = Matrix:createRotation(45)

    print("scale(2.67, 2.67), translate(72)")
    i:preMultiplyBy(s1)
    i:preMultiplyBy(t)
    i:preMultiplyBy(s2)

    print("i")
    print(i)

    print("transform(72,0)")
    local x1, y1 = i:transformPoint(72,0)
    print(x1,y1)
end

local function test_map()
    print("==== test_map ====")
    print("map: 0,13")
    local y = MAP(13, 0,2112, 2112, 0)
    print("y: ", y)
end

test_map()
--test_identity()
--test_translation()
--test_rotation()
--test_scale()
--test_concat()
