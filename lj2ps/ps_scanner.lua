local ffi = require("ffi")

local ps_common = require("lj2ps.ps_common")
local PSString = require("lj2ps.ps_string")

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
local whitespaceChars = createSet('\t\n\f\r ')          -- whitespace characters
local hexChars = createSet('0123456789abcdefABCDEF')    -- hex digits
local digitChars = createSet('0123456789')
local numBeginChars = createSet('+-.0123456789')

local function isgraph(c)
	return c > 0x20 and c < 0x7f
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
    

    local arr = self.Vm:pop()
    return (Token{kind = TokenType.LITERAL_ARRAY, value = arr, line=bs:tell()}); 
end

-- string literal
local name_buff = PSString(65535)
lexemeMap[B'('] = function(self, bs)
    -- start reading a literal text string
    -- until we see a terminating ')'
    local starting = bs:tell()
    local startPtr = bs:getPositionPointer();
    name_buff:reset()

    while not bs:isEOF() do
        local c = bs:peekOctet()
        if c == B')' then
            break;
        end

        -- deal with various forms of embedded chars
        if c == B'\\' then
            if escapeChars[bs:peekOctet(1)] then
                -- embed the char
                name_buff:append(bs:peekOctet(1))
            else
                -- ran into a char that's escaped but not one
                -- that we recognize
                break
            end
        end

        bs:skip(1);
    end

    local ending = bs:tell()
    local len = ending - starting

    -- skip over closing delimeter
    bs:skip(1)

    local value = ffi.string(startPtr, len)

    return Token{kind = TokenType.STRING, value=value, line=bs:tell()}
end

-- hexadecimal string
lexemeMap[B'<'] = function(self, bs) 
    --print("LEFT_ANGLE")
    local starting = bs:tell()
    local startPtr = bs:getPositionPointer();



    while not bs:isEOF() do
        local c = bs:peekOctet()
        if c == B'>' then
            break;
        end
        
        if hexChars[c] then
        elseif not whitespaceChars[c] then
            error("hexstring, found non-space, non-hex")
        end

        bs:skip(1);
    end

    -- get the end of the string
    local ending = bs:tell()
    local len = ending - starting

    -- skip over closing delimeter
    bs:skip(1)

    local str = ffi.string(startPtr, len)
    --print("hexstring: ", str)
    -- convert to numbers
    local tbl = {}
    for byte in str:gmatch('%x%x') do
        local bytenum = tonumber(byte,16)
        local byteval = string.char(bytenum)
        table.insert(tbl,byteval)
    end
    local value = table.concat(tbl)
    --print("value: ",#tbl, string.byte(tbl[1]), string.byte(tbl[2]), string.byte(tbl[3]))
    
    return Token{kind = TokenType.HEXSTRING, value=value, line=bs:tell()}
end

-- build up a procedure
-- use the Vm's operandstack itself to build 
-- the array
-- BUGBUG - an optimization would be to simply capture tokens
-- right here until the closing brace.
-- Doing it this way would avoid going through the 
-- Postscript VM and operand stack.
lexemeMap[B'{'] = function(self, bs) 
    --print("LEFT_CURLY BRACE")
    self.Vm:beginProc()
end

lexemeMap[B'}'] = function(self, bs)
    --print("RIGHT_CURLY_BRACE")

    local arr = self.Vm:endProc()

    -- and hand an executable array to the scanner
    return Token{kind = TokenType.PROCEDURE, value = arr, line=bs:tell()}
end

-- processing a comment, consume til end of line or EOF
-- totally throw away comment
lexemeMap[B'%'] = function(self, bs)
    --print("COMMENT")
    while bs:peekOctet() ~= B'\n' and not bs:isEOF() do
        bs:skip(1)
    end
end





-- scan identifiers
local function lex_name(self, bs)
    --print("lex_name")
    local starting = bs:tell();
    local startPtr = bs:getPositionPointer();
    name_buff:reset()

    -- read to end of stream, or til delimeter
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
--print("lex_name; value: ", value)

    local tok =  Token{kind = TokenType.EXECUTABLE_NAME, value = value, position=bs:tell()}

    if value == "true" or value == "false" then
        if value == "true" then
            tok.value = true
        else
            tok.value = false
        end

        tok.kind = TokenType.BOOLEAN    
    end

    return tok
end

-- scan a number
-- something got us here, it was something in numBeginChars
-- valid: 8.35928e-09
-- numBeginChars["+-.[digit]"]
-- If not valid number, return nil
local function lex_number(self, bs)
    local starting = bs:tell();
    local startPtr = bs:getPositionPointer();
--print("lex_number: ", starting)
    -- First, let's look for a valid starting character
    -- -, +, ., digit
    if numBeginChars[bs:peekOctet()] then
        --print("  SKIP 1")
        bs:skip(1)
    else
        print("INVALID START of NUMBER: ", string.char(bs:peekOctet()))
        return nil
    end

    -- scan until a delimeter found
    while true do
        if bs:isEOF() then
            break
        end

        local c = bs:peekOctet()
        --io.write(string.char(c))
        
        if whitespaceChars[c] then
            --print("SPACE")
            break
        end

        if delimeterChars[c] then
            break
        end

        bs:skip(1)
    end


    local ending = bs:tell();
    local len = ending - starting;

    local str = ffi.string(startPtr, len)
    local value = tonumber(str)

    --print("LEX_NUMBER: ", starting, len, str, value)

    if not value then
        return nil
    end

    --print("LEX_NUMBER: ", starting, len, str, value)
    local tok = Token({kind = TokenType.NUMBER, value=value, line=bs:tell()})

    return tok
end


lexemeMap[B'/'] = function(self, bs) 
    --print("LITERAL")
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
                    if self.Vm:isBuildingProc() then
                        self.Vm.OperandStack:push(tok)
                    else
                        return bs:tell(), tok
                    end
                else
                    --print("no token for: "..string.char(c))
                    -- deal with error if there was one
                end
            else
                -- handle the case of numbers
                -- and names that begin with a number
                if numBeginChars[c] then
                    -- backup one and try to scan the number
                    bs:skip(-1)
                    local sentinel = bs:tell()
                    local tok = lex_number(self, bs)
                    if not tok then
                        bs:seekFromBeginning(sentinel)
                        tok = lex_name(self, bs)
                    end

                    if tok then
                        if self.Vm:isBuildingProc() then
                            self.Vm.OperandStack:push(tok)
                        else
                            return bs:tell(), tok
                        end
                    end
                elseif isgraph(c) then
                    bs:skip(-1)
                    local tok = lex_name(self, bs)
                    if self.Vm:isBuildingProc() then
                        self.Vm.OperandStack:push(tok)
                    else
                        return bs:tell(), tok
                    end
                else
                    print("SCANNER UNKNOWN: ", c, string.char(c)) 
                end
            end
        end
    end

    return token_gen, self.Stream, self.Stream:tell()
end

return Scanner