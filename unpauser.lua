-- unpauser.lua
--
-- Always unpause mpv when a new file is loaded.

mp.add_hook("on_load", 5, function ()
    if(mp.get_property_bool("pause") == true) then
        mp.set_property_bool("pause", false)
    end
end)
