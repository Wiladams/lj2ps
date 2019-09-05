local enum = require("lj2ps.enum")

--[[
Use TokenType to both indicate a kind of character
as well as a parse state.  Makes things easier
--]]

local TokenType = enum {                                   
    -- Single-character tokens.                      
    -- matched sets
    "LEFT_PAREN",       -- (
    "RIGHT_PAREN",      -- )
    "LEFT_ANGLE",       -- <
    "RIGHT_ANGLE",      -- >
    "LEFT_BRACKET",     -- [
    "RIGHT_BRACKET",    -- ]
    "LEFT_BRACE",       -- {
    "RIGHT_BRACE",      -- }


    -- single characters
    "COLON",        -- :
    "COMMA",        -- ,
    "DOT",          -- .
    "MINUS",        -- -
    "PERCENT",      -- %
    "POUND",        -- #
    "PLUS",         -- +
    "SLASH",        -- /
    "STAR",         -- *
    "QUESTION",     -- ?



    -- values                                     
    "BEGIN_OBJECT",
    "END_OBJECT",
    "BEGIN_ARRAY",
    "END_ARRAY",
    "NAME",
    "LITERAL_NAME",
    "STRING", 
    "NUMBER",
    "BOOLEAN",
    "COMMENT",
    
    -- literals

}

local Token_mt = {
    __tostring = function(self)
        --print("__tostring, Kind: ", self.Kind, TokenType[self.Kind])
        return string.format("'%s' %s %s", TokenType[self.kind], self.lexeme, self.literal or self.value)
    end;
}
local function Token(obj)
    setmetatable(obj, Token_mt)
    return obj;
end



return {
    NULL = "null";
    MARK = "mark";
    Token = Token;
    TokenType = TokenType;
}
