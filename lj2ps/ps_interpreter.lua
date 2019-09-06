
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
        if token.kind == TokenType.LITERAL_NAME then
            self.Vm:pushLiteralName(token.value)
        else
            print(token)
        end
        print("-----")
        self.Vm:pstack()
        print("-----")
    end
end

return Interpreter
