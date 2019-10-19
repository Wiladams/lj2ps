local enum = require("lj2ps.enum")

--[[
Use TokenType to both indicate a kind of character
as well as a parse state.  Makes things easier
--]]

local exports = {
    NULL = "NULL";
    MARK = "MARK";
}

local TokenType = enum {                                   
    -- Single-character tokens.                      
    -- matched sets

    -- Token Kinds
    "LITERAL_ARRAY",    -- []
    "PROCEDURE",        -- {}
    "OPERATOR",         -- a function which has been bound
    
    "LITERAL_NAME",     -- /name
    "EXECUTABLE_NAME",  -- name

    "STRING",           -- (string)
    "HEXSTRING",        -- <hexstring>
    "NUMBER",           -- int, float, hex
    "BOOLEAN",          -- true, false
    "COMMENT",          -- % to end of line
}

local Token_mt = {
    __tostring = function(self)
        --print("Token_mt- kind, value: ", self.kind, self.value)
        --return string.format("'%s' %s %s", TokenType[self.kind], self.lexeme, self.literal or self.value or '')
        return string.format("'%s' %s", TokenType[self.kind], tostring(self.value))
    end;
}
local function Token(obj)
    setmetatable(obj, Token_mt)
    return obj;
end


--[[
    pure functional iterators are supposed to be
    copyable.  Some iterators, such as cycle, 
    use this feature.
]]
local function deepCopy(orig)
    local otype = type(orig)
    local copy

    if otype == "table" then
        copy = {}
        for okey, ovalue in next, orig, nil do
            copy[deepCopy(okey)] = deepCopy(ovalue)
        end
    else
        -- kind of cheap bailout.  The orig
        -- might have a clone() function
        copy = orig
    end
    return copy
end

exports.Token = Token;
exports.TokenType = TokenType;
exports.deepCopy = deepCopy;

return exports 
