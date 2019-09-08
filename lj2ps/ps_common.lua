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
	Stack
--]]
local Stack = {}
setmetatable(Stack,{
	__call = function(self, ...)
		return self:new(...);
	end,
});

local Stack_mt = {
	__len = function(self)
		return self:length()
	end,

	__index = Stack;
}

function Stack.new(self, obj)
	obj = obj or {first=1, last=0}

	setmetatable(obj, Stack_mt);

	return obj;
end

function Stack.length(self)
	return self.last - self.first+1
end


-- pop all the items off the stack
function Stack.clear(self)
	local n = self:length()
	for i=1,n do 
		self:pop()
	end

	return self
end

function Stack.push(self, value)
	local last = self.last + 1
	self.last = last
	self[last] = value

	return self
end

function Stack.pop(self)
	local last = self.last
	if self.first > last then
		return nil, "list is empty"
	end
	local value = self[last]
	self[last] = nil         -- to allow garbage collection
	self.last = last - 1

	return value
end

function Stack.top(self)
	-- return what's at the top of the stack without
	-- popping it off
	local last = self.last
	if self.first > last then
		return nil, "list is empty"
	end

	return self[last]
end

-- BUGBUG
-- need to do error checking
function Stack.nth(self, n)
	if n < 0 then return nil end

	local last = self.last
	local idx = last - n
	if idx < self.first then return nil, 'beyond end of stack' end
	
	return self[idx]
end

-- iterate the stack items non-destructively
function Stack.items(self)
	local function gen(param, state)
		if param.first > state then
			return nil;
		end

		return state-1, param.data[state]
	end

	return gen, {first = self.first, data=self}, self.last
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
    NULL = "NULL";
    MARK = "MARK";
    Token = Token;
    TokenType = TokenType;

    Array = Array;
    Dictionary = Dictionary;
    Stack = Stack;
    
    deepCopy = deepCopy;
}
