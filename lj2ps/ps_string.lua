local ffi = require("ffi")

local PSString = {}
setmetatable(PSString, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local PSString_mt = {
--[=[
	-- using trying to retrieve a value
    __index = function(self, idx)
        --print("Array_mt.__index: ", idx)

        local num = tonumber(idx)
        if num then
            return self.__impl[num+1]
        end

        -- The index was not a number, so perform
        -- some function, or return some attribute

		if idx == "kind" then
			return 'array'
        elseif idx == "isExecutable" then
            return self.__attributes.isExecutable
        elseif idx == "capacity" then
            return self.__attributes.capacity
        elseif idx == "length" then
            return function(self) return self.capacity end
        elseif idx == "put" then
            return function(self, idx, any) self[idx] = any end
        elseif idx == "get" then
            return function(self, idx) return self[idx] end
        elseif idx == "getInterval" then
            return function(self, idx, count)
                -- guard against negative count, but all
                -- for an empty array
                count = math.min(count, self.capacity-idx)
                if count < 0 then
                    return nil
                end

                -- Create a new array with capacity == count
                local arr = Array(count)
                if count == 0 then
                    return arr
                end

                for nidx = 0, count-1 do
                    arr[nidx] = self[idx+nidx]
                end

                return arr
            end
        elseif idx == "putInterval" then
            return function(self, offset, other)
                local count = math.min(#other, self.capacity-offset)
                --print("Array.putInterval, #: ", self:length(), offset, count)
                if count < 1 then
                    return self
                end

                for i=0,count-1 do
                    local value = other[i]
                    --print("  ", value)
                    self[offset+i] = value;
                end

                return self
            end
        elseif idx == "elements" then
            -- iterator over elements in array
            local function gen(param, state)
                --print("array.elements.gen: ", param, state, param:length())
                if state >= param:length() then
                    return nil
                end

                return state+1, param[state]
            end

            return function() return gen, self, 0 end
        end


        return nil
    end;

	-- user trying to set a value
	__newindex = function(self, idx, value)
        local num = tonumber(idx)
        --print("__newindex: ", idx, value)
        -- if it's a number, then we'll set the value
        -- of the element at the index+1
        if num then
        	-- protect against index beyond capacity
            if num >= self.capacity then 
                return false 
            end

            self.__impl[num+1] = value
        else
            if idx == "isExecutable" then
                self.__attributes.isExecutable = value
            end
        end

        return true
    end;
--]=]
    __len = function(self)
        return self.attributes.length
    end;

    __tostring = function(self)
        local n = #self
        print("PSString.__tostring: ", #self)
        
        if n == 0 then
            return ""
        end

        return ffi.string(self.__impl, n)
    end;
}


--[[
 An array must have a given size to start
 It can be index using numeric values
 which start at 0 NOT 1
 You can access attributes using '.' notation

 Attributes
    capacity
    isExecutable

capacity is not changeable
isExecutable is either true or false
--]]

function PSString.new(self, cnt)
    if not cnt then return nil end
    if isExecutable == nil then isExecutable = false end

    local obj = {
        __impl = ffi.new("char[?]", cnt)
        __attributes = {
            capacity = cnt;
            length = 0;
            isExecutable = isExecutable;
        };
	}
	
    setmetatable(obj, PSString_mt)

    return obj
end

return PSString