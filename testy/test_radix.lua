local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor

local pow = math.pow
local B = string.byte

local function isdigit(c)
	return c >= B'0' and c <= B'9'
end

local function islower(c)
	return c >= B'a' and c <= B'z';
end

local function toupper(c)
	if (islower(c)) then
		return band(c, 0x5f)
	end

	return c
end

-- take an ascii number, and convert it to a decimal number
-- based on an alphabet
-- 0x30 - 0x39
-- 0x41 - 0x5A  (A - Z)
local function alphaToNum(c)
    local C = toupper(c)
    if isdigit(C) then
        return C - B'0'
    end

    local num = C - B'A'
    if num >=0 and num <= 26 then
        return num + 10
    end

    return nil
end

-- in lua, you can simply call tonumber(str, base)
-- but here we want to actually calculate it out just
-- to have an example of doing the calculation
local function radixNumber(str, base)
    --print("radixNumber: ", base, str)
    -- traverse the string, adding powers as we go
    local n = #str
    local chars = ffi.cast("const char *", str)
    local sum = 0
    for i=n-1, 0, -1 do
        local multiplier = pow(base, (n-i-1))
        local num = alphaToNum(chars[i])
        sum = sum + (num * multiplier)
    end

    return sum
end

print(radixNumber("123", 10))
print(radixNumber("7F", 16))
print(radixNumber("1011", 2))

print(tonumber("17", 8))