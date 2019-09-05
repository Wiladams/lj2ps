local collections = require("wordplay.collections")
local Stack = collections.Stack 

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
local GraphicsState_mt = {
    __index = GraphicsState
}

function GraphicsState.new(self)
    local obj = {
        -- device independent
        CTM = {};
        Position = {0,0};
        Path = {};
        ClippingPath = {};
        ClippingPathStack = Stack();
        ColorSpace = {};
        Color = {};
        Font = {};
        LineWidth = 1.0;    -- user units
        LineCap = 0;        -- square butt
        LineJoin = 0;       -- miter
        MiterLimit = 10.0;
        DashPattern = {};
        StrokeAdjustment = false;

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

return GraphicsState
