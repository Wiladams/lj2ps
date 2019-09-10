package.path = "../?.lua;"..package.path

--local b2d = require("blend2d.blend2d")
local Blend2DDriver = require("lj2ps.b2ddriver")

local Driver = Blend2DDriver()


--[[
local img = BLImage(612, 792)   -- 8.5" x 11" @ 72 pt
local ctx, err = BLContext(img)
ctx:setFillStyle(BLRgba32(0xFFFFFFFF));
ctx:fillAll()
--ctx:setStrokeStyle(BLRgba32(0xFFFFFFFF));
--]]


--[[
newpath
100 200 moveto
200 250 lineto
100 300 lineto
2 setlinewidth
stroke
showpage
--]]

Driver:newPath()
Driver:moveTo(100, 200)
Driver:lineTo(200, 250)
Driver:lineTo(100, 300)
Driver:stroke();
Driver:showPage()