local utils = require 'mp.utils'


local function exec(args)
    local ret = utils.subprocess({args = args})
    return ret.status, ret.stdout, ret
end

local last_text = ""
local enabled = false
mp.observe_property("sub-text","string", function(prop,txt)
    if enabled and txt ~= nil and txt ~= last_text then
        last_text = txt
        exec({"say", " "..txt}) -- prepend a space, incase the subtitle line begins with a - character.
    end
end)

mp.add_key_binding("Ctrl+x","toggle-tts-subs", function()
    enabled = not enabled
    mp.osd_message("Subtitle TTS mode: ".. utils.to_string(enabled) )
end)

