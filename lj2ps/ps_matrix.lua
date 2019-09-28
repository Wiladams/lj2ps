local ffi = require("ffi")
local C = ffi.C

ffi.cdef[[
struct PSMatrix {
    double a, b, c, d, tx, ty;
} PSMatrix;
]]
local PSMatrix = ffi.typeof("struct PSMatrix")
local PSMatrix_mt = {
    __tostring = function(self)
        return string.format("%3.2f %3.2f\n%3.2f %3.2f\n%3.2f %3.2f",
            self.a,self.b, self.c, self.d, self.tx, self.ty)
    end;

    __index = {
        createIdentity = function(self)
            local obj = PSMatrix(1,0,0,1,0,0)
            return obj
        end;

        createTranslation = function(self, dx, dy)
            local obj = PSMatrix(1,0,0,1, dx, dy)
            return obj
        end;

        -- rotation counter clockwise about origin (0,0)
        createRotation = function(self, angle)
            local rads = math.rad(angle)
            local cosr = math.cos(rads)
            local sinr = math.sin(rads)

            local obj = PSMatrix(cosr, sinr, -sinr, cosr, 0,0)

            return obj
        end;

        createScaling = function(self, sx, sy)
            local obj = PSMatrix(sx, 0, 0, sy, 0, 0)
            return obj
        end;

        -- Instance Methods
        -- m1 = other * m
        -- a   b  0     a  b  0
        -- c   d  0     c  d  0
        -- tx ty  1    tx ty  1
        preMultiplyBy = function(self, other)
            --c.m11 = a.m11*b.m11 + a.m12*b.m21 + a.m13*b.m31;        
            local a = other.a*self.a + other.b*self.c;

            --c.m12 = a.m11*b.m12 + a.m12*b.m22 + a.m13*b.m32;
            local b = other.a*self.b + other.b*self.d;
        
            --c.m21 = a.m21*b.m11 + a.m22*b.m21 + a.m23*b.m31;
            local c = other.c*self.a + other.d*self.c;
            
            --c.m22 = a.m21*b.m12 + a.m22*b.m22 + a.m23*b.m32;
            local d = other.c*self.b + other.d*self.d;

            --c.m31 = a.m31*b.m11 + a.m32*b.m21 + a.m33*b.m31;        
            local tx = other.tx*self.a + other.ty*self.c + self.tx;

            --c.m32 = a.m31*b.m12 + a.m32*b.m22 + a.m33*b.m32;
            local ty = other.tx*self.b + other.ty*self.d + self.ty;

            self.a = a
            self.b = b 
            self.c = c 
            self.d = d
            self.tx = tx
            self.ty = ty

            return self
        end;

        transformPoint = function(self, x, y)
            local x1 = self.a*x + self.c*y + self.tx
            local y1 = self.b*x + self.d*y + self.ty

            return x1, y1
        end;
    };
}

ffi.metatype(PSMatrix, PSMatrix_mt)

return PSMatrix