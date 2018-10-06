-- rubberband_helper.lua
--
-- rubberband is great for keeping voices intelligible when the video playback
-- is speed up, but it consumes a fair amount of CPU.
--
-- This script allows you to degrade the audio filter back to scaletempo when
-- playback speeds are high enough to make rubberband pointless.  Hopefully
-- this reduces pesky A/V desync that can occur when rubberband is pushed
-- too fast.
-- 
-- (default threshold is 3x, based on my personal preference)
local mp = require 'mp'

local threshold = 3
local scaletempo_af = {{name='scaletempo', enabled=true, params={speed="tempo"}}}
local rubberband_af = {{name='rubberband', enabled=true, params={channels="together"}}}

local last_set = nil
local function changed_speed(name, value)
    if last_set ~= scaletempo_af and (value == 1.0 or value > threshold) then
        mp.set_property_native('af', scaletempo_af)
        last_set = scaletempo_af
    elseif last_set ~= rubberband_af and (value ~= 1.0 and value <= threshold) then
        mp.set_property_native('af', rubberband_af)
        last_set = rubberband_af 
    end
end

mp.observe_property("speed", "number", changed_speed)

--re-implement the [ and ] keys.
--this nonsense is needed because observe_property("speed"...) isn't working
--properly for some reason in mpv 0.29.0
mp.add_forced_key_binding("[", "slowdown", function()
        mp.set_property("speed", mp.get_property("speed") - 0.1)
        mp.osd_message(string.format("x%.1f", mp.get_property("speed")), 1)
    end ,{repeatable=true})

mp.add_forced_key_binding("]", "speedup", function()
        mp.set_property("speed", mp.get_property("speed") + 0.1)
        mp.osd_message(string.format("x%.1f", mp.get_property("speed")), 1)
    end ,{repeatable=true} )
