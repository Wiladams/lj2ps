
local ffi = require("ffi")
local C = ffi.C 

local b2d = require("blend2d.blend2d")

local FontMonger = require("lj2ps.fontmonger")
local ps_common = require("lj2ps.ps_common")
local Stack = ps_common.Stack


local ops = require("lj2ps.ps_operators")
local DictionaryStack = require("lj2ps.ps_dictstack")
local GraphicsState = require("lj2ps.ps_graphicsstate")


--[[
    This rendering context assumes it is being run within 
    the bestwin application.  As such, a DrawingContext
    object is available globally.
]]

local Blend2DDriver = {}
setmetatable(Blend2DDriver, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local Blend2DDriver_mt = {
    __index = Blend2DDriver
}

function Blend2DDriver.new(self, obj)
    obj = obj or {}

    obj.dpi = obj.dpi or 72
    obj.inchesWide = obj.inchesWide or 8.5
    obj.inchesHigh = obj.inchesHigh or 11

    obj.GraphicsStack = obj.GraphicsStack or Stack();
    obj.ClippingPathStack = obj.ClippingPathStack or Stack();
    obj.CurrentState = obj.CurrentState or GraphicsState();
    obj.StateStack = obj.StateStack or Stack();
    obj.FontMonger = obj.FontMonger or FontMonger:new();
    
    -- Drawing Context
    local w = obj.inchesWide * obj.dpi
    local h = obj.inchesHigh * obj.dpi

    obj.img = BLImage(w, h)   -- 8.5" x 11" @ dpi
    obj.DC, err = BLContext(obj.img)
    
    -- must do this stroke transform order so
    -- the stroke line thickness does not grow with the
    -- scaling factor, but only obeys the setLineWidth
    obj.DC:setStrokeTransformOrder(C.BL_STROKE_TRANSFORM_ORDER_BEFORE)

    -- set coordinate system for y at the bottom
    -- use the dpi to scale so that in user space, when
    -- the user specifies a number, 1 == 1/72 inches (points)
    local scalex = obj.dpi / 72
    local scaley = obj.dpi / 72
    --print("SCALE: ", scalex, scaley)
    obj.DC:scale(1, -1)
    obj.DC:translate(0,-h)
    obj.DC:scale(scalex,scaley)

    local cpath = BLPath()
    cpath:moveTo(0,0)
    cpath:lineTo(obj.inchesWide*72, 0)
    cpath:lineTo(obj.inchesWide*72, obj.inchesHigh*72)
    cpath:lineTo(0, obj.inchesHigh*72)
    cpath:close()
    obj.ClippingPath = cpath;

    -- we push from userToMeta so that this becomes
    -- the baseline transform
    -- Now when we push and pop other matrices, 
    -- they can apply to user space, and not affect the
    -- base transform
    --obj.DC:userToMeta()


    -- start with full white background
    obj.DC:setFillStyle(BLRgba32(0xFFFFFFFF));
    obj.DC:fillAll()


    setmetatable(obj, Blend2DDriver_mt)

    -- setup various state things
    obj:applyState(obj.CurrentState)

    return obj
end

function Blend2DDriver.applyState(self, state)
    self.CurrentState.Color = state.Color;
    self.DC:setFillStyle(state.Color);
    self.DC:setStrokeStyle(state.Color);

    self.CurrentState.Font = state.Font;
end

local fontAliases = {
    ["times-roman"] = "times new roman";
    ["helvetica"] = "arial";
    ["helvetica-boldoblique"] = "arial";
    ["palatino-italic"] = "palatino linotype";
}

local function substituteFontName(name)

    local newName = fontAliases[name:lower()]
    if newName then
        return newName
    end

    return name
end


function Blend2DDriver.findFontFace(self, name)
    local alias = substituteFontName(name)
    --print("Blend2DDriver.findFontFace, name, alias: ", name, alias)
    local fontinfo = self.FontMonger:getFace(alias, subfamily, true)

    print("Blend2DDriver.findFontFace, fontinfo: ", alias, fontinfo)

    if fontinfo then
        --print("fontinfo.face: ", fontinfo.face)
        return fontinfo.face 
    end

    return nil
end

function Blend2DDriver.setFont(self, font)
    self.CurrentState.Font = font;
end

function Blend2DDriver.gSave(self)
    -- use the DrawingContext to store most graphics state
    -- and save a copy of current path on stack
    -- clone current graphics state
    -- store it on the statestack
    self.DC:save()
    local clonedPath = BLPath()
    clonedPath:assignDeep(self.CurrentState.Path)
    self.StateStack:push(clonedPath)

    return true
end

function Blend2DDriver.gRestore(self)
    
    self.DC:restore()
    self.CurrentState.Path = self.StateStack:pop()
    

    return true
end


--[[
    Graphics State
]]

function Blend2DDriver.clipPath(self)
    return self.ClippingPath
end

-- setlinewidth
-- currentlinewidth
function Blend2DDriver.setLineWidth(self, value)
    --print("Blend2DDriver.setLineWidth: ", value)
    self.CurrentState.LineWidth = value
    self.DC:setStrokeWidth(value)
    return true
end


-- setlinecap
-- currentlinecap
--[[
0 - butt
1 - round
2 - square
--]]
local capMap = {
    [0] = 0;
    [1] = 2;
    [2] = 1;
}
function Blend2DDriver.setLineCap(self, value)
    --print("setLineCap: ", value, capMap[value])
    self.CurrentState.LineCap = value;
    self.DC:setStrokeStartCap(capMap[value])
    self.DC:setStrokeEndCap(capMap[value])

    return true
end

-- setlinejoin
-- currentlinejoin
--[[
    0 miter
    1 round
    2 bevel
]]
local joinMap = {
    [0] = 0;
    [1] = 4;
    [2] = 3;
}
function Blend2DDriver.setLineJoin(self, value)
    self.CurrentState.LineJoin = value
    self.DC:setStrokeJoin(joinMap[value])

    return true
end

-- setmiterlimit
-- currentmiterlimit
-- setstrokeadjust
-- currentstrokeadjust
-- setdash
-- currentdash
-- setcolorspace
-- currentcolorspace



-- setgray
-- currentgray
function Blend2DDriver.setGraya(self, value, a)
    local c = BLRgba32()
    
    a = a or 1.0
    a = math.floor(a*255)
    local gray = math.floor(value*255)
    c.r = gray 
    c.g = gray 
    c.b = gray
    c.a = a

    -- need to set stroke color
    -- and fill color
    self.DC:setFillStyleRgba32(c.value);
    self.DC:setStrokeStyleRgba32(c.value);

    return self.CurrentState:setGray(c)
end

-- setcolor
-- currentcolor
-- r, g, b in range [0..1]
function Blend2DDriver.setRgbaColor(self, r, g, b,a)
    a = a or 1.0
    a = math.floor(a*255)
    r = math.floor(r*255)
    g = math.floor(g*255)
    b = math.floor(b*255)

    local c = BLRgba32()
    c.r = r
    c.g = g 
    c.b = b 
    c.a = a
    --print(string.format("setRgbaColor: %d %d %d %d, #%X", r, g, b, a, c.value))

    self.DC:setFillStyleRgba32(c.value);
    self.DC:setStrokeStyleRgba32(c.value);

    return self.CurrentState:setColor(c)

end

-- sethsbcolor
-- currenthsbcolor
-- setrgbcolor
-- currentrgbcolor
-- setcmykcolor
-- currentcmykcolor


-- Coordinate System and Matrix Operators
--matrix
--initmatrix
--identmatix
--defaultmatrix

--currentmatrix
function Blend2DDriver.currentMatrix(self)
    return self.DC:userMatrix()
end

--setmatrix
function Blend2DDriver.setMatrix(self, m)
    self.DC:setMatrix(m)

    return true
end

--translate
function Blend2DDriver.translate(self, tx, ty)
    self.DC:translate(tx, ty)
    
    return true
end


--scale
function Blend2DDriver.scale(self, sx, sy)
    self.DC:scale(sx, sy)

    return true
end


--rotate
function Blend2DDriver.rotateBy(self, angle)
    local rads = math.rad(angle)
    --local m2 = BLMatrix2D:createRotation(rads, 0,0)
    --local m1 = self.DC:userMatrix()

    --m2:concat(m1)
    --m1:concat(m2)
    --self.DC:setMatrix(m2)
    self.DC:rotate(rads)

    return true
end


--concat
--concatmatrix
--transform
--dtransform
--itransform
--idtransform
--invertmatrix

--[[
-- Path construction
--]]

function Blend2DDriver.setPath(self, apath)
    self.CurrentState.Path = apath
    
    return true
end

--newpath
function Blend2DDriver.newPath(self)
    --print("Blend2DDriver.newPath()")
    self.CurrentState.Path = BLPath()
    
    return true
end

-- pathbox
function Blend2DDriver.pathBox(self)
    local abox = BLBox()
    local bResult = self.CurrentState.Path:getBoundingBox(abox)
    
    return abox.x0, abox.y0, abox.x1, abox.y1
end

--currentpoint
function Blend2DDriver.getCurrentPosition(self)
    return self.CurrentState:getPosition()
end

--moveto
function Blend2DDriver.moveTo(self, x, y)
    self:newPath();
    self.CurrentState.Path:moveTo(x,y)


    return true
end

--rmoveto
--lineto
function Blend2DDriver.lineTo(self, x, y)
    --print("lineTo: ", x, y)
    self.CurrentState.Path:lineTo(x,y)

    return true
end

--rlineto
--arc
function Blend2DDriver.arc(self, x, y, r, angle1, angle2)
    -- blPathArcTo(BLPathCore* self, double x, double y, double rx, double ry, double start, double sweep, _Bool forceMoveTo)
    local sweep = math.rad(angle2 - angle1)
    self.CurrentState.Path:arcTo(x, y, r, r, math.rad(angle1), sweep, true)
    
    return true
end

--arcn
function Blend2DDriver.arn(self, x, y, r, angle1, angle2)
    -- blPathArcTo(BLPathCore* self, double x, double y, double rx, double ry, double start, double sweep, _Bool forceMoveTo)
    local sweep = math.rad(angle2 - angle1)
    self.CurrentState.Path:arcTo(x, y, r, r, math.rad(angle1), sweep, true)
    
    return true
end

--arct
function Blend2DDriver.arc(self, x1, y1, x2, y2, r)
    self.CurrentState.Path:arcTo(x, y, r, r, math.rad(angle1), sweep, true)
    
    return true
end

--arcto

--curveto
--rcurveto
function Blend2DDriver.curveTo(self, x1,y1,x2,y2,x3,y3)
    self.CurrentState.Path:cubicTo(x1,y1,x2,y2,x3,y3)

    return true
end

--closepath
function Blend2DDriver.closePath(self)
    self.CurrentState.Path:close()
    return true
end

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









--[[
    Painting Operators
]]
-- erasepage
-- Clear page to all white
function Blend2DDriver.erasepage(self)
    self.DC:save()
    self.DC:setFillStyle(BLRgba32(0xFFFFFFFF));
    self.DC:fillAll()
    self.DC:restore()

    return true
end




function Blend2DDriver.fill(self)
    self.DC:fillPathD(self.CurrentState.Path)
    return true
end

function Blend2DDriver.rectStroke(self, x, y, width, height)
    self.DC:strokeRectD(BLRect(x, y, width, height))

    return true
end

function Blend2DDriver.stroke(self)
    self.DC:strokePathD(self.CurrentState.Path);

    return true
end

--[[
    Device Setup
]]
function Blend2DDriver.showPage(self)
    BLImageCodec("BMP"):writeImageToFile(self.img, "output/ps_example.bmp")
    return true
end

--[[
    Font Operators
]]
function Blend2DDriver.stringWidth(self, str)

    local font = self.CurrentState.Font
    --print("Blend2DDriver.stringwidth: ", str, font)
    local dx, dy = font:measureText(str)

    --print("dx, dy: ", dx, dy)

    return dx, dy
end

function Blend2DDriver.show(self, pos, txt)
    local dst = BLPoint(pos[1],pos[2])
    local font = self.CurrentState.Font

    --print("Blend2DDriver.show: ", dst, font, txt, #txt)

    -- need to unflip temporarirly
    self.DC:save()
    self.DC:translate(pos[1], pos[2])
    self.DC:scale(1,-1)
    local success, err = self.DC:fillTextUtf8(BLPoint(), font, txt, #txt)
    
    self.DC:restore()


    return true
end

return Blend2DDriver
