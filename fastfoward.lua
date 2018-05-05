-- fastforward.lua
--
-- Skipping forward by five seconds can be jarring.
--
-- This script allows you to tap or hold the RIGHT key to speed up video,
-- the faster you tap RIGHT the faster the video will play.  After 2.5
-- seconds the playback speed will begin to decay back to 1x speed.
--
-- Tapping LEFT will skip back five seconds like normal, but will also reset
-- the playback speed to 1x.
local decay_delay = 2.5 -- time in seconds until playback speed decreases again
local speed_increments = .2 -- amount by which playback speed is increased each time
local max_rate = 5 -- will not exceed this rate

local mp = require 'mp'
local options = require 'mp.options'

local function inc_speed()
    local new_speed = mp.get_property("speed") + speed_increments
    if new_speed > max_rate then new_speed = max_rate end
    mp.set_property("speed", new_speed)
    mp.osd_message("▶▶ x"..new_speed, decay_delay)
end
local function dec_speed()
    local new_speed = mp.get_property("speed") - speed_increments

    -- clear up FP imprecision
    if new_speed < (1 + speed_increments)  then new_speed = 1 end 

    mp.set_property("speed", new_speed)
    mp.osd_message("▶▶ x"..new_speed, decay_delay)
end

local function fastforward_handle()
    inc_speed()
    mp.add_timeout(decay_delay, dec_speed )
end    

local function seekback_handle()
    mp.commandv("seek", -5)
    mp.set_property("speed", 1)
end

mp.add_forced_key_binding("RIGHT", "fastforward", fastforward_handle, {repeatable=true} )
mp.add_forced_key_binding("LEFT", "seekback", seekback_handle, {repeatable=true} )
