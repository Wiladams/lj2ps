--[[
    The operation of the dictionary stack is complex enough that
    a standalone object is warranted to deal with it.

    The dictionary stack deals with things like 
    Finding a key value in stack order
    Adding dictionaries to the stack
    removing dictionaries from the stack
    Setting a value somewhere in the stack
]]

local ps_common = require("lj2ps.ps_common")
local Stack = require("lj2ps.ps_stack")


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
        dicts = Stack()
    }
    setmetatable(obj, DictionaryStack_mt)

    return obj;
end

function DictionaryStack.mark(self)
    self.dicts:push(ps_common.MARK)
end

function DictionaryStack.clearToMark(self)
    while self.dicts:length() > 0 do 
        local item = self.dicts:pop()
        if item == ps_common.MARK then
            break
        end
    end
end

function DictionaryStack.pushDictionary(self, d)
    self.dicts:push(d)
end

function DictionaryStack.popDictionary(self, d)
    self.dicts:pop()
end

function DictionaryStack.currentdict(self)
    if self.dicts:top() == ps_common.MARK then
        return self.dicts:nth(1)
    end

    return self.dicts:top()
end

-- def
-- key value def
-- Associate key and value in current dictionary
function DictionaryStack.def(self, key, value)
    local current = self:currentdict()
    --print("DictionaryStack.def: ", key, value, current)
    current[key] = value
end

function DictionaryStack.load(self, key)
    -- search for which dictionary has the key
    -- in stack order
    local d, value = self:where(key)
    --print("Dictionary.load: ", key, d)

    -- if we didn't find the key, then return nil
    if not d then 
        return nil 
    end

    return value
end

function DictionaryStack.store(self, key, value)
    local d, v = self:where(key)
    if not d then
        d = self:currentdict()
    end

    d[key] = value

    return true
end

-- where
-- Search the dictionary stack for the first definition
-- of the specified key.
-- return the dictionary, and value if found
function DictionaryStack.where(self, key)
    for _, dict in self.dicts:elements() do 
        if type(dict) == "table" then
            local value = dict[key] 
            if value ~= nil then
                return dict, value
            end
        end
    end

    return nil
end

return DictionaryStack