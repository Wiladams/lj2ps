
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
local function setdash(vm)
    local offset = vm.OperandStack:pop()
    local arr = vm.OperandStack:pop()

    vm.Driver.CurrentState.Dash = {offset=offset, array=arr}

    return true
end
exports.setdash = setdash

local function currentdash(vm)
    local dsh = vm.Driver.CurrentState.Dash
    vm.OperandStack:push(dsh.array)
    vm.OperandStack:push(dsh.offset)

    return true
end
exports.currentdash = currentdash

-- setcolorspace
-- currentcolorspace
-- setcolor
-- currentcolor

-- setgray
-- currentgray
local function setgray(vm)
    local value = vm.OperandStack:pop()
    vm.Driver:setGraya(value)

    return true
end
exports.setgray = setgray

local function setgraya(vm)
    local a = vm.OperandStack:pop()
    local value = vm.OperandStack:pop()
    vm.Driver:setGraya(value, a)

    return true
end
exports.setgraya = setgraya

-- sethsbcolor
-- currenthsbcolor
-- hue  saturation  brightness  sethsbcolor  --
--[[
    HSVtoRGB

    h,s,v ==> [0..1]
--]]
local function HSVtoRGB(h, s, v)
    local function round(n)
        if n >= 0 then
            return math.floor(n+0.5)
        else
            return math.ceil(n-0.5)
        end
    end

    local r, g, b, i, f, p, q, t;

    i = math.floor(h * 6);
    f = h * 6 - i;
    p = v * (1 - s);
    q = v * (1 - f * s);
    t = v * (1 - (1 - f) * s);
    local case = i % 6
    
    if case == 0 then r, g, b = v, t, p
    elseif case == 1 then r, g, b = q, v, p 
    elseif case == 2 then r,g,b = p,v,t 
    elseif case == 3 then r,g,b = p,q,v
    elseif case == 4 then r,g,b = t,p,v
    elseif case == 5 then r, g, b = v, p, q;  end

    return round(r * 255), round(g * 255), round(b * 255)
end

local function sethsbcolor(vm)
    local brightness = vm.OperandStack:pop()
    local saturation = vm.OperandStack:pop()
    local hue = vm.OperandStack:pop()

    -- create an rgb color from the hsb values
    local r, g, b = HSVtoRGB(hue, saturation, brightness)
    --print("sethsbcolor: ", hue, saturation, brightness, r, g, b)

    vm.Driver:setRgbaColor(r,g,b,1.0)

    return true
end
exports.sethsbcolor = sethsbcolor

-- setrgbcolor
-- currentrgbcolor
local function setrgbcolor(vm)
    local b = vm.OperandStack:pop()
    local g = vm.OperandStack:pop()
    local r = vm.OperandStack:pop()

    vm.Driver:setRgbaColor(r,g,b,1.0)

    return true
end
exports.setrgbcolor = setrgbcolor

local function setrgbacolor(vm)
    local a = vm.OperandStack:pop()
    local b = vm.OperandStack:pop()
    local g = vm.OperandStack:pop()
    local r = vm.OperandStack:pop()

    vm.Driver:setRgbaColor(r,g,b, a)

    return true
end
exports.setrgbacolor = setrgbacolor

-- setcmykcolor
-- currentcmykcolor

--[[
-- Graphics State - Device Dependent
--]]
--sethalftone
--currenthalftone
--setscreen
--currentscreen
--setcolorscreen
--currentcolorscreen
--settransfer
--currenttransfer
--setcolortransfer
--currentcolortransfer
--setblackgeneration
--currentblackgeneration
--setundercolorremoval
--currentundercolorremoval
--setcolorrendering
--currentcolorrendering

--setflat
--currentflat
local function setflat(vm)
    local num = vm.OperandStack:pop()
    vm.Driver.CurrentState.Flat = num

    return true
end
exports.setflat = setflat

local function currentflat(vm)
    local num = vm.Driver.CurrentState.Flat;
    vm.OperandStack:push(num)

    return true
end
exports.currentflat = currentflat

--setoverprint
--currentoverprint


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
--transform
local function transform(vm)
    local y = vm.OperandStack:pop()
    local x = vm.OperandStack:pop()

    --print("transform: ", x, y)

    vm.OperandStack:push(x)
    vm.OperandStack:push(y)

    return true
end
exports.transform = transform

--dtransform
--itransform
local function itransform(vm)
    local y = vm.OperandStack:pop()
    local x = vm.OperandStack:pop()

    vm.OperandStack:push(x)
    vm.OperandStack:push(y)
end
exports.itransform = itransform

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
local function rmoveto(vm)
    local dy = vm.OperandStack:pop()
    local dx = vm.OperandStack:pop()
    local curr = vm.Driver:getCurrentPosition()
    vm.Driver:moveTo(curr[1]+dx, curr[2]+dy)

    return true
end
exports.rmoveto = rmoveto

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
local function arc(vm)
    local angle2 = vm.OperandStack:pop()
    local angle1 = vm.OperandStack:pop()
    local r = vm.OperandStack:pop()
    local y = vm.OperandStack:pop()
    local x = vm.OperandStack:pop()

    vm.Driver:arc(x, y, r, angle1, angle2)

    return true
end
exports.arc = arc

--arcn
local function arcn(vm)
    local angle2 = vm.OperandStack:pop()
    local angle1 = vm.OperandStack:pop()
    local r = vm.OperandStack:pop()
    local y = vm.OperandStack:pop()
    local x = vm.OperandStack:pop()

    local rangle1 = 360 - angle1
    local rangle2 = 360 - angle2

    vm.Driver:arc(x, y, r, rangle1, rangle2)

    return true
end
exports.arcn = arcn

--arct
--arcto

--curveto
--rcurveto
local function curveto(vm)
    local y3 = vm.OperandStack:pop()
    local x3 = vm.OperandStack:pop()
    local y2 = vm.OperandStack:pop()
    local x2 = vm.OperandStack:pop()
    local y1 = vm.OperandStack:pop()
    local x1 = vm.OperandStack:pop()

    vm.Driver:curveTo(x1, y1, x2, y2, x3, y3)

    return true
end
exports.curveto = curveto

local function rcurveto(vm)
    local dy3 = vm.OperandStack:pop()
    local dx3 = vm.OperandStack:pop()
    local dy2 = vm.OperandStack:pop()
    local dx2 = vm.OperandStack:pop()
    local dy1 = vm.OperandStack:pop()
    local dx1 = vm.OperandStack:pop()

    local curr = vm.Driver:getCurrentPosition()
    local x = curr[1]
    local y = curr[2]

    vm.Driver:curveTo(x+dx1, y+dy1, x+dx2, y+dy2, x+dx3, y+dy3)

    return true
end
exports.rcurveto = rcurveto

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
local function clippath(vm)
    return true
end
exports.clippath = clippath

--setbbox
--pathbbox
local function setbbox(vm)
    -- setclip based on specified
    -- rectangular bounds
    local ury = vm.OperandStack:pop()
    local urx = vm.OperandStack:pop()
    local lly = vm.OperandStack:pop()
    local llx = vm.OperandStack:pop()
    
    local w = urx-llx
    local h = ury-lly
    vm.Driver:clipRectI(BLRectI(llx,lly,urx-llx, ury-lly))

    return true
end
exports.setbbox = setbbox

--pathforall
--upath
--initclip
--clip
local function clip(vm)
    return true
end
exports.clip = clip

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
local function rectstroke(vm)
    local height = vm.OperandStack:pop()
    local width = vm.OperandStack:pop()
    local y = vm.OperandStack:pop()
    local x = vm.OperandStack:pop()

    vm.Driver:rectStroke(x,y,width,height)

    return true
end
exports.rectstroke = rectstroke

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
    --print("show: ", pos[1], pos[2], str)
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