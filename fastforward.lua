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
local inertial_decay = false -- changes the behavior of speed decay


-----------------------
local mp = require 'mp'
local auto_dec_timer = nil
local osd_duration = math.max(decay_delay, mp.get_property_number("osd-duration")/1000)

local function inc_speed()
    if auto_dec_timer ~= nil then
        auto_dec_timer:kill()
    end

    local new_speed = mp.get_property("speed") + speed_increments

    if new_speed > max_rate - speed_increments then
        new_speed = max_rate
    end

    mp.set_property("speed", new_speed)
    mp.osd_message(("▶▶ x%.1f"):format(new_speed), osd_duration)
end

local function auto_dec_speed()
    auto_dec_timer = mp.add_periodic_timer(decay_delay, dec_speed)
end

function dec_speed()
    local new_speed = mp.get_property("speed") - speed_decrements
    if new_speed < 1 + speed_decrements then
        new_speed = 1
        if auto_dec_timer ~= nil then auto_dec_timer:kill() end
    end
    mp.set_property("speed", new_speed)
    mp.osd_message(("▶▶ x%.1f"):format(new_speed), osd_duration)
end

local function fastforward_handle(table)
    if table == nil or table["event"] == "down" or table["event"] == "repeat" then
        inc_speed()
        if inertial_decay then
            mp.add_timeout(decay_delay, dec_speed)
        end
    elseif table["event"] == "up" then
        if not inertial_decay then
            auto_dec_speed()
        end
    end
end

mp.add_forced_key_binding("RIGHT", "fastforward", fastforward_handle, {complex=not inertial_decay, repeatable=inertial_decay})
