--[[
    Virtual machine for Postscript

    This object represents the Postscript "machine",
    which is the execution model for the Postscript interpreter.
    The machine is the organization point for things like the 
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
local Blend2DDriver = require("lj2ps.b2ddriver")

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

function PSVM.new(self, obj)
    obj = obj or {
        OperandStack = Stack();
        ExecutionStack = Stack();
        DictionaryStack = DictionaryStack();

        GraphicsStack = Stack();
        ClippingPathStack = Stack();

        Driver = Blend2DDriver();
    }

    obj.OperandStack = obj.OperandStack or Stack()
    obj.ExecutionStack = obj.ExecutionStack or Stack()
    obj.DictionaryStack = obj.DictionaryStack or DictionaryStack()
    obj.GraphicsStack = obj.GraphicsStack or Stack()
    obj.ClippingPathStack = obj.ClippingPathStack or Stack()
    obj.Driver = obj.Driver or Blend2DDriver()
    
    setmetatable(obj, PSVM_mt)

    -- setup system dictionary
    ops["true"] = true
    ops["false"] = false
    obj.DictionaryStack:pushDictionary(ops)     -- systemdict, should contain system operators
    obj.DictionaryStack:pushDictionary(gops)     -- graphics operators
    
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


--[[
    Given an executable array, go through and start executing
    the elements of that array.  

    Currently, putting elementary types on the stack, calling ops
    and calling procedures will work.
]]
function PSVM.execArray(self, arr)
    --print("EXEC EXECUTABLE ARRAY: ", #arr)
    --print("--- stack ---")
    --self.Vm:pstack()
    --print("----")

    for i=1,#arr do
        local value = arr[i]
        --print(value)

        -- lookup the name
        -- BUGBUG, need to distinguish between literal things
        -- and executable things.  We can do it for tables
        -- but not for strings.  Relying on the dictionary won't
        -- allow for things like redefining a stored variable
        local op = self.DictionaryStack:load(value)

        if op then
            if type(op) == "function" then
                -- it's an operator, so call the function
                op(self)
            elseif type(op) == "table" then
                -- handle a bit of 'recursion'
                -- if the thing is an executable array
                -- then call it
                if op.isExecutable then
                    self:execArray(value)
                end
            else
                self.Vm.OperandStack:push(value)
            end
        else
            self.OperandStack:push(value)
        end
    end
end




return PSVM
