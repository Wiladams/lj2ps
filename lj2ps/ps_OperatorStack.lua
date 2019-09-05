local collections = require("lj2ps.collections")
local stack = collections.Stack
local ops = require("lj2ps.ps_operators")

-- OperatorStack is a sub-class of stack
-- so it inherits push(), pop(), top()
local OperatorStack  = {}
setmetatable(OperatorStack, {
    __index = stack;

    __call = function(self, ...)
        return self:new(...)
    end;
})
local OperatorStack_mt = {
    __index = OperatorStack;
}

function OperatorStack.new(self,...)
    local obj = stack(...)
    setmetatable(obj, OperatorStack_mt)

    return obj
end

return OperatorStack
