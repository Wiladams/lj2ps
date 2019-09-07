
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

-- setlinecap
local function setlinecap(vm)
    local value = vm.OperandStack:pop()
    vm.GraphicsState:setLineCap(value)
    
    return true
end
exports.setlinecap = setlinecap

-- currentlinecap
local function currentlinecap(vm)
    local value = vm.GraphicsState:getLineCap()
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
--currentpoint
--moveto
--rmoveto
--lineto
--rlineto
--arc
--arcn
--arct
--arcto
--curveto
--rcurveto
--closepath
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
--fill
--eofill
--rectstroke
--rectfill
--ustroke
--ufill
--ueofill
--shfill

--[[
-- Form and Pattern Operators
makepattern
setpattern
setpattern
execform

-- Device Setup
showpage
copypage
setpagedevice
currentpagedevice
nulldevice

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