
local ps_common = require("lj2ps.ps_common")

local GraphicState = require("lj2ps.ps_graphicsstate")

local exports = {}

-- Graphics State - Device Independent
-- gsave
-- grestore
local function gsave(vm)
    vm.Driver:gSave()
    return true
end
exports.gsave = gsave

local function grestore(vm)
    vm.Driver:gRestore()
    return true
end
exports.grestore = grestore

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
    --print("setlinewidth: ", value)
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
local function setlinejoin(vm)
    local value = vm.OperandStack:pop()
    vm.Driver:setLineJoin(value)

    return true
end
exports.setlinejoin = setlinejoin

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
local function setgray(vm)
    local value = vm.OperandStack:pop()
    vm.Driver:setGray(value)

    return true
end
exports.setgray = setgray


-- sethsbcolor
-- currenthsbcolor
-- setrgbcolor
-- currentrgbcolor
local function setrgbcolor(vm)
    local b = vm.OperandStack:pop()
    local g = vm.OperandStack:pop()
    local r = vm.OperandStack:pop()

    vm.Driver:setRgbColor(r,g,b)

    return true
end
exports.setrgbcolor = setrgbcolor

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
--]]

-- Coordinate System and Matrix Operators
--matrix
--initmatrix
--identmatix
--defaultmatrix
--currentmatrix
--setmatrix
--translate
local function translate(vm)
    local ty = vm.OperandStack:pop()
    local tx = vm.OperandStack:pop()
    vm.Driver:translate(tx, ty)

    return true
end
exports.translate = translate

--scale
local function scale(vm)
    local sy = vm.OperandStack:pop()
    local sx = vm.OperandStack:pop()
    vm.Driver:scale(sx, sy)

    return true
end
exports.scale = scale

--rotate
local function rotate(vm)
    local angle = vm.OperandStack:pop()
    vm.Driver:rotate(angle)

    return true
end
exports.rotate = rotate

--concat
--concatmatrix
--tranform
--dtransform
--itransform
--idtransform
--invertmatrix


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
local function rlineto(vm)
    local dy = vm.OperandStack:pop()
    local dx = vm.OperandStack:pop()
    local curr = vm.Driver:getCurrentPosition()
    vm.Driver:moveTo(curr[1]+dx, curr[2]+dy)

    return true
end
exports.rlineto = rlineto

--lineto
--rlineto
local function lineto(vm)
    local y = vm.OperandStack:pop()
    local x = vm.OperandStack:pop()
    vm.Driver:lineTo(x, y)
    
    return true
end
exports.lineto = lineto


local function rlineto(vm)
    local dy = vm.OperandStack:pop()
    local dx = vm.OperandStack:pop()
    local curr = vm.Driver:getCurrentPosition()
    vm.Driver:lineTo(curr[1]+dx, curr[2]+dy)
    
    return true
end
exports.rlineto = rlineto

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
local function erasepage(vm)
    vm.Driver:erasepage()
    return true
end
exports.erasepage = erasepage

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
--]]

--definefont
--composefont
--undefinefont

--findfont
local function findfont(vm)
    local key = vm.OperandStack:pop()
    -- find font based on family name
    local face = vm.Driver:findFontFace(key)
    
    print("findfont, face: ", key, face)

    -- put that object on the stack
    if face then
        -- put the actual BLFaceCore object on the stack
        vm.OperandStack:push(face)
    else
        -- push an error on the stack
        vm.OperandStack:push(ps_common.NULL)
    end

    return true
end
exports.findfont = findfont


--scalefont
local function scalefont(vm)
    -- pop size off the stack
    local size = vm.OperandStack:pop()
    local face = vm.OperandStack:pop()

    local font = face:createFont(size)

    vm.OperandStack:push(font)
    vm.Driver:setFont(font)

    return true
end
exports.scalefont = scalefont

--makefont
--setfont
local function setfont(vm)
    local font = vm.OperandStack:pop()
    vm.Driver:setFont(font)

    return true
end
exports.setfont = setfont

--rootfont
--currentfont
--selectfont

--show
local function show(vm)
    local str = vm.OperandStack:pop()

    -- use the current point as location
    local pos = vm.Driver:getCurrentPosition()
    print("show: ", pos[1], pos[2], str)
    vm.Driver:show(pos, str)

    return true
end
exports.show = show

--ashow
--widthshow
--awidthshow
--xshow
--xyshow
--yshow
--glyphshow
--stringwidth
--cshow
--kshow

--FontDirectory
--GlobalFontDirectory
--StandardEncoding
--ISOLatin1Encoding

--findencoding
--setcachedevice
--setcachedevice2
--setcharwidth



return exports