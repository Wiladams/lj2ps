
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

-- bs - type can be either 'string' or 'ectetstream' (table)
function Interpreter.run(self, bs)
    if type(bs) == "string" then
        bs = octetstream(bs)
    end

    local scnr = Scanner(self.Vm, bs)
    for _, token in scnr:tokens(bs) do
        --print("INTERP: ", token)
        
        if token.kind == TokenType.LITERAL_NAME then
            self.Vm:pushLiteralName(token.value)
        elseif token.kind == TokenType.EXECUTABLE_NAME then
            -- lookup the name
            local op = self.Vm.DictionaryStack:load(token.value)
            --print("EXECUTABLE_NAME, exec: ", token.value, op)

            -- if found, execute procedure
            if op then
                if type(op) == "function" then
                    op(self.Vm)
                else
                    -- BUGBUG, need to be more subtle and
                    -- look at whether it is an executable 
                    -- array or not
                    self.Vm.OperandStack:push(op)
                end
            end
        elseif token.kind = TokenType.EXECUTABLE_ARRAY then
            -- a procedure
            self.Vm:push(token.value)
        end
            self.Vm:push(token.value)
        end
        --print("--- stack ---")
        --self.Vm:pstack()
        --print("-----")
    end
end

return Interpreter
