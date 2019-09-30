local ffi = require("ffi")
local C = ffi.C

--[[
    A matrix object with Postscript transformation
    behavior and representation.  It is essentially
    a truncated 3x3 matrix.

    a   b  =>   m00  m01  0
    c   d  =>   m10  m11  0
    tx ty  =>   m20  m21  1
--]]
ffi.cdef[[
struct PSMatrix {
    union {
        struct {
            double m00;
            double m01;
            double m10;
            double m11;
            double m20;
            double m21;
        };
        double m[6];
    };
};
]]
local PSMatrix = ffi.typeof("struct PSMatrix")
local PSMatrix_mt = {
    __tostring = function(self)
        return string.format("%3.2f %3.2f\n%3.2f %3.2f\n%3.2f %3.2f",
            self.m00,self.m01, self.m10, self.m11, self.m20, self.m21)
    end;

    __index = {
        --  Factory methods
        createIdentity = function(self)
            local obj = PSMatrix(1,0,0,1,0,0)
            return obj
        end;

        createTranslation = function(self, tx, ty)
            local obj = PSMatrix(1,0,0,1, tx, ty)
            return obj
        end;

        --[[
        -- rotation counter clockwise about origin by an
        -- angle specified in degrees
             cos(a)  sin(a)  0
            -sin(a)  cos(a)  0
              0       0      1
        --]]
        createRotation = function(self, angle, cx, cy)
            cx = cx or 0
            cy = cy or 0
            local rads = math.rad(angle)
            local rcos = math.cos(rads)
            local rsin = math.sin(rads)

            local obj = PSMatrix(rcos, rsin, -rsin, rcos, cx,cy)

            return obj
        end;

        createScaling = function(self, sx, sy)
            local obj = PSMatrix(sx, 0, 0, sy, 0, 0)
            return obj
        end;

        --[[
            Instance Methods
        --]]
        clone = function(self)
            local m = PSMatrix(self)
            return m
        end;

        -- used to determine if we can create an inverse
        determinant = function(self)
            return self.m00*self.m11 - self.m01*self.m10
        end;

        -- rotate
        -- apply rotation to current transform
        -- maintain scaling and translation
        rotate = function(self, angle, cx, cy)
            -- create rotation matrix
            local r = PSMatrix:createRotation(angle, cx, cy)

            -- premultiply by current
            self:preMultiplyBy(r)

            return self
        end;

        -- scale 
        -- apply scaling to current matrix, 
        -- keeping rotation and translation intact
        scale = function(self, sx, sy)
            self.m00 = self.m00 * sx;
            self.m01 = self.m01 * sx;
            self.m10 = self.m10 * sy;
            self.m11 = self.m11 * sy;

            return self
        end;

        -- translate
        -- apply matrix transform to specified offsets
        -- and add to current matrix translation
        translate = function(self, tx, ty)
            local x1,y1 = self:transformPoint(tx, ty)
            self.m20 = self.m20 + x1
            self.m21 = self.m21 + y1

            return self
        end;

        -- concatenate matrix transformations
        -- m = other * m
        -- a   b  0     a  b  0
        -- c   d  0     c  d  0
        -- tx ty  1    tx ty  1
        preMultiplyBy = function(self, other)
            local a = other.m00*self.m00 + other.m01*self.m10;
            local b = other.m00*self.m01 + other.m01*self.m11;
            
            local c = other.m10*self.m00 + other.m11*self.m10;
            local d = other.m10*self.m01 + other.m11*self.m11;

            local tx = other.m20*self.m00 + other.m21*self.m10 + self.m20;
            local ty = other.m20*self.m01 + other.m21*self.m11 + self.m21;

            self.m00 = a
            self.m01 = b 
            self.m10 = c 
            self.m11 = d
            self.m20 = tx
            self.m21 = ty

            return self
        end;

        transformPoint = function(self, x, y)
            local x1 = self.m00*x + self.m10*y + self.m20
            local y1 = self.m01*x + self.m11*y + self.m21

            return x1, y1
        end;
    };
}

ffi.metatype(PSMatrix, PSMatrix_mt)

return PSMatrix