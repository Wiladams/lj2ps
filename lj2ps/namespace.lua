--[[
    This is a conveniece that allows you to put things
    into a local namespace, and access them as if they were
    in a global namespace.

    Useful, because it allows you to not pollute the global namespace
    of you lua state, and also gives you local access to values, which
    will be faster than global access.

    Usage:
    local namespace = require("namespace")
    local myns = namespace()

    myns.a = 32
    myns.name = "William"

    print(a)
    print(name)
    
]]
local function namespace(res)
    res = res or {}
    setmetatable(res, {__index= _G})
    setfenv(2, res)
    return res
end


return namespace