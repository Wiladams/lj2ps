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
    
    "BEGIN_PROCEDURE",  -- {
    "END_PROCEDURE",    -- }

    "BEGIN_ARRAY",      -- [
    "END_ARRAY",        -- ]
    "LITERAL_ARRAY",
    "EXECUTABLE_ARRAY",
    
    "LITERAL_NAME",     -- /name
    "EXECUTABLE_NAME",  -- name

    "STRING",           -- (string), <string>
    "NUMBER",           -- int, float, hex
    "BOOLEAN",          -- true, false
    "COMMENT",          -- % to end of line
}

local Token_mt = {
    __tostring = function(self)
        --print("__tostring, Kind: ", self.Kind, TokenType[self.Kind])
        --return string.format("'%s' %s %s", TokenType[self.kind], self.lexeme, self.literal or self.value or '')
        return string.format("'%s' %s", TokenType[self.kind], self.literal or self.value or '')
    end;
}
local function Token(obj)
    setmetatable(obj, Token_mt)
    return obj;
end

--[[
	Array

	A fixed size array, with an index starting at '0'
	Useful when we want a more typical 'C' style array
	of a fixed size.

	The array guards against writing past its stated
	capacity.

	local arr = Array(5)
]]
local Array = {}
setmetatable(Array, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local Array_mt = {
	-- using trying to retrieve a value
	__index = function(self, idx)
		if type(idx) == "string" then
			if idx == "kind" then
				return 'array'
            elseif idx == "isExecutable" then
                return rawget(self,"__isExecutable")
            end
		end

		idx = tonumber(idx)
		if not idx then return nil end
		
        return self.__impl[idx+1]
    end;

	-- user trying to set a value
	__newindex = function(self, idx, value)
		local key = tonumber(idx)
        if type(idx) == "string" then
            if tonumber(idx) then
                idx = tonumber(idx)
            else
                if idx == "isExecutable" then
                    rawset(self, __isExecutable, value)
                    return nil
                end
            end
        end

		-- protect against index beyond capacity
        if idx >= self.__capacity then return false end

        self.__impl[idx+1] = value
    end;

    __len = function(self)
        return self.__capacity
    end;
}

function Array.new(self, cnt)
    cnt = cnt or 100
    isExecutable = isExecutable or false

    local obj = {
        __capacity = cnt;
        __impl = {};
        __isExecutable;
	}
	
    --for i=1,cnt do
    --    obj.__impl[i]=false;
    --end
    setmetatable(obj, Array_mt)

    return obj
end


--[[
    Dictionary
]]
local Dictionary = {}
setmetatable(Dictionary, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local Dictionary_mt = {

	-- using trying to retrieve a value
	__index = function(self, idx)
		if type(idx) == "string" then
			if idx == "kind" then
				return 'dictionary'
			end
		end
		
        return self.__impl[idx]
    end;

	-- user trying to set a value
	__newindex = function(self, idx, value)
		-- protect against non-numeric index
		if not idx then return false end

		-- protect against index beyond capacity
        --if idx >= self.__capacity then return false end
        local size = rawget(self, "__size__")
        size = size + 1;
        rawset(self, "__size__", size)

        self.__impl[idx] = value
    end;

    __len = function(self)
        return self.__size__
    end;

}

function Dictionary.new(self, cap)
    local obj = {
        __cap__ = cap;
        __size__ = 0;
        __impl = {};
	}
	
    --for i=1,cnt do
    --    obj.__impl[i]=false;
    --end
    setmetatable(obj, Array_mt)

    return obj
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


return {
    NULL = "null";
    MARK = "mark";
    Token = Token;
    TokenType = TokenType;

    Array = Array;
    Dictionary = Dictionary;

    deepCopy = deepCopy;
}
