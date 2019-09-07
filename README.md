# lj2ps
Impetuous Postscript (IMPP)

Postscript Virtual Machine using Lua

This project is an exploration of trying to pull together several different kind of things.

  Virtual Machine
  Drawing using a Driver model
  Scanning/Parsing Language

```Postscript
 0   0  moveto
72  72  lineto
stroke
```

Things are done modularly so that they can be separable.  It is possible, for example, to use the postscript vm (ps_vm.lua) as a standalone virtual machine, without using the text scanner.  In this way, you're essentially making the same calls that the interpreter would itself be making.

The scanner can be used on its own if you want to do something like transpile the postscript language into something else.

The virtual machine is faithful to the standard Postscript model, utilizing stacks and operators for execution.  After an initial level of completeness, an attempt will be made to optimize by using the lua language stack more directly.  This may or may not turn out to be a fruitful endeavor.

At any rate, the Postcript language environment is very large.  It will take some time to become complete enough to do anything remotely useful.


Here is a "Hello World" that current works:

```lua
package.path = "../?.lua;"..package.path

local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")


local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter


interp:run([[
  1 2 add 
  pstack
]])

```

It will output

> 3

The vm itself should have facility to execute a string directly without having to create an instance of the interpreter explicitly.  That will come in next revision.
