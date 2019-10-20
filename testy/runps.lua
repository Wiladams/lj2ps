-- Run a postscript file that's specified on the command line
-- luajit runps.lua <filename>.ps
--
package.path = '../?.lua;'..package.path; 
local vm = require('lj2ps.ps_vm')({dpi=300}); 
print(vm:runFile(arg[1]))
