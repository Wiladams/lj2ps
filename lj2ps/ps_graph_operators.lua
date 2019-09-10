
local GraphicState = require("lj2ps.ps_graphicsstate")

local exports = {}

-- Graphics State - Device Independent
-- gsave
-- grestore
-- grestoreall
-- initgraphics
-- gstate
local function gstate(vm)
    local gs = GraphicState();
    vm.OperandStack:push(gs)
    return true
end
exports.gstate = gstate

-- setgstate
-- currentgstate
-- setlinewidth
-- currentlinewidth
local function setlinewidth(vm)
    local value = vm.OperandStack:pop()
    print("setlinewidth: ", value)
    vm.Driver:setLineWidth(value)
    return true
end
exports.setlinewidth = setlinewidth

-- setlinecap
local function setlinecap(vm)
    local value = vm.OperandStack:pop()
    vm.Driver:setLineCap(value)
    
    return true
end
exports.setlinecap = setlinecap

-- currentlinecap
local function currentlinecap(vm)
    local value = vm.Driver:getLineCap()
    vm.OperandStack:push(value)
    return true
end
exports.currentlinecap = currentlinecap

-- setlinejoin
-- currentlinejoin
-- setmiterlimit
-- currentmiterlimit
-- setstrokeadjust
-- currentstrokeadjust
-- setdash
-- currentdash
-- setcolorspace
-- currentcolorspace
-- setcolor
-- currentcolor
-- setgray
-- currentgray
-- sethsbcolor
-- currenthsbcolor
-- setrgbcolor
-- currentrgbcolor
-- setcmykcolor
-- currentcmykcolor

--[[
-- Graphics State - Device Dependent
sethalftone
currenthalftone
setscreen
currentscreen
setcolorscreen
currentcolorscreen
settransfer
currenttransfer
setcolortransfer
currentcolortransfer
setblackgeneration
currentblackgeneration
setundercolorremoval
currentundercolorremoval
setcolorrendering
currentcolorrendering
setflat
currentflat
setoverprint
currentoverprint

-- Coordinate System and Matrix Operators
matrix
initmatrix
identmatix
defaultmatrix
currentmatrix
setmatrix
translate
scale
rotate
concat
concatmatrix
tranform
dtransform
itransform
idtransform
invertmatrix
--]]

--[[
-- Path construction
--]]
--newpath
local function newpath(vm)
    vm.Driver:newPath()
    return true
end
exports.newpath = newpath

--currentpoint
local function currentpoint(vm)
    -- get Position from current GraphState
    -- push x, y onto operand stack
    local pos = vm.Driver:getCurrentPosition()
    vm.OperandStack:push(pos[1])
    vm.OperandStack:push(pos[2])

    return true
end
exports.currentpoint = currentpoint

--moveto
local function moveto(vm)
    local y = vm.OperandStack:pop()
    local x = vm.OperandStack:pop()
    vm.Driver:moveTo(x, y)
    
    return true
end
exports.moveto = moveto

--rmoveto
--lineto
local function lineto(vm)
    local y = vm.OperandStack:pop()
    local x = vm.OperandStack:pop()
    vm.Driver:lineTo(x, y)
    
    return true
end
exports.lineto = lineto

--rlineto
--arc
--arcn
--arct
--arcto
--curveto
--rcurveto
local function closepath(vm)
    vm.Driver:closePath()
end
exports.closepath = closepath

--flattenpath
--reversepath
--strokepath
--ustrokepath
--charpath
--uappend
--clippath
--setbbox
--pathbbox
--pathforall
--upath
--initclip
--clip
--eoclip
--rectclip
--ucache


-- Painting Operators
--erasepage
--stroke
local function stroke(vm)
    vm.Driver:stroke()
    return true
end
exports.stroke = stroke

--fill
local function fill(vm)
    vm.Driver:fill()
    return true
end
exports.fill = fill

--eofill
--rectstroke
--rectfill
--ustroke
--ufill
--ueofill
--shfill

--[[
-- Form and Pattern Operators
--]]
--makepattern
--setpattern
--setpattern
--execform

--[[
-- Device Setup
-]]

--showpage
local function showpage(vm)
    vm.Driver:showPage()
end
exports.showpage = showpage

--copypage
--setpagedevice
--currentpagedevice
--nulldevice

--[[
-- font operators
definefont
composefont
undefinefont
findfont
scalefont
makefont
setfont
rootfont
currentfont
selectfont
show
ashow
widthshow
awidthshow
xshow
xyshow
yshow
glyphshow
stringwidth
cshow
kshow

FontDirectory
GlobalFontDirectory
StandardEncoding
ISOLatin1Encoding

findencoding
setcachedevice
setcachedevice2
setcharwidth
--]]


return exports