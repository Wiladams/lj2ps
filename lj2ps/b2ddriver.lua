
local ps_common = require("lj2ps.ps_common")
local Stack = ps_common.Stack

local ops = require("lj2ps.ps_operators")
local DictionaryStack = require("lj2ps.ps_dictstack")
local GraphicsState = require("lj2ps.ps_graphicsstate")
local b2d = require("blend2d.blend2d")

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

function Blend2DDriver.new(self, ...)

    local obj = {
        GraphicsStack = Stack();
        ClippingPathStack = Stack();

        CurrentState = GraphicsState();

        -- path
        -- path stack

    }
    
    -- Drawing Context
    obj.img = BLImage(612, 792)   -- 8.5" x 11" @ 72 pt
    obj.DC, err = BLContext(obj.img)
    
    -- start with full white background
    obj.DC:setFillStyle(BLRgba32(0xFFFFFFFF));
    obj.DC:fillAll()

    setmetatable(obj, Blend2DDriver_mt)

    return obj
end

--[[
    Graphics State
]]
-- setlinewidth
-- currentlinewidth
function Blend2DDriver.setLineWidth(self, value)
    self.CurrentState.LineWidth = value
    self.DC:setStrokeWidth(value)
    return true
end


-- setlinecap
-- currentlinecap
function Blend2DDriver.setLineCap(self, value)
    self.CurrentState.LineCap = value;
    self.DC:setLineCap(value)
    return true
end

-- setlinejoin
-- currentlinejoin
function Blend2DDriver.setLineJoin(self, value)
    self.CurrentState.LineJoin = value
    self.DC:setLineJoin(value)
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
-- Path construction
--]]
--newpath
function Blend2DDriver.newPath(self)
    self.CurrentState.Path = BLPath()
    
    return true
end

--currentpoint
function Blend2DDriver.getCurrentPosition(self)
    return self.CurrentState.Position
end

--moveto
function Blend2DDriver.moveTo(self, x, y)
    self.CurrentState.Path:moveTo(x,y)
    self.CurrentState.Position = {x,y}

    return true
end

--rmoveto
--lineto
function Blend2DDriver.lineTo(self, x, y)
    self.CurrentState.Path:lineTo(x,y)
    self.CurrentState.Position = {x,y}

    return true
end

--rlineto
--arc
--arcn
--arct
--arcto

--curveto
--rcurveto

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


return Blend2DDriver
