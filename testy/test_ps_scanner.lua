package.path = "../?.lua;"..package.path


local ps_common = require("lj2ps.ps_common")
local TokenType = ps_common.TokenType
local ps_scanner = require("lj2ps.ps_scanner")
local octetstream = require("lj2ps.octetstream")

local function test_tokens()
local bs = octetstream([[
% comment
123
(This is a string)
(These \
two strings \
are the same.)
(These two strings are the same.)
(This string has a newline at the end of it
)
(So does this one\n)
]])

for _, token in ps_scanner(bs) do
    print(token)
end
end

local function test_token_type()
    print("TokenType, size: ", #TokenType)
    for k,v in pairs(TokenType) do
        print(k,v)
    end
end

local function test_name()
    local bs = octetstream([[
abc Offset $$ 23A 13-456 a.b $MyDict @pattern /Absolute
]])

    for _, token in ps_scanner(bs) do
        print(token)
    end
end

local function test_array()
    local bs = octetstream([[
[123 /abc (xyz)]
]])

    for _, token in ps_scanner(bs) do
        print(token)
    end
end

local function test_procedure()
    local bs = octetstream([[
{add 2 div}
]])

    for _, token in ps_scanner(bs) do
        print(token)
    end
end

--test_tokens()
--test_token_type()
--test_name()
--test_array()
test_procedure()


