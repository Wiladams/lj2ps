
local Scanner = require("lj2ps.ps_scanner")
local octetstream = require("lj2ps.octetstream")
local ps_common = require("lj2ps.ps_common")
local TokenType = ps_common.TokenType


local Interpreter = {}
setmetatable(Interpreter, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local Interpreter_mt  = {
    __index = Interpreter
}

function Interpreter.new(self, vm)
    local obj = {
        Vm = vm;
    }
    setmetatable(obj, Interpreter_mt)

    return obj
end

function Interpreter.createFromString(self, vm, input)
    local bs = octetstream(input)
    return Interpreter:new(vm, bs)
end

--[[
    Instance Methods
]]

function Interpreter.execName(self, name)
    -- lookup the name
    local op = self.Vm.DictionaryStack:load(name)

    -- op can either be one of the literal types
    -- bool, number, string, null
    -- or it's a table or function
    -- if it's a table, we need to check whether it's a procedure
    -- or an array
    if op then
        if type(op) == "function" then
            -- it's a function operator, so execute it
            op(self.Vm)
        elseif type(op) == "table" then
            if op.isExecutable then
                -- it's a procedure, so run the procedure
                self.Vm:execArray(op)
            else
                -- it's just a normal array, so put it on the stack
                --print("REGULAR ARRAY")
                self.Vm.OperandStack:push(op)
            end
        else
            --print("PUSH EXECUTABLE_NAME: ", token.value, op)
            self.Vm.OperandStack:push(op)
        end
    else
        print("UNKNOWN EXECUTABLE_NAME: ", name)
    end
end

-- bs - type can be either 'string' or 'ectetstream' (table)
function Interpreter.runStream(self, bs)

    local scnr = Scanner(self.Vm, bs)

    -- Iterate through tokens
    for _, token in scnr:tokens(bs) do
        --print("INTERP: ", token)
        
        if token.kind == TokenType.LITERAL_NAME then
            -- defining a name with '/name'
            self.Vm.OperandStack:push(token.value)
        elseif token.kind == TokenType.EXECUTABLE_NAME then
            self:execName(token.value)
        elseif token.kind == TokenType.LITERAL_ARRAY then
            self.Vm.OperandStack:push(token.value)
        elseif token.kind == TokenType.PROCEDURE then
            -- pure procedure definition, push it on the stack
            -- probably saving for a bind or control flow or looping
            self.Vm.OperandStack:push(token.value)
        else
            -- it's some other literal value type
            --print("INTERP, push: ", TokenType[token.kind], token.value)
            self.Vm.OperandStack:push(token.value)
        end

        --print("--- stack ---")
        --self.Vm:pstack()
        --print("-----")
    end
end

function Interpreter.run(self, bs)
    if type(bs) == "string" then
        bs = octetstream(bs)
    end

    return self:runStream(bs)
end

return Interpreter
