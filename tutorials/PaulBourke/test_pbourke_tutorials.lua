package.path = "../?.lua;"..package.path

--[[
http://paulbourke.net/dataformats/postscript/
--]]


local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")

local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter

local function test_example1()
    interp:run([[
%!
%% Example 1

newpath
100 200 moveto
200 250 lineto
100 300 lineto
closepath
2 setlinewidth
stroke
showpage
]])
end

local function test_example2()
    interp:run([[
%!
%% Example 2

newpath
100 200 moveto
200 250 lineto
100 300 lineto
closepath
gsave
0.5 setgray
fill
grestore
4 setlinewidth
0.75 setgray
stroke
showpage
]])
end

local function test_example3()
interp:run([[
%!
%% Example 3

/Tahoma findfont
72 scalefont
setfont

newpath
100 200 moveto
(Example 3) show

showpage
]])

    return true
end

local function test_example3()
    interp:run([[
    %!
    %% Example 4
    
    /Tahoma findfont
    72 scalefont
    setfont
    
    100 200 translate
    45 rotate
    2 1 scale
    
    newpath
    0 0 moveto
    (Example 4) true charpath
    0.5 setlinewidth
    0.4 setgray
    stroke

    showpage
]])
    
    return true
end

local function test_example5()
    interp:run([[
%!
%% Example 5

newpath
100 100 moveto
0 100 rlineto
100 0 rlineto
0 -100 rlineto
-100 0 rlineto
closepath
gsave
0.5 1 0.5 setrgbcolor
fill
grestore
1 0 0 setrgbcolor
4 setlinewidth
stroke
showpage
]])
end

local function test_example9()
    interp:run([[
%!
%%Example 9
100 200 translate
26 34 scale
26 34 8 [26 0 0 -34 0 34]
{<
ffffffffffffffffffffffffffffffffffffffffffffffffffff
ff000000000000000000000000000000000000ffffffffffffff
ff00efefefefefefefefefefefefefefefef0000ffffffffffff
ff00efefefefefefefefefefefefefefefef00ce00ffffffffff
ff00efefefefefefefefefefefefefefefef00cece00ffffffff
ff00efefefefefefefefefefefefefefefef00cecece00ffffff
ff00efefefefefefefefefefefefefefefef00cececece00ffff
ff00efefefefefefefefefefefefefefefef00000000000000ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efef000000ef000000ef000000ef0000ef0000efefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efef000000ef00000000ef00000000ef000000efefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efef0000ef00000000000000ef000000ef0000efefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff00efefefefefefefefefefefefefefefefefefefefefef00ff
ff000000000000000000000000000000000000000000000000ff
ffffffffffffffffffffffffffffffffffffffffffffffffffff
>}
image
showpage
]])

end



--test_example1()
--test_example2()
test_example3()
--test_example5()
--test_example6()
--test_example7()
--test_example8()
--test_example9()

