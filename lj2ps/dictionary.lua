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
        --print("__index: ", idx)
		if type(idx) == "string" then
			if idx == "kind" then
				return 'dictionary'
			end
		end
		
        return self.__impl[idx]
    end;

	-- user trying to set a value
    __newindex = function(self, idx, value)
        --print("__newindex: ", idx, value)
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
        --print("__len")
        return self.__size__
    end;

}

function Dictionary.new(self, cap)
    local obj = {
        __cap__ = cap or 499;
        __size__ = 0;
        __impl = {};
	}
	
    setmetatable(obj, Dictionary_mt)

    return obj
end

return Dictionary