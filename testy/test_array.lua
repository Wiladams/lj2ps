package.path = "../?.lua;"..package.path

local Array = require("lj2ps.array")

local arr = Array(10)

local function test_attributes()
    print("arr.capacity: ", arr.capacity)
    print("arr:length(): ", arr:length())
end

local function test_getinterval()
    local arr = Array(10)
    for i=0,9 do
        arr[i] = i
    end

    local sub = arr:getInterval(3,2)

    print("SUB, 3,2")
    local sub = arr:getInterval(3,2)
    for i=0,#sub-1 do
        io.write(" ", sub[i])
    end
    print()

    print("SUB, 8,3")
    local sub = arr:getInterval(8,3)
    for i=0,#sub-1 do
        io.write(" ", sub[i])
    end
    print()
end

local function test_putinterval()
    local arr1 = Array(10)
    for i=0,9 do arr1[i] = i end

    local arr2 = Array(10)
    for i=0,9 do arr2[i] = i*10 end

    arr1:putInterval(5,arr2)

    for i=0,9 do
        print(i,arr1[i])
    end
end

local function test_elements()
    local arr1 = Array(10)
    for i=0,9 do arr1[i] = i end

    print(arr1:elements())
    for _, element in arr1:elements() do
        print(element)
    end
end

--test_attributes()
--test_getinterval()
--test_putinterval()
test_elements()
