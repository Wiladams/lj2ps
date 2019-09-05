-- metatable for enums
-- simply provides the 'reverse lookup' in a 
-- dictionary.  Make this the metatable whenever
-- you need such functionality.
local enum = {}
local enum_mt = {
    __index = function(tbl, value)
        --print("enum.__index: ", value)
        for key, code in pairs(tbl) do
            if code == value then 
                return key;
            end
        end

        return false;
    end;
}

setmetatable(enum, {
    __call = function(self, alist)
        local alist = alist or {}
        setmetatable(alist, enum_mt)
        return alist
    end,
})

--[[
function enum.init(self, alist)
    setmetatable(alist, enum_mt)

    return alist;
end

function enum.create(self, alist)
    local alist = alist or {}
    return self:init(alist);
end
--]]

return enum
