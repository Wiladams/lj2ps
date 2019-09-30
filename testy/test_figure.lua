package.path = "../?.lua;"..package.path

local ffi = require("ffi")
local C = ffi.C 

local b2d = require("blend2d.blend2d")

function pathBox(apath)
    local abox = BLBox()
    local bResult = apath:getBoundingBox(abox)
    
    return abox.x0, abox.y0, abox.x1, abox.y1
end

local figure = BLPath()

local contour = BLPath()
contour:moveTo(0,0)
contour:lineTo(100,100)

print("ADDING PATH - BEGIN")
figure:addPath(contour, nil)
print("ADDING PATH - END")

print("BoundingBox: ", pathBox(figure))