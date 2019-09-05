local collections = require("lj2ps.collections")
local stack = collections.Stack

local DictionaryStack = {}
setmetatable(DictionaryStack, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local DictionaryStack_mt = {
    __index = DictionaryStack
}

function DictionaryStack.new(self, ...)
    local obj = {
        dicts = stack()
    }
    setmetatable(obj, DictionaryStack_mt)

    return obj;
end

function DictionaryStack.pushDictionary(self, d)
    self.dicts:push(d)
end

function DictionaryStack.popDictionary(self, d)
    self.dicts:pop()
end

function DictionaryStack.currentdict(self)
    return self.dicts:top()
end

-- def
-- key value def
-- Associate key and value in current dictionary
function DictionaryStack.def(self, key, value)
    rawset(self.dicts:top(), key, value)
end

function DictionaryStack.load(self, key)
    -- search for which dictionary has the key
    -- in stack order
    local d = self:where(key)
    
    -- if we didn't find the key, then return nil
    if not d then 
        return nil 
    end

    return d[key]
end

function DictionaryStack.store(self, key, value)
    local d = self:where(key)
    if not d then
        d = self:currentdict()
    end
    rawset(d, key, value)

    return true
end

-- where
-- return the dictionary within which key 
-- is defined
function DictionaryStack.where(self, key)
    for _, dict in self.dicts:items() do 
        if dict[key] then
            return dict
        end
    end

    return nil
end

return DictionaryStack