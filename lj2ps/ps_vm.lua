--[[
    Virtual machine for Postscript
]]

local collections = require("lj2ps.collections")
local Stack = collections.Stack

local ps_common = require("lj2ps.ps_common")
local ops = require("lj2ps.ps_operators")
local DictionaryStack = require("lj2ps.ps_dictstack")

-- has-a operand stack
-- has-a dictionary stack

local PSVM = {}
setmetatable(PSVM, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local PSVM_mt = {
    __index = function(self, name)
        --print("PSVM.__index: ", self, name)
        --  First, if it's one of our object methods
        -- use the PSVM defined methods
        if PSVM[name] then
            -- do the rawset so next time around, there won't be
            -- this indirection lookup.  This allows an object
            -- to absorb the function calls that it actually uses
            -- over time
            rawset(self, name, PSVM[name])
            return PSVM[name]
        end

        -- Next, use the DictionaryStack to determine the name of
        -- something
        if ops[name] then
            local func = function() return ops[name](self) end
            return func
        end
    end;
}

function PSVM.new(self, ...)
    local obj = {
        OperandStack = Stack();
        ExecutionStack = Stack();
        DictionaryStack = DictionaryStack();

        GraphicsStack = Stack();
        ClippingPathStack = Stack();
    }
    setmetatable(obj, PSVM_mt)

    obj.DictionaryStack:pushDictionary(ops)     -- systemdict, should contain system operators
    obj.DictionaryStack:pushDictionary({})      -- globaldict
    obj.DictionaryStack:pushDictionary({})      -- userdict

    return obj
end

-- push a value onto the operand stack
function PSVM.push(self, value)
    self.OperandStack:push(value)
    return true
end

function PSVM.pushStringLiteral(self, value)
    self.OperandStack:push(value)
    return true
end


-- Dictionary management
function PSVM.currentdict(self)
    local d = self.DictionaryStack:currentdict()
    if not d then
        self.OperandStack:push(ps_common.NULL)
    else
        self.OperandStack:push(d)
    end

    return true;
end

PSVM["BEGIN"] = function(self)
    -- pop the dictionary off the top of the 
    -- operand stack and make it the current dictionary
    -- by placing on top of dictionary stack
    local d = self.OperandStack:pop()
    self.DictionaryStack:pushDictionary(d)

    return true;
end

PSVM["END"] = function(self)
    -- simply pop the dictionary stack
    self.DictionaryStack:popDictionary()
end

-- def
-- key value def    Associate key with value in current dictionary
function PSVM.def(self)
    local value = self.OperandStack:pop()
    local key = self.OperandStack:pop()

    return self.DictionaryStack:def(key, value)
end

-- load
-- key load value        search stack for key, place value on operand stack
function PSVM.load(self)
    local key = self.OperandStack:pop()
    local value = self.DictionaryStack:load(key)
    if not value then
        self.OperandStack:push(ps_common.NULL)
    else
        self.OperandStack:push(value)
    end

    return true
end

-- key value store -
-- Replace topmost definition of key
function PSVM.store(self)
    local value = self.OperandStack:pop()
    local key = self.OperandStack:pop()

    return self.DictionaryStack:store(key, value)
end

function PSVM.where(self)
    local key = self.OperandStack:pop()
    local d = self.DictionaryStack:where(key)
    if not d then
        self.OperandStack:push(false)
    else
        self.OperandStack:push(d)
        self.OperandStack:push(true)
    end

    return true
end



return PSVM
