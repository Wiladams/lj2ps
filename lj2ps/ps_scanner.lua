local ffi = require("ffi")
local cctype = require("lj2ps.cctype")
local isdigit = cctype.isdigit
local isalpha = cctype.isalpha
local isalnum = cctype.isalnum
local isgraph = cctype.isgraph

local ps_common = require("lj2ps.ps_common")

local Token = ps_common.Token;
local TokenType = ps_common.TokenType;


local B = string.byte

-- create an array that contains characters
local function createSet(str)
    local bytes = {string.byte(str,1,#str)}
    local res = {}
    for i=1,#str do
        res[bytes[i]] = true
    end

    return res
end


local escapeChars = createSet('/\\"bfnrtu')
local delimeterChars = createSet('()<>[]{}/%')
local whitespaceChars = createSet('\t\n\f\r ')  -- whitespace characters

local function iswhitespace(c)
    return c == B' ' or c == B'\t' or
        c == B'\n' or c == '\r'
end

local function skipspaces(bs)
    while true do
        if bs:isEOF() then
            return false;
        end

        if whitespaceChars[bs:peekOctet()] then
            bs:skip(1)
        else
            return true;
        end
    end
end


-- The lexemeMap gives us a table that represents the start of a 
-- lexeme, and what action should be taken to deal with it.
-- each entry is a function that performs the necessary, typically
-- generating a token to be consumed by whomever is scanning.
local lexemeMap = {}

lexemeMap[B' '] = function(self, bs)
    -- do nothing with it
    print("[SPACE]")
end

lexemeMap[B'\n'] = function(self, bs)
    -- do nothing with it
    print("[NEWLINE]")
end

lexemeMap[B'['] = function(self, bs)
    self.Vm:beginArray()
end

lexemeMap[B']'] = function(self, bs) 
    self.Vm:endArray()
    
    if not self.isBuildingProcedure then
        local arr = self.Vm:pop()
        return (Token{kind = TokenType.LITERAL_ARRAY, value = arr, line=bs:tell()}); 
    else
        -- just keep the array on the stack
    end
end

lexemeMap[B'('] = function(self, bs)
    -- start reading a literal text string
    -- until we see a terminating ')'
    local starting = bs:tell()
    local startPtr = bs:getPositionPointer();
    while not bs:isEOF() do
        local c = bs:peekOctet()
        if c == B')' then
            break;
        end

        bs:skip(1);
    end

    local ending = bs:tell()
    local len = ending - starting

    -- skip over closing delimeter
    bs:skip(1)

    local value = ffi.string(startPtr, len)

    return Token{kind = TokenType.STRING, lexeme='', literal=value, line=bs:tell()}
end

lexemeMap[B')'] = function(self, bs) 
    return (Token{kind = TokenType.RIGHT_PAREN, lexeme=')', literal='', line=bs:tell()}); 
end

-- build up a procedure
lexemeMap[B'{'] = function(self, bs) 
    self.isBuildingProcedure = true
    -- in this case, an executable Array
    self.Vm:beginExecutableArray()
end

lexemeMap[B'}'] = function(self, bs) 
    -- finish building procedure
    -- gather up array elements until mark
    -- array astore array
    self.Vm:push(1000)
    self.Vm:array()
    self.Vm:astore()

    local arr = self.Vm:pop()

    self.isBuildingProcedure = false;

    -- and hand an executable array to the scanner
    return Token{kind = TokenType.EXECUTABLE_ARRAY, value = arr, line=bs:tell()}
end

-- processing a comment, consume til end of line or EOF
-- totally throw away comment
lexemeMap[B'%'] = function(self, bs)
    while bs:peekOctet() ~= B'\n' and not bs:isEOF() do
        bs:skip(1)
    end
end

-- scan a number
-- something got us here, it was either
-- a digit, a '-'
local function lex_number(self, bs)
    local starting = bs:tell();
    local startPtr = bs:getPositionPointer();

    -- get through all digits
    -- -, digit, ., E, digits
    if bs:peekOctet() == B'+' or bs:peekOctet() == B'-' then
        bs:skip(1)
    end

    -- next, MUST be 0 or [1..9]
    while(isdigit(bs:peekOctet())) do
        bs:skip(1);
    end

    -- look for fraction part
    --print("lex_number: ", string.char(bs:peekOctet()), string.char(bs:peekOctet(1)))
    if (bs:peekOctet() == B'.') then
        if isdigit(bs:peekOctet(1)) then
            bs:skip(1);

            while isdigit(bs:peekOctet()) do
                bs:skip(1);
            end
        elseif whitespaceChars[bs:peekOctet(1)] then
            bs:skip(1)
        end
    end

    local ending = bs:tell();
    local len = ending - starting;

    local value = tonumber(ffi.string(startPtr, len))
    
    return value;

end

-- scan identifiers
local function lex_name(self, bs)
    --print("lex_name")
    local starting = bs:tell();
    local startPtr = bs:getPositionPointer();

    while not bs:isEOF() do
        local c = bs:peekOctet()
        if delimeterChars[c] or whitespaceChars[c] then
            break;
        end

        bs:skip(1);
    end

    local ending = bs:tell();
    local len = ending - starting;
    local value = ffi.string(startPtr, len)
--print("value: ", value)
    local tok =  Token{kind = TokenType.EXECUTABLE_NAME, value = value, position=bs:tell()}

    return tok
end

lexemeMap[B'/'] = function(self, bs) 
    print("LITERAL")
    local tok = lex_name(self, bs)
    tok.kind = TokenType.LITERAL_NAME

    return tok
end



local Scanner = {}
setmetatable(Scanner, {
    __call = function(self, ...)
        return self:new(...);
    end;
})
local Scanner_mt = {
    __index = Scanner;
}

function Scanner.new(self, vm, bs)
    local obj = {
        Vm = vm;
        Stream = bs;
    }
    setmetatable(obj, Scanner_mt)

    return obj
end

--[[
 iterator, returning individually scanned lexemes
 need to make this pure functional
 create a range on the stream?
--]]
function Scanner.tokens(self)

    local function token_gen(bs, state)

        while not bs:isEOF() do
            -- skip any leading whitespace to start
            skipspaces(bs)
            if bs:isEOF() then 
                break;
            end

            local c = bs:readOctet()

            if lexemeMap[c] then
                local tok, err = lexemeMap[c](self, bs)
                if tok then
                    if self.isBuildingProcedure then
                        self.Vm:push(tok.value)
                    else
                        return bs:tell(), tok
                    end
                else
                    -- deal with error if there was one
                end
            else
                if isdigit(c) or c == B'-' then
                    bs:skip(-1)
                    local value = lex_number(self, bs)

                    if value then
                        if self.isBuildingProcedure then
                            self.Vm.OperandStack:push(value)
                        else
                            return Token({kind = TokenType.NUMBER, value=value, line=bs:tell()})
                        end
                    end
                    
                elseif isgraph(c) then
                    bs:skip(-1)
                    local tok = lex_name(self, bs)
                    if self.isBuildingProcedure then
                        self.Vm.OperandStack:push(tok.value)
                    else
                        return bs:tell(), tok
                    end
                else
                    print("UNKNOWN: ", c, string.char(c)) 
                end
            end
        end
    end

    return token_gen, self.Stream, self.Stream:tell()
end

return Scanner