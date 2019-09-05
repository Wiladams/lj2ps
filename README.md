# lj2ps
Postscript Virtual Machine using Lua

The general idea here is to use Postscript as an example of pulling together lots of things.

  Virtual Machine
  Drawing using a Driver model
  Scanning/Parsing Language

Things are done modularly so that they can be separable.  It is possible, for example, to use the postscript vm (ps_vm.lua) as a standalone virtual machine, without using the text scanner.  In this way, you're essentially making the same calls that the interpreter would itself be making.

The scanner can be used on its own if you want to do something like transpile the postscript language into something else.

The virtual machine is faithful to the standard Postscript model, utilizing stacks and operators for execution.  After an initial level of completeness, an attempt will be made to optimize by using the lua language stack more directly.  This may or may not turn out to be a fruitful endeavor.

At any rate, the Postcript language environment is very large.  It will take some time to become complete enough to do anything remotely useful.
