
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

        GraphicsState = GraphicsState();

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
    self.DC:setStrokeWidth(value)
    return true
end


-- setlinecap
-- currentlinecap
function Blend2DDriver.setLineCap(self, value)
    self.DC:setLineCap(value)
    return true
end

-- setlinejoin
-- currentlinejoin
function Blend2DDriver.setLineJoin(self, value)
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




function Blend2DDriver.moveTo(self, x, y)
    print("Blend2DDriver.moveTo: ", x, y)
    self.Path:moveTo(x,y)
    return true
end

function Blend2DDriver.lineTo(self, x, y)
    print("Blend2DDriver.lineTo: ", x, y)
    self.Path:lineTo(x,y)
    return true
end

function Blend2DDriver.newPath(self)
    print("Blend2DDriver.newPath")
    self.Path = BLPath()
    return true
end



--[[
    Painting Operators
]]
function Blend2DDriver.stroke(self)
    print("Blend2DDriver.stroke")
    print("  : ", self.DC:strokePathD(self.Path));

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
