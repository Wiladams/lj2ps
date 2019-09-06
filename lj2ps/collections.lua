--[[
	Collections.lua

	This file contains a few collection classes that are
	useful for many things.  The most basic object is the
	simple list.

	From the list is implemented a queue
--]]
local setmetatable = setmetatable;

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
        return self.__impl[idx+1]
    end;

	-- user trying to set a value
	__newindex = function(self, idx, value)
		idx = tonumber(idx)

		-- protect against non-numeric index
		if not idx then return false end

		-- protect against index beyond capacity
        if idx >= self.__capacity then return false end

        self.__impl[idx+1] = value
    end;

    __len = function(self)
        return self.__capacity
    end;
}

function Array.new(self, cnt)
    local obj = {
        __capacity = cnt;
        __impl = {};
	}
	
    --for i=1,cnt do
    --    obj.__impl[i]=false;
    --end
    setmetatable(obj, Array_mt)

    return obj
end

--[[
	A bag behaves similar to a dictionary.
	You can add values to it using simple array indexing
	You can also retrieve values based on array indexing
	The one addition is the '#' length operator works
--]]
local Bag = {}
setmetatable(Bag, {
	__call = function(self, ...)
		return self:_new(...);
	end,
})

local Bag_mt = {
	__index = function(self, key)
		--print("__index: ", key)
		return self.tbl[key]
	end,

	__newindex = function(self, key, value)		
		--print("__newindex: ", key, value)
		if value == nil then
			self.__Count = self.__Count - 1;
		else
			self.__Count = self.__Count + 1;
		end

		--rawset(self, key, value)
		self.tbl[key] = value;
	end,

	__len = function(self)
--		print("__len: ", self.__Count)
		return self.__Count;
	end,

	__pairs = function(self)
		return pairs(self.tbl)
	end,
}

function Bag._new(self, obj)
	local obj = {
		tbl = {},
		__Count = 0,
	}

	setmetatable(obj, Bag_mt);

	return obj;
end


-- The basic list type
-- This will be used to implement queues and other things
local List = {}
local List_mt = {
	__index = List;
}

function List.new(params)
	local obj = params or {first=0, last=-1}

	setmetatable(obj, List_mt)

	return obj
end

function List:reset()
	self.first = 0;
	self.last = -1;
	return self
end

function List:PushLeft (value)
	local first = self.first - 1
	self.first = first
	self[first] = value
end

function List:PushRight(value)
	local last = self.last + 1
	self.last = last
	self[last] = value
end

function List:PopLeft()
	local first = self.first

	if first > self.last then
		return nil, "list is empty"
	end
	local value = self[first]
	self[first] = nil        -- to allow garbage collection
	self.first = first + 1

	return value
end

function List:PopRight()
	local last = self.last
	if self.first > last then
		return nil, "list is empty"
	end
	local value = self[last]
	self[last] = nil         -- to allow garbage collection
	self.last = last - 1

	return value
end

function  List:PeekRight()
	local last = self.last
	if self.first > last then
		return nil, "list is empty"
	end

	return self[last]
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
	
	return self[last]
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

return {
	Array = Array;
	Bag = Bag;
	List = List;
	Stack = Stack;
}

