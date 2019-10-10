local utils = require 'mp.utils'


local function exec(args)
    local ret = utils.subprocess({args = args})
    return ret.status, ret.stdout, ret
end

local last_text = ""
mp.observe_property("sub-text","string", function(prop,txt)
    if txt ~= nil and txt ~= last_text then
        last_text = txt
        exec({"say", txt})
    end
end)

