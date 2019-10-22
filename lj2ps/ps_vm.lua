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
local TokenType = ps_common.TokenType
local Token = ps_common.Token

local ops = require("lj2ps.ps_operators")
local gops = require("lj2ps.ps_graph_operators")
local fops = require("lj2ps.ps_operators_file")

local Stack = require("lj2ps.ps_stack")
local DictionaryStack = require("lj2ps.ps_dictstack")

local Blend2DDriver = require("lj2ps.b2ddriver")
local Scanner = require("lj2ps.ps_scanner")
local octetstream = require("lj2ps.octetstream")


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
---[[
    -- endArray
        -- Next, use the DictionaryStack to determine the name of
        -- something
        if ops[name] then
            local func = function() return ops[name](self) end
            return func
        end
--]]
    end;
}

function PSVM.new(self, obj)
    obj = obj or {
        OperandStack = Stack();
        ExecutionStack = Stack();
        DictionaryStack = DictionaryStack();

        GraphicsStack = Stack();
        ClippingPathStack = Stack();

        -- Internal stuff
        buildProcDepth = 0;
    }

    obj.buildProcDepth = 0
    obj.OperandStack = obj.OperandStack or Stack()
    obj.ExecutionStack = obj.ExecutionStack or Stack()
    obj.DictionaryStack = obj.DictionaryStack or DictionaryStack()
    obj.GraphicsStack = obj.GraphicsStack or Stack()
    obj.ClippingPathStack = obj.ClippingPathStack or Stack()
    obj.Driver = obj.Driver or Blend2DDriver({dpi=obj.dpi or 192, VM = obj})
    
    setmetatable(obj, PSVM_mt)

    -- setup system dictionary
    ops["true"] = true
    ops["false"] = false
    ops["QUIET"] = true

    -- obj.systemdict = {}
    -- stuff all the operators into the systemdict
    obj.DictionaryStack:pushDictionary(ops)     -- systemdict, should contain system operators
    obj.DictionaryStack:pushDictionary(gops)     -- graphics operators
    obj.DictionaryStack:pushDictionary(fops)    -- file operators

    obj.userdict = {}
    obj.globaldict = {}

    obj.DictionaryStack:pushDictionary(obj.globaldict)      -- globaldict
    obj.DictionaryStack:pushDictionary(obj.userdict)      -- userdict

    -- Mark the dictionary stack so that if we do a clear
    -- we can stop at the mark
    obj.DictionaryStack:mark()


    return obj
end

--[[
    Built-in functions, NOT operators
]]

function PSVM.beginProc(self)
    self.OperandStack:push(ps_common.MARK)
    self.buildProcDepth = self.buildProcDepth + 1
end

function PSVM.endProc(self)
    --self:pstack()
    self:endArray()
    local arr = self.OperandStack:pop()
    arr.isExecutable = true;
    self.buildProcDepth = self.buildProcDepth - 1

    return arr
end

function PSVM.isBuildingProc(self)
    return self.buildProcDepth > 0
end

function PSVM.execName(self, name)
    -- lookup the name
    local op = self.DictionaryStack:load(name)
    local otype = type(op)
    --print("PSVM.execName: ", name, op, otype)
    --print("PSVM.execName: ", name, op)
    --print("PSVM.execName: ", name)

    -- op can either be one of the literal types
    -- bool, number, string, null
    -- or it's a table or function
    -- if it's a table, we need to check whether it's a procedure
    -- or an array
    if op ~= nil then
        if otype == "boolean" or
            otype == "number" or
            otype == "string" then
            self.OperandStack:push(op)
        elseif otype == "cdata" then
            self.OperandStack:push(op)
        elseif otype == "function" then
            -- it's a function operator, so execute it
            op(self)
        elseif type(op) == "table" then
            if op.isExecutable then
                -- it's a procedure, so run the procedure
                self:execArray(op)
            else
                -- it's just a normal array, or dictionary, so put it on the stack
                --print("REGULAR ARRAY")
                self.OperandStack:push(op)
            end
        else
            print("UNKNOWN EXECUTABLE TYPE: ", name, otype)
            --print("PUSH EXECUTABLE_NAME: ", token.value, op)
            --self.Vm.OperandStack:push(op)
        end
    else
        print("UNKNOWN EXECUTABLE_NAME: ", name)
    end

    return true
end


--[[
    Given an executable array, go through and start executing
    the elements of that array.  

    The elements within the array are the same as they were
    when the procedure was constructed.  All elements are
    token objects.
]]
function PSVM.execArray(self, arr)
    --print("== EXEC EXECUTABLE ARRAY: ==", arr, #arr)
    --print("--- stack ---")
    --self:pstack()
    --print("----")

    -- The array should be filled with tokens
    for i=0,#arr-1 do
        local value = arr[i]
        --print("  ARR: ", value, type(value))

        if value.kind then
            --print("KIND: ", TokenType[value.kind], value.value)

            if value.kind == TokenType.BOOLEAN or 
               value.kind == TokenType.NUMBER or
               value.kind == TokenType.STRING or
               value.kind == TokenType.HEXSTRING then
                -- BOOLEAN
                -- NUMBER
                -- STRING
                -- HEXSTRING
                self.OperandStack:push(value.value)
            elseif value.kind == TokenType.OPERATOR then
                -- it's a function pointer, so execute it
                value.value(self) 
            elseif  value.kind == TokenType.LITERAL_NAME then
                -- LITERAL_NAME
                self.OperandStack:push(value.value)
            elseif value.kind == TokenType.EXECUTABLE_NAME then
                -- EXECUTABLE_NAME
                self:execName(value.value)
            elseif value.kind == TokenType.LITERAL_ARRAY then
                -- LITERAL_ARRAY
                self.OperandStack:push(value.value)
            elseif value.kind == TokenType.PROCEDURE then
                -- PROCEDURE
                self.OperandStack:push(value.value)
            else
                print("execArray, UNKNOWN VALUE KIND: ", value.kind, value.value)
            end
        end
    end
end

-- binding an array, basically reconstructing a 
-- procedure binding ops to their actual functions
function PSVM.bindArray(self, arr)
    --print("BIND EXECUTABLE ARRAY: ", #arr)
    --print("--- stack ---")
    --self.Vm:pstack()
    --print("----")

    for i=0,#arr-1 do
        local tok = arr[i]
        --print("  PSVM.bindArray; ARR: ", type(tok), tok)

        if tok.kind then
            --print("bindArray, KIND: ", TokenType[tok.kind], tok.value)

            if tok.kind == TokenType.BOOLEAN or 
                tok.kind == TokenType.NUMBER or
                tok.kind == TokenType.STRING or
                tok.kind == TokenType.HEXSTRING then
                -- BOOLEAN
                -- NUMBER
                -- STRING
                -- HEXSTRING
                -- For these literals, just push the token back 
                -- on the operand stack
                self.OperandStack:push(tok)
            elseif  tok.kind == TokenType.LITERAL_NAME then
                -- LITERAL_NAME
                self.OperandStack:push(tok)
            elseif tok.kind == TokenType.EXECUTABLE_NAME then
                -- lookup the executable thing and put that on the stack
                local op = self.DictionaryStack:load(tok.value)
                if op and type(op) == "function" then
                    local functok = Token{kind = TokenType.OPERATOR, value=op}
                    self.OperandStack:push(functok)
                else
                    -- it's not a function, so just put the 
                    -- name back on the stack for later lookup
                    self.OperandStack:push(tok)
                end
            elseif tok.kind == TokenType.LITERAL_ARRAY then
                -- LITERAL_ARRAY
                self.OperandStack:push(tok)
            elseif tok.kind == TokenType.PROCEDURE then
                -- PROCEDURE
                -- put the procedure back on the stack
                self.OperandStack:push(tok)
            else
                print("BIND UNKNOWN VALUE KIND: ", value.kind, value.value)
            end
        end
    end
end


--[[
    Bind is more than just a simple optimization.  It
    allows you to lock in an implementation of an operator
    before the user introduces their own version of it.

    So, for example, when you have the following

    /bdef {bind def} bind def

    You are creating a procedure "bdef", and in this case, 
    we want to lock in the implementation of the 'bind' and 'def'
    operators within the procedure body.

    bind(), will replace the names 'bind' and 'def' with pointers
    to the actual operators.  This will do two things.
        1) Save on the lookup of the executable name when the
        procedure is actually executed
        2) Ensure we are using the base implementation of the operator
        rather than anything the user might replace it with later

    Functionally, we essentially create a new procedure body by 
    enumerating all the elements in the procedure that's on the top
    of the stack.  Then we put that new procedure on the top of the
    stack, ready for usage, typically a 'def' to save it in a variable.
]]
function PSVM.bind(self)
    --print("PSVM.BIND")
    -- pop executable array off of stack
    local arr = self.OperandStack:pop()

    self:beginProc()

    -- hand it to bind array
    self:bindArray(arr)
    
    -- put it back on the stack
    arr = self:endProc()

    self.OperandStack:push(arr)
end


function PSVM.runStream(self, bs)

    local scnr = Scanner(self, bs)

    -- Iterate through tokens
    for _, token in scnr:tokens(bs) do
        --print("INTERP: ", token.kind, token.value)
        if TokenType[token.kind] == nil then
            -- it's some other literal value type
            print("INTERP, UNKNOWN Token Kind: ", token.kind)
            --print("INTERP, push: ", TokenType[token.kind], token.value)
            --self.OperandStack:push(token.value)
        elseif token.kind == TokenType.EXECUTABLE_NAME then
            --print("  PSVM.runstream(self.Vm:execName): ", token.value)
            self:execName(token.value)
        else
            self.OperandStack:push(token.value)
        end
    end
end

function PSVM.eval(self, bs)
    if type(bs) == "string" then
        bs = octetstream(bs)
    end

    return self:runStream(bs)
end

function PSVM.runFile(self, filename)
    local f = io.open(filename, "r")
    if not f then
        error("PSVM.runFile, error: ", f, filename)
        --return nil, "file not opened: "..filename
    end

    local bytes = f:read("*a")
    f:close()
    local bs = octetstream(bytes)
    self.CurrentFile = bs

    return self:runStream(bs)
end



return PSVM
