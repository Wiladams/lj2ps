
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

local RenderingContext = {}
setmetatable(RenderingContext, {
    __call = function(self, ...)
        self:new(...)
    end;
})
local RenderingContext_mt = {
    __index = RenderingContext
}

function RenderingContext.new(self, ...)
    local obj = {
        GraphicsStack = Stack();
        ClippingPathStack = Stack();

        GraphicsState = GraphicsState();

        -- path
        -- path stack
    }

    setmetatable(obj, RenderingContext_mt)

    return obj
end

function RenderingContext.moveto(self, x, y)
end

function RenderingContext.lineTo(self, x, y)
end

function RenderingContext.newpath(self)
end
