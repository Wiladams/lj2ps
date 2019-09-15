package.path = "../?.lua;"..package.path


local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")

local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter

local filename = arg[1]

if not filename then
    error("must specify a postscript file to run")
end

-- load the file into a string
-- pass it to the interpreter
local f = io.open(filename, "r")
local bytes = f:read("*a")
f:close()

print("==== RUN SCRIPT ====")
interp:run(bytes)
print("==== FINISHED ====")