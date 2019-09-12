

local ps_common = require("lj2ps.ps_common")
local deepCopy = ps_common.deepCopy
local Stack = ps_common.Stack
local b2d = require("blend2d.blend2d")

--[[
-- device independent state
    CTM         array       current transformation matrix
    position        two numbers     Coordinates of current point
    path            (internal)  current path being built
    clipping path   (internal)  path defining current boundary
    clipping path stack
    color space
    color
    font
    line width
    line cap
    miter limit
    dash pattern
    stroke adjustment
]]

--[[
-- device dependent state
color rendering     dictionary
overprint           boolean
black generation    procedure
undercolor removal  procedure
transfer            procedure
halftone            procedure
flatness            number
smoothness          number
device              (internal)
]]

local GraphicsState = {}
setmetatable(GraphicsState, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local GraphicsState_mt = {
    __index = GraphicsState
}

function GraphicsState.assign(self, other)
    self.CTM = deepCopy(other.CTM);
    self.Position   = deepCopy(other.Position);
    self.Path = deepCopy(other.Path);
    self.ClippingPath = deepCopy(other.ClippingPath);
    self.ColorSpace = deepCopy(other.ColorSpace);
    self.Color = deepCopy(other.Color);
    self.Font = deepCopy(other.Font);
    self.LineWidth = deepCopy(other.LineWidth);
    self.LineCap = deepCopy(other.LineCap);
    self.LineJoin = deepCopy(other.LineJoin);
    self.MiterLimit = deepCopy(other.MiterLimit);
    self.DashPattern = deepCopy(other.DashPattern);
    self.StrokeAdjustment = deepCopy(other.StrokeAdjustment);
    self.DDParams = deepCopy(other.DDParams);

    return self
end



function GraphicsState.new(self)
    -- BUGBUG, show there be fields like this, or should
    -- it just implement something more specific to the drawing
    -- driver it will connect to?
    -- These attributes will need to be reflected in the driver anyway
    -- so it might be easier to simply translate going in and out through
    -- the various set/get calls.
    local obj = {
        -- device independent
        CTM = {};
        Position = {0,0};               -- start origin (0,0)
        Path = BLPath();                -- start with default path
        ClippingPath = nil;
        ClippingPathStack = Stack();
        ColorSpace = nil;
        Color = BLRgba32(0xFF000000);   -- Start with black fill/stroke
        Font = nil;
        LineWidth = 1.0;    -- user units
        LineCap = 0;        -- square butt
        LineJoin = 0;       -- miter
        MiterLimit = 10.0;
        DashPattern = {};
        StrokeAdjustment = false;

        -- Device Dependent Parameters
        DDParams = {
            ColorRendering = {};
            OverPrint = false;
            BlackGeneration = false;
            UndercolorRemoval = false;
            Transfer = false;
            Halftone = false;
            Flatness = 1.0;
            Smoothness = 1.0;
            Device = false;         -- Maybe put device context here?
        };
    }
    setmetatable(obj, GraphicsState_mt)

    return obj 
end

function GraphicsState.clone(self)
    local newstate = GraphicsState()
    newstate:assign(self)
    return newstate
end

-- setposition
-- currentposition
function GraphicsState.setPosition(self, x, y)
    self.Position = {x,y};
    return true
end
function GraphicsState.getPosition(self)
    return self.Position
end

-- setpath
-- currentpath
function GraphicsState.setPath(self, path)
    self.Path = path
    return true
end

-- setclippingpath
-- currentclippingpath
function GraphicsState.setClippingPath(self, clippingPath)
    self.ClippingPath = clipingPath;
    return true
end

-- setcolorspace
-- currentcolorspace
function GraphicsState.setColorSpace(self, colorSpace)
    self.ColorSpace = colorSpace
    return true
end

-- setcolor
-- currentcolor
function GraphicsState.setColor(self, color)
    self.Color = color;
    return true
end

function GraphicsState.setGray(self, color)
    self.Color = color
    return true
end

-- setfont
-- currentfont
function GraphicsState.setFont(self, font)
    self.Font = font;
    return true
end

-- setlinewidth
-- currentlinewidth
function GraphicsState.setLineWidth(self, width)
    self.LineWidth = width;
    return true;
end
function GraphicsState.getLineWidth(self)
    return self.LineWidth;
end

-- linecap
-- currentlinecap
function GraphicsState.setLineCap(self, cap)
    self.LineCap = cap;
end
function GraphicsState.getLineCap(self)
    return self.LineCap;
end

-- linejoin
-- currentlinejoin
function GraphicsState.setLineJoin(self, join)
    self.LineJoin = join;
end
function GraphicsState.getLineJoin(self)
    return self.LineJoin
end

-- miterlimit
-- currentmiterlimit
function GraphicsState.setMiterLimit(self, limit)
    self.MiterLimit = limit
    return true
end
function GraphicsState.getMiterLimit(self)
    return self.MiterLimit;
end


-- setdashpattern
-- currentdashpattern
function GraphicsState.setDashPatthern(self, pattern)
    self.DashPattern = pattern
    return true
end
function GraphicsState.getDashPattern(self)
    return self.DashPattern
end

-- strokeadjustment
-- currentstrokeadjustment
function GraphicsState.setStrokeAdjustment(self, adjustment)
    self.StrokeAdjustment = adjustment
    return true
end
function GraphicsState.getStrokeAdjustment(self)
    return self.StrokeAdjustment
end



return GraphicsState
