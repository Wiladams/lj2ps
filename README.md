# lj2ps
Impetuous Postscript (IMPP) Postscript interpreter written in Lua


![Image](https://github.com/Wiladams/lj2ps/blob/master/images/tigger.png)


This project pulls together several different kinds of things.

  * Virtual Machine
  * Interpreted language
  * binding to blend2d vector graphics library

At present (4 Oct 2019), the interpreter is good enough to properly render the ghostscript tiger example above.  There are additional examples that exhibit various degrees of completeness of the operator set.

Things are done modularly so that they can be separable.  It is possible, for example, to use the postscript vm (ps_vm.lua) as a standalone virtual machine, without using the text scanner.  In this way, you're essentially making the same calls that the interpreter would itself be making.

The scanner can be used on its own if you want to do something like transpile the postscript language into something else.

The virtual machine is faithful to the standard Postscript model, utilizing stacks and operators for execution.  The execution of procedures deviates from what the Postscript spec implies.  It does not utilize the execution stack for tail recursion and the like.  Procedures are essentially executed as Lua coroutines.

The Postcript language environment has a large number of operators.  In general, the approach taken in this project is to implement the set of operators needed to make the various examples work.  Over time, this will mean an increasing number of examples and operators will actually work, but this will never be a full implementation of the language like ghostscript is.



The "Hello World" from the Lua side:

```lua
package.path = "../?.lua;"..package.path

local PSVM = require("lj2ps.ps_vm")
local Interpreter = require("lj2ps.ps_interpreter")


local vm = PSVM();              -- Create postscript virtual machine
local interp = Interpreter(vm)  -- create an interpreter


interp:run([[
  1 2 add 
  ==
]])

```

It will output

> 3

The vm can execute a string directly without having to create an instance of the interpreter explicitly.

```lua
local PSVM = require("lj2ps.ps_vm")
local vm = PSVM();              -- Create postscript virtual machine

vm:eval([[
%!
%% Example 1

newpath
100 200 moveto
200 250 lineto
100 300 lineto
2 setlinewidth
stroke
showpage

]])
```

There is a convenient utility in the 'testy' directory 'runps.lua'

Usage: luajit runps.lua case_tigger.ps

This is the easiest way to generate an image from a typical postscript file.  The various test
cases within the testy directory exercise various aspects of the interpreter from the simple stack
commands to the execution of procedures.

There are several more examples in the tutorials, examples, and resources directories.  They work to varying
degrees depending on which unimplemented features they utilize.  The iconic tiger image exercises curveto primarily
as well as scaling, so that works.  The more complex ghostscript examples variously work.

References
----------

http://paulbourke.net/dataformats/postscript/

http://logand.com/sw/wps/#sec-2.4

cholla.mmto.org/computers/postscript/tutorial.html

https://mostlymaths.net/2008/12/quick-postscript-programming-tutorial.html/

http://www.math.ubc.ca/~cass/graphics/manual/

https://www.tinaja.com/post01.shtml

https://subversion.american.edu/aisaac/wp/psdraw.html

https://en.wikibooks.org/wiki/PostScript_FAQ




Notes

Implementing Loops

https://stackoverflow.com/questions/6949434/how-to-implement-loop-in-a-forth-like-language-interpreter-written-in-c/6951850#6951850

int proc  **repeat**  -
    if int<0 Error
    if int==0 return //do nothing
    push null on exec stack   <--- this marks our "frame"
    push int-1 on exec stack
    push proc on exec stack
    push '@repeat-continue' on exec stack
    push executable proc on exec stack

@repeat-continue
    peek proc from exec stack
    peek int from exec stack
    if int==0 clear-to-null and return
    push '@repeat-continue' on exec stack
    push executable proc on exec stack