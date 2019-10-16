--[[
    Operators related to files
]]
local octetstream = require("lj2ps.octetstream")
local exports = {}

-- file
-- filename access file file
local function file(vm)
    local access = vm.OperandStack:pop()
    local filename = vm.OperandStack:pop()

    -- construct an octetstream based on filename
    -- and intended access
    local f = io.open(filename, "r")
    assert(f ~= nil)
    local bytes = f:read("*a")
    f:close()

    local bs = octetstream(bytes)
    assert(bs ~= nil)

    vm.OperandStack:push(bs)

    return true
end
exports.file = file

-- closefile
-- file closefile -
local function closefile(vm)
    local f = vm.OperandStack:pop()
    
    -- closing the file won't do much at the moment

    return true
end
exports.closefile = closefile

-- read
--   file read int true
--   file read false
local function read(vm)
    local f = vm.OperandStack:pop()
    if f:isEOF() then
        vm.OperandStack:push(false)
    else
        local c, err = vm.OperandStack:readOctet()
        if c then
            vm.OperandStack:push(c)
            vm.OperandStack:push(true)
        else
            vm.OperandStack:push(false)
        end
    end

    return true
end
exports.read = read

-- write
--   file int write -
local function write(vm)
    local c = vm.OperandStack:pop()
    local f = vm.OperandStack:pop()
    
    f:writeOctet(f)

    return true
end
exports.write = write

-- readhexstring
-- writehexstring

-- readstring
--   file string readstring substring bool
local function readstring(vm)
    local str = vm.OperandStack:pop()
    local src = vm.OperandStack:pop()
    local n = str.capacity

    str:reset()

    local offset = 0
    while (not src:isEOF()) and offset < n do
        local c, err = src:readOctet()
        str[offset] = c
        offset = offset + 1
    end

    vm.OperandStack:push(str)
    vm.OperandStack:push(not src:isEOF())
    
    return true
end
exports.readstring = readstring

-- writestring

-- readline
--   file string readline substring bool
local function readline(vm)
    local CR = string.byte("\r")
    local LF = string.byte("\n")
    local sawnewline = false

    local str = vm.OperandStack:pop()
    local src = vm.OperandStack:pop()
    local n = str.capacity
--print("length: ", n, str.capacity)
--print("stream, remaining: ", src:remaining())
    -- reset the string before usage
    str:reset()

    local offset = 0;
    while (not src:isEOF()) and offset < n do
        --print("WHILE")
        local c = src:peekOctet()
        --print(c, string.char(c))
        if (c == CR) then
            if src:peekOctet(1) == LF then
                sawnewline = true
                src:skip(2)
                break
            end
        elseif c == LF then
            sawnewline = true
            src:skip(1)
            break
        end

        src:skip(1)
        str[offset] = c
        offset = offset + 1
    end

    vm.OperandStack:push(str)
    vm.OperandStack:push(sawnewline)

    return true
end
exports.readline = readline

-- token

-- bytesavailable
--    file bytesavailable int
local function bytesavailable(vm)
    local f = vm.OperandStack:pop()
    local n = f:remaining()

    vm.OperandStack:push(n)

    return true
end
exports.bytesavailable = bytesavailable

-- fileposition
--   file fileposition int
local function fileposition(vm)
    local f = vm.OperandStack:pop()
    local p = f:tell()
    vm.OperandStack:push(p)

    return true
end
exports.fileposition = fileposition

-- setfileposition
-- file int setfileposition -
local function setfileposition(vm)
    local n = vm.OperandStack:pop()
    local f = vm.OperandStack:pop()
    f:seekFromBeginning(n)

    return true
end

-- flushfile
--   file flushfile -
local function flushfile(vm)
    local f = vm.OperandStack:pop()

    return true
end
exports.flushfile = flushfile

-- flush

-- resetfile
local function resetfile(vm)
    local f = vm.OperandStack:pop()
    f:seekFromBeginning(0)

    return true
end
exports.resetfile = resetfile

-- status

-- run
--   filename run -
local function run(vm)
    local filename = vm.OperandStack:pop()
    vm:runFile(filename)
--[[
    local f = io.open(filename, "r")

    assert(f ~= nil)

    local bytes = f:read("*a")
    f:close()

    vm:eval(bytes)
--]]
    return true
end
exports.run = run

-- currentfile
--   - currentfile file
local function currentfile(vm)
end

return exports