-- fastforward.lua
--
-- Skipping forward by five seconds can be jarring.
--
-- This script allows you to tap or hold the RIGHT key to speed up video,
-- the faster you tap RIGHT the faster the video will play.  After 2.5
-- seconds the playback speed will begin to decay back to 1x speed.
local decay_delay = .05 -- rate of time by which playback speed is decreased
local speed_increments = .2 -- amount by which playback speed is increased each time
local speed_decrements = .4 -- amount by which playback speed is decreased each time
local max_rate = 5 -- will not exceed this rate

local mp = require 'mp'

local function inc_speed()
    if timer ~= nil then
        timer:kill()
    end

    local new_speed = mp.get_property("speed") + speed_increments

    if new_speed > max_rate - speed_increments then
        new_speed = max_rate
    end

    mp.set_property("speed", new_speed)
    mp.osd_message("▶▶ x"..new_speed)
end

local function dec_speed()
    timer = mp.add_periodic_timer(decay_delay, function()
        local new_speed = mp.get_property("speed") - speed_decrements
        if new_speed < 1 + speed_decrements then
            new_speed = 1
            timer:kill()
        end
        mp.set_property("speed", new_speed)
        mp.osd_message("▶▶ x"..new_speed)
    end)
end

local function fastforward_handle(table)
    if table["event"] == "down" or table["event"] == "repeat" then
        inc_speed()
    elseif table["event"] == "up" then
        dec_speed()
    end
end

mp.add_forced_key_binding("RIGHT", "fastforward", fastforward_handle, {complex=true})