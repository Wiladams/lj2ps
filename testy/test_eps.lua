package.path = "../?.lua;"..package.path


local PSVM = require("lj2ps.ps_vm")

local vm = PSVM();              -- Create postscript virtual machine

vm:eval([[
%%BeginProcSet:Adobe_Illustrator_1.2d1 0 0

/Adobe_Illustrator_1.2d1 dup 100 dict def load begin
% definition operators
%/bdef {bind def} bind def
%/ldef {load def} bdef
%/xdef {exch def} bdef

]])