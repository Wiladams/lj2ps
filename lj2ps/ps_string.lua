local ffi = require("ffi")

local PSString = {}
setmetatable(PSString, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
--PSString_ops = {}
local PSString_mt = {

    __index = function(self, idx)
        --print("PSString_mt.__index: ", idx)

        local num = tonumber(idx)
        if num then
            return self.__impl[num]
        end

        -- The index was not a number, so perform
        -- some function, or return some attribute

		if idx == "kind" then
			return 'string'
        elseif idx == "capacity" then
            return self.__attributes.capacity
        elseif idx == "reset" then
            -- BUGBUG
            -- maybe also zero things out?
            return function(self) self.__attributes.length = 0 end
        elseif idx == "length" then
            return function(self) return self.__attributes.length end
        elseif idx == "put" then
            return function(self, idx, byte) self[idx] = byte end
        elseif idx == "get" then
            return function(self, idx) return self[idx] end
        elseif idx == "getInterval" then
            return function(self, idx, count)
                -- guard against negative count, but all
                -- for an empty array
                count = math.min(count, self.__attributes.capacity-idx)
                if count < 0 then
                    return nil
                end

                -- Create a new array with capacity == count
                local arr = PSString(count)
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
                local count = math.min(#other, self.__attributes.capacity-offset)
                --print("PSString.putInterval, #: ", self:length(), offset, count)
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
            -- iterator over elements in string
            local function gen(param, state)
                --print("array.elements.gen: ", param, state, param:length())
                if state >= param.__attributes.length then
                    return nil
                end

                return state+1, param.__impl[state]
            end

            return function() return gen, self, 0 end
        end


        return nil
    end;


	-- user trying to set a value
	__newindex = function(self, idx, value)
        local num = tonumber(idx)
        --print("__newindex: ", idx, value, self.__attributes.capacity)
        -- if it's a number, then we'll set the value
        -- of the element at the index+1
        if num then
        	-- protect against index beyond capacity
            if num >= self.__attributes.capacity then 
                return false 
            end

            self.__impl[num] = value
            if num >= self.__attributes.length then
                --print("reset length: ", num+1)
                self.__attributes.length = num+1
            end
        else
            if idx == "isExecutable" then
                self.__attributes.isExecutable = value
            end
        end

        return true
    end;

    __len = function(self)
        --print("length: ", self.__attributes.length)
        return self.__attributes.length
    end;

    __tostring = function(self)
        local n = #self
        --print("PSString.__tostring: ", #self)
        
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

--[[
    PSString(count)
    PSString("string literal")
--]]
function PSString.new(self, param)
    if not param then return nil end

    local cnt = 0
    local copyParam = false

    if type(param) == "number" then
        cnt = param
    elseif type(param) == "string" then
        cnt = #param
        copyParam = true
    end

    local obj = {
        __impl = ffi.new("char[?]", cnt);
        __attributes = {
            capacity = cnt;
            length = 0;
            isExecutable = isExecutable;
        };
	}
    
    if copyParam then
        for i=1,cnt do
            obj.__impl[i-1] = string.byte(param:sub(i,i))
        end
        obj.__attributes.length = cnt
    end

    setmetatable(obj, PSString_mt)

    return obj
end

return PSString