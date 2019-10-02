
local ps_common = require("lj2ps.ps_common")
local Matrix = require("lj2ps.ps_matrix")

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
local function setmiterlimit(vm)
    local num = vm.OperandStack:pop()
    -- set the miter limit

    return true
end
exports.setmiterlimit = setmiterlimit


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
    https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
--]]
local function round(n)
    if n >= 0 then
        return math.floor(n+0.5)
    else
        return math.ceil(n-0.5)
    end
end

local function map255(val)
    return math.min(math.floor(val*256),255)
end

local function mapToRange(val, range)
    return math.min(math.floor(val*(range+1)),range)
end

--[[
        https://en.wikipedia.org/wiki/HSL_and_HSV
        'alternate' polynomial based implementation
]]
local function HSLToRGB(H,S,L)
    -- we want H in degrees
    H = mapToRange(H,360.0)

    local function fn(n)
        local k = math.fmod((n + H/30.0), 12)
        local a = S * math.min(L, 1.0 - L)

        return L - a * math.max(math.min(k-3.0, 9.0-k,1.0),-1.0)
    end

    local R1, G1, B1 = fn(0), fn(8), fn(4)


    --print("HSL, RGB: ", H, S, L, "     ", R, G, B)

    return R1, G1, B1
end

--[[
    h,s,v => [0..1]
    h - hue, is converted to degrees [0..360]
    https://en.wikipedia.org/wiki/HSL_and_HSV
]]
local function HSVToRGB(H,S,V)
    -- we want H in degrees
    H = mapToRange(H,360.0)

    -- figure out the chroma
    local C = V * S

    -- figure out RGB
    local H1 = H / 60.0
    local X = C * (1-math.abs(math.fmod(H1, 2)-1))

    local R1, G1, B1
    if H1 >= 0 and H1 <= 1 then R1,G1,B1 = C, X, 0 end
    if H1 > 1 and H1 <= 2 then R1, G1, B1 = X, C, 0 end
    if H1 > 2 and H1 <= 3 then R1, G1, B1 = 0, C, X end
    if H1 > 3 and H1 <= 4 then R1, G1, B1 = 0, X, C end
    if H1 > 4 and H1 <= 5 then R1, G1, B1 = X, 0, C end
    if H1 > 5 and H1 <= 6 then R1, G1, B1 = C, 0, X end

    local m = V - C

    local R = R1 + m
    local G = G1 + m
    local B = B1 + m

    --print("HSV, RGB: ", H, S, V, "     ", R, G, B)

    return R, G, B
end

local function sethsbcolor(vm)
    local brightness = vm.OperandStack:pop()
    local saturation = vm.OperandStack:pop()
    local hue = vm.OperandStack:pop()

    -- create an rgb color from the hsb values
    local r, g, b = HSVToRGB(hue, saturation, brightness)
    --local r, g, b = HSLToRGB(hue, saturation, brightness)
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
-- by default, create identity matrix and push 
-- it on the operand stack
local function matrix(vm)
    local m = Matrix:createIdentity()
    vm.OperandStack:push(m)

    return true
end
exports.matrix = matrix

--initmatrix

--identmatix
-- take whatever thing that's on the top
-- of the stack and give it identity matrix values
local function identmatrix(vm)
    local m = vm.OperandStack:pop()
    m[0]=1
    m[1]=0
    m[2]=0
    m[3]=1
    m[4]=0
    m[5]=0

    vm.OperandStack:push(m)

    return true
end
exports.identmatrix  =identmatrix

--defaultmatrix
--currentmatrix
local function currentmatrix(vm)
    local m = vm.Driver:currentMatrix()
    -- BUGBUG
    -- need to turn a blend2d matrix into a
    -- 6 element array
    vm.OperandStack:push(m)

    return true
end
exports.currentmatrix = currentmatrix

--setmatrix
local function setmatrix(vm)
    local m = vm.OperandStack:pop()

    vm.Driver:setMatrix(m)

    return true
end
exports.setmatrix = setmatrix

-- translate
--         tx ty translate -
--  tx ty matrix translate matrix
--
local function translate(vm)
    local tx, ty
    local m = vm.OperandStack:pop()

    if type(m) == "number" then
        -- change user coordinate space
        local ty = m
        local tx = vm.OperandStack:pop()
        vm.Driver:translate(tx, ty)
    else
        -- create a translation matrix and
        -- put it back on the stack
        local ty = vm.OperandStack:pop()
        local tx = vm.OperandStack:pop()
        local m1 = Matrix:createTranslation(tx, ty)

        vm.OperandStack:push(m1)
    end

    return true
end
exports.translate = translate

--scale
--        sx sy scale -
-- sx sy matrix scale matrix
local function scale(vm)
    local m = vm.OperandStack:pop()

    if type(m) == "number" then
        local sy = m
        local sx = vm.OperandStack:pop()
        vm.Driver:scale(sx, sy)
    else
        local sy = vm.OperandStack:pop()
        local sx = vm.OperandStack:pop()
        local m1 = Matrix:createScaling(sx, sy)

        vm.OperandStack:push(m1)
    end

    return true
end
exports.scale = scale

--rotate
--           angle rotate -
--    angle matrix rotate matrix
local function rotate(vm)
    local m = vm.OperandStack:pop()

    if type(m) == "number" then
        local angle = m

        vm.Driver:rotateBy(angle)
    else
        local angle = vm.OperandStack:pop()
        local m1 = Matrix:createRotation(angle)
        vm.OperandStack:push(m1)
    end
    
    return true
end
exports.rotate = rotate

-- concat
-- matrix concat
local function concat(vm)
    local m = vm.OperandStack:pop()
    m = Matrix:createFromArray(m)
    vm.Driver:concat(m)

    return true
end
exports.concat = concat

--concatmatrix
-- matrix1 matrix2 matrix3 concatmatrix matrix3
local function concatmatrix(vm)
    local m3 = Matrix:createFromArray(vm.OperandStack:pop())
    local m2 = Matrix:createFromArray(vm.OperandStack:pop())
    local m1 = Matrix:createFromArray(vm.OperandStack:pop())

    m3 = m1;
    m3:preMultiplyBy(m2);
    vm.OperandStack:push(m3)

    return true
end
exports.concatmatrix = concatmatrix

--transform
-- transform a single point
--        x y transform x1 y1
-- x y matrix transform x1 y1
local function transform(vm)
    local m = vm.OperandStack:pop()
    local x, y

    if type(m) == "number" then
        local y = m
        local x = vm.OperandStack:pop()

        local m1 = vm.Driver:currentMatrix();

        local x1, y1 = m1:transformPoint(x, y)

        vm.OperandStack:push(x1)
        vm.OperandStack:push(y1)
    else
        -- the matrix was given as a parameter
        -- get the inverse of it
        m = Matrix:createFromArray(m)
        local y = vm.OperandStack:pop()
        local x = vm.OperandStack:pop()

        local x1, y1 = m:transformPoint(x, y)

        vm.OperandStack:push(x1)
        vm.OperandStack:push(y1)
    end

    return true
end
exports.transform = transform

--dtransform
--itransform
local function itransform(vm)
    local arg1 = vm.OperandStack:pop()
    local x, y

    if type(arg1) == "number" then
        local y = arg1
        local x = vm.OperandStack:pop()

        local m = vm.Driver:currentMatrix();
        local m1 = m:createInverse();

        local x1, y1 = m1:transformPoint(x, y)

        vm.OperandStack:push(x1)
        vm.OperandStack:push(y1)
    else
        -- the matrix was given as a parameter
        -- get the inverse of it
        local m1 = Matrix:createFromArray(arg1)
        m1 = m1:createInverse();

        assert(m1 ~= nil)
        
        local y = vm.OperandStack:pop()
        local x = xm.OperandStack:pop()

        local x1, y1 = m1:transformPoint(x, y)

        vm.OperandStack:push(x1)
        vm.OperandStack:push(y1)
    end

    return true
end
exports.itransform = itransform

--idtransform
--invertmatrix
-- matrix1 matrix2 invertmatrix matrix2
local function invertmatrix(vm)
    local m2 = vm.OperandStack:pop()
    local m1 = vm.OperandStack:pop()

    -- make sure we have an actual matrix 
    -- and not just an array
    local matrix1 = Matrix:createFromArray(m1)
    
    --print("invertmatrix - matrix1")
    --print(matrix1)

    local m1inv = matrix1:createInverse()
    
    assert(m1inv ~= nil)

    vm.OperandStack:push(m1inv)
    
    return true
end
exports.invertmatrix = invertmatrix

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

local function lineto(vm)
    local y = vm.OperandStack:pop()
    local x = vm.OperandStack:pop()
    vm.Driver:lineTo(x, y)
    
    return true
end
exports.lineto = lineto

--rlineto
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
local function arct(vm)
    local r = vm.OperandStack:pop()
    local y2 = vm.OperandStack:pop()
    local x2 = vm.OperandStack:pop()
    local y1 = vm.OperandStack:pop()
    local x1 = vm.OperandStack:pop()

    vm.Driver:arct(x1, y1, x2,y2, r)

    return true
end
exports.arct = arct

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
-- string  bool  charpath -
local function charpath(vm)
    local abool = vm.OperandStack:pop()
    local str = vm.OperandStack:pop()
    
    -- use current font to get outline of string
    vm.Driver:charPath(str)

    return true
end
exports.charpath = charpath

--uappend

--clippath
local function clippath(vm)
    local cpath = vm.Driver:clipPath()
    vm.Driver:setPath(cpath)
    
    return true
end
exports.clippath = clippath

--setbbox

local function setbbox(vm)
    -- setclip based on specified
    -- rectangular bounds
    local ury = vm.OperandStack:pop()
    local urx = vm.OperandStack:pop()
    local lly = vm.OperandStack:pop()
    local llx = vm.OperandStack:pop()
    
    local w = urx-llx
    local h = ury-lly
    vm.Driver.DC:clipRectI(BLRectI(llx,lly,urx-llx, ury-lly))

    return true
end
exports.setbbox = setbbox

--pathbbox
-- pathbbox  llx  lly  urx  ury
local function pathbbox(vm)
    local x1,y1,x2,y2 = vm.Driver:pathBox()
    vm.OperandStack:push(x1)
    vm.OperandStack:push(y1)
    vm.OperandStack:push(x2)
    vm.OperandStack:push(y2)

    return true
end
exports.pathbbox = pathbbox

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
-- use even odd rule
local function eofill(vm)
    vm.Driver:fill()
    return true;
end
exports.eofill = eofill

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
    
    --print("findfont, face: ", key, face)

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

--setfont
local function selectfont(vm)
    -- findfont
    -- scalefont
    -- setfont
    local scale = vm.OperandStack:pop()
    local key = vm.OperandStack:pop()

    -- findfont
    local face = vm.Driver:findFontFace(key)
    
    -- scalefont
    local font = face:createFont(scale)
    
    -- setfont
    vm.Driver:setFont(font)

    return true
end
exports.selectfont = selectfont

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
--string  stringwidth  wx  wy
local function stringwidth(vm)
    local str = vm.OperandStack:pop()
    local wx, wy = vm.Driver:stringWidth(str)

    vm.OperandStack:push(wx)
    vm.OperandStack:push(wy)

    return true
end
exports.stringwidth = stringwidth

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