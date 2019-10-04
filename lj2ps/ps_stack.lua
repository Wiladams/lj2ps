local ps_common = require("lj2ps.ps_common")

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


--[[
    Operand stack operators
]]
function Stack.countToMark(self)
    local ct = 0

    for _, item in self:elements() do
        if item == ps_common.MARK then
            break
        end

        ct = ct + 1
    end

    return ct
end

-- pop all the items off the stack
function Stack.clear(self)
	local n = self:length()
	for i=1,n do 
		self:pop()
	end

	return self
end

function Stack.dup(self)
    if self:length() > 0 then
        self:push(self:top())
    end

    return self
end

-- exch
-- Same as: 2 1 roll
function Stack.exch(self)
    local a = self:pop()
    local b = self:pop()
    self:push(a)
    self:push(b)
end

function Stack.push(self, value)
	local last = self.last + 1
	self.last = last
	self[last] = value

	return self
end

-- push multiple elements onto the stack at once
function Stack.pushn(self, ...)
    local n = select('#',...)
    for i=1,n do
        self:push(select(i,...))
    end
    
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

function Stack.popn(self, n)
    local tmp = {}
    for i=1,n do
        tmp[n-i+1] = self:pop()
    end

    return unpack(tmp)
end

function Stack.copy(self, n)
    local sentinel = self.last

    for i=1,n do 
        self:push(self[sentinel-(n-i)])
    end

    return self
end

-- n is the number of items to consider
-- j is the number of positions to exchange
-- this is a brute force implementation which simply
-- does a single rotation as many times as is needed
-- a more direct approach would be to calculate the 
-- new position of each element and use swaps to put
-- them in place
function Stack.roll(self,n,j)
    
    if j > 0 then   -- roll the stack up (counter clockwise)
        for i=1,j do
            local tmp = self:top()

            for i=1,n-1 do
                local dst = self.last-(i-1)
                local src = self.last-i
                self[dst] = self[src]
            end

            self[self.last-n+1] = tmp
        end  --  outer loop
    elseif j < 0 then   -- roll the stack 'down' (clockwise)
        for i=1,math.abs(j) do
            local tmp = self[self.last-(n-1)]

            for i=1,n-1 do
                local dst = self.last-(n-1)+i-1
                local src = self.last-(n-1)+i
                self[dst] = self[src]
            end

            self[self.last] = tmp
        end  --  outer loop
    end

    return self
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
--[[
    return non-destructive iterator of elements
]]
function Stack.elements(self)
	local function gen(param, state)
		if param.first > state then
			return nil;
		end

		return state-1, param.data[state]
	end

	return gen, {first = self.first, data=self}, self.last
end

return Stack