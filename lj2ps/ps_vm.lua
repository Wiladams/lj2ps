--[[
    Virtual machine for Postscript

    This object represents that Postscript "machine"
    It is the organization point for things like the 
    various stacks, dictionaries, graphics connection
    and whatnot.

    You should be able to program against the VM directly
    and not just by going through the interpreter.  The
    interpreter simply uses a scanner and transforms the
    text of a postscript program into calls against this
    virtual machine.
]]

local ps_common = require("lj2ps.ps_common")
local Stack = ps_common.Stack

local ops = require("lj2ps.ps_operators")

local gops = require("lj2ps.ps_graph_operators")
local DictionaryStack = require("lj2ps.ps_dictstack")
local GraphicsState = require("lj2ps.ps_graphicsstate")


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

        GraphicsState = GraphicsState();
    }
    setmetatable(obj, PSVM_mt)

    obj.DictionaryStack:pushDictionary(ops)     -- systemdict, should contain system operators
    obj.DictionaryStack:pushDictionary({})      -- globaldict
    obj.DictionaryStack:pushDictionary({})      -- userdict

    return obj
end

--[[
    Built-in functions, NOT operators
]]
function PSVM.popTopAndPrint(vm)
    print(vm.OperandStack:pop())
end

-- push a value onto the operand stack
function PSVM.push(self, value)
    -- check the type of the value
    -- if it's a string, then look it up
    -- in the dictionary.  If what is found there
    -- is executable, then execute it, otherwise
    -- push the value onto the stack
    local dvalue = self.DictionaryStack:load(value)
    if dvalue then
        self.OperandStack:push(dvalue)
    else
        self.OperandStack:push(value)
    end

    return true
end

function PSVM.pushExecutableName(self, name)
end


function PSVM.pushLiteralName(self, value)
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

return PSVM
