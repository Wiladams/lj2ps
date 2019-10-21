--[[
    A figure is the representation of a composite
    path.  The individual segments within a figure
    are contours.  Each individual contour has a 
    transformation matrix.
]]

local Matrix = require("lj2ps.ps_matrix")

local PSFigure = {}
setmetatable(PSFigure, {
    __call = function (self, ...)
        return self:new(...)
    end;
})
local PSFigure_mt = {
    __index = PSFigure
}

function PSFigure.new(self, VM)
    local obj = {
        VM = VM;
        BasePath = BLPath();
        CurrentContour = BLPath();
    }

    setmetatable(obj, PSFigure_mt)

    return obj
end

function PSFigure.clone(self)
    local clonedBase = BLPath();
    clonedBase:assignDeep(self.BasePath)

    local obj = {
        VM = self.VM;
        BasePath = clonedBase;
        lastX = self.lastX;
        lastY = self.lastY;
    }
    setmetatable(obj, PSFigure_mt)

    return obj;
end

--[[
    Properties
]]

function PSFigure.currentPosition(self)
    return {self.lastX, self.lastY}
end

function PSFigure.boundingBox(self)
    local abox = BLBox()
    local bResult = self.BasePath:getBoundingBox(abox)
    
    return abox.x0, abox.y0, abox.x1, abox.y1
end

--[[
    Contour Management

    A contour is a subpath of the larger figure.  They are constructed
    using path objects, and then added to the figure's base path object
]]
local function PSMatrixToBLMatrix2D(m)
    --print(m)
    local m1 = BLMatrix2D()
    m1:set(m.m00, m.m01, m.m10, m.m11, m.m20, m.m21)

    return m1
end

function PSFigure.attachContour(self, c)
    --print("PSFigure.attachContour, VM: ", self.VM, self.VM.getCTM)
    local ctm = self.VM.Driver:getCTM()
    local m1 = PSMatrixToBLMatrix2D(ctm)
    --print("PSFigure.attachContour: ")
    --print(m1)

    self.BasePath:addTransformedPath(c, nil, m1)

    --self.BasePath:addPath(c, nil)
    
    return true
end

function PSFigure.attachCurrentContour(self)
    if self.CurrentContour then
        self:attachContour(self.CurrentContour)
        self.CurrentContour = nil;
    end

    return self
end

function PSFigure.newContour(self)
    --print("newContour - BEGIN, contour: ", self.CurrentState.CurrentContour)
    -- take existing contour and add it to the 
    -- current figure

    self:attachCurrentContour()

    -- create a new countour for future contouring commands
    self.CurrentContour = BLPath()

    return true
end

function PSFigure.closeContour(self)
    self.CurrentContour:close()
    self:attachCurrentContour()
end

--[[
--moveto
--rmoveto
    moveTo will initiate a new contour on the existing figure.
--]]
function PSFigure.moveTo(self, x, y)
    --print("PSFigure.moveTo: ", x, y)

    self.lastX = x
    self.lastY = y

    self:newContour()

    self.CurrentContour:moveTo(x,y)

    --local ctm = self.VM.Driver:getCTM()
    --local x1, y1 = ctm:transformPoint(x,y)
    --self.CurrentContour:moveTo(x1,y1)
    --print("PSFigure.moveTo: ", x,y,x1, y1)

    return true
end



--lineto
--rlineto
function PSFigure.lineTo(self, x, y)
    --print("PSFigure.lineTo: ", x, y)

    self.lastX = x
    self.lastY = y

    self.CurrentContour:lineTo(x,y)

    --local ctm = self.VM.Driver:getCTM()
    --local x1, y1 = ctm:transformPoint(x,y)
    --self.CurrentContour:lineTo(x1,y1)
    --print("PSFigure.lineTo: ", x, y, x1, y1)

    return true
end

-- BUGBUG, need to capture lastX, lastY
function PSFigure.arc(self, x, y, r, angle1, angle2)
    --print("PSFigure.arc: ", x, y, r, angle1, angle2)
    local sweep = math.rad(angle2 - angle1)
    local bResult = self.CurrentContour:arcTo(x, y, r, r, math.rad(angle1), sweep, false)

    --local ctm = self.VM.Driver:getCTM()
    --local x1, y1 = ctm:transformPoint(x,y)
    --local rx, ry = ctm:dtransform(r, r)
    --local bResult = self.CurrentContour:arcTo(x1, y1, rx, ry, math.rad(angle1), sweep, false)

    -- get last point, and do inverse transform on it
    -- to figure out untransformed point
    local vtxOut = BLPoint()
    self.CurrentContour:getLastVertex(vtxOut)
    self.lastX = vtxOut.x
    self.lastY = vtxOut.y

    return true
end

function PSFigure.curveTo(self, x1,y1,x2,y2,x3,y3)
    self.lastX = x3
    self.lastY = y3
    return self.CurrentContour:cubicTo(x1,y1,x2,y2,x3,y3)

    --local ctm = self.VM.Driver:getCTM()
    --local x11, y11 = ctm:transformPoint(x1,y1)
    --local x21, y21 = ctm:transformPoint(x2,y2)
    --local x31, y31 = ctm:transformPoint(x3,y3)
    --return self.CurrentContour:cubicTo(x11,y11,x21,y21,x31,y31)
end

function PSFigure.addTransformedPath(self, path, m)
    --self.CurrentContour:addPath(path, nil)
    self.CurrentContour:addTransformedPath(path, nil, m)
end

--[[
    Rendering
]]

function PSFigure.fill(self, ctx)
    self:attachCurrentContour()

    ctx:fillPathD(self.BasePath)
--print("FILL - END")
end

function PSFigure.stroke(self, ctx)
    self:attachCurrentContour()

    -- apply the transform now
    ctx:strokePathD(self.BasePath);

end


return PSFigure