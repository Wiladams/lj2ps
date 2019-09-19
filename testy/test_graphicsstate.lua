package.path = "../?.lua;"..package.path


local GraphicsState = require("lj2ps.ps_graphicsstate")

local g1 = GraphicsState()
local g2 = g1:clone()

-- make some changes to original state
--g1.CTM:translate(30,30)
g1:setLineWidth(2)


local function printState(state)
    print("CTM = ")
    print(state.CTM)
    print("Path = ", state.Path)
    print("ClippingPath = ", state.ClippingPath)
    print("ColorSpace = ", state.ColorSpace)
    print("Color = ", state.Color)
    print("  RGB: ", state.Color.r, state.Color.g, state.Color.b)
    print("Font = ", state.Font)
    print("LineWidth = ", state.LineWidth)
    print("LineCap = ", state.LineCap)
    print("LineJoin = ", state.LineJoin)
    print("MiterLimit = ", state.MiterLimit)
    print("DashPattern = ", state.DashPattern)
    print("StrokeAdjustment = ", state.StrokeAdjustment)
    print("DDParams = ", state.DDParams)
end

print("==== STATE 1 ====")
printState(g1)


print("==== STATE 2 ====")
printState(g2)