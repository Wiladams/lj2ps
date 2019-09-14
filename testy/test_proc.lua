package.path = "../?.lua;"..package.path


local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")

local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter

local function test_var()
interp:run([[
/ppi 72 def
10 ppi mul
pstack
]])
end

local function test_proc()
interp:run([[
/inch {
  72 mul
}  def
5 inch
pstack
]])
end

-- Draw three overlapping boxes
local function test_boxes()
interp:run([[
/box {
    72 0 rlineto
    0 72 rlineto
    -72 0 rlineto
    closepath
} def

% ---- Begin Program
% First Box
newpath
252 324 moveto
box
0 0 0  setrgbcolor
fill

% Second Box
newpath
270 360 moveto
box
0.4 0.4 0.4 0.8 setrgbacolor
fill

% Third Program
newpath
288 396 moveto
box
0.8 0.4 setgraya
fill

showpage
]])
end

--test_var()
--test_proc()
test_boxes()
