
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
        StateStack = Stack()

    }
    
    -- Drawing Context
    local w = 612
    local h = 792
    obj.img = BLImage(w, h)   -- 8.5" x 11" @ 72 pt
    obj.DC, err = BLContext(obj.img)
    
    -- set coordinate system for y at the bottom
    -- we push from userToMeta so that this becomes
    -- the baseline transform
    -- Now when we push and pop other matrices, 
    -- they can apply to user space, and not affect the
    -- base transform
    obj.DC:translate(0,h)
    obj.DC:scale(1,-1)
    obj.DC:userToMeta()

    -- start with full white background
    obj.DC:setFillStyle(BLRgba32(0xFFFFFFFF));
    obj.DC:fillAll()

    setmetatable(obj, Blend2DDriver_mt)

    return obj
end

function Blend2DDriver.gSave(self)
    -- clone current graphics state
    -- store it on the statestack
    self.StateStack:push(self.CurrentState:clone())

    return true
end

function Blend2DDriver.gRestore(self)
    -- pop the graphics stack
    -- make it current
    self.CurrentState = self.StateStack:pop()

    return true
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
-- setcolor
-- currentcolor


-- setgray
-- currentgray
function Blend2DDriver.setGray(self, value)
    -- need to set stroke color
    -- and fill color
    local c = BLRgba32()
    local gray = math.floor(value*255)
    c.r = gray 
    c.g = gray 
    c.b = gray
    c.a = 255
    self.DC:setFillStyle(c);
    self.DC:setStrokeStyle(c);

    return self.CurrentState:setGray(value)
end

-- r, g, b in range [0..1]
function Blend2DDriver.setRgbColor(self, r, g, b)
    r = math.floor(r*255)
    g = math.floor(g*255)
    b = math.floor(b*255)

    local c = BLRgba32()
    c.r = r
    c.g = g 
    c.b = b 
    c.a = 255
    self.DC:setFillStyle(c);
    self.DC:setStrokeStyle(c);

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
--setmatrix

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
function Blend2DDriver.rotate(self, angle)
    self.DC:rotate(math.rad(angle))

    return true
end


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
    --print("lineTo: ", x, y)
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
function Blend2DDriver.fill(self)
    self.DC:fillPathD(self.CurrentState.Path)
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


return Blend2DDriver