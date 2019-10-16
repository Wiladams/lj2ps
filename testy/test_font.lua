package.path = "../?.lua;"..package.path

local PSVM = require("lj2ps.ps_vm")
local vm = PSVM();              -- Create postscript virtual machine


local FontMonger = require("lj2ps.fontmonger")
local monger = FontMonger:new()

--[[
print("==== Families ====")
for family, v  in monger:families() do
    print(family, v)
end
--]]

print("==== Font Faces ====")
for family, subfamily, facedata in monger:faces() do
    print(family, "|", facedata.info.postscriptName)
    for k,v in pairs(facedata) do
        print("    ",k,v)
    end
end

print("==== Find Font ====")
local face = monger:getFace("tahoma", subfamily, true)

if face then
    print("face: ", face.face)
    print("       family: ", face.info.family)
    print("subFamilyName: ", face.info.subFamilyName)

end
