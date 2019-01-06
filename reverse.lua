-- reverse.lua
--
-- Reverses the current playlist, preserving playlist titles.
-- Bound to Meta+r

local function reverse_playlist()
    local current_file = mp.get_property("playlist/" .. mp.get_property_number("playlist-pos-1") .. "/filename")
    local current_time = mp.get_property_number("time-pos")
    local new_pos = nil

    playlist={"#EXTM3U"}
    for _, f in ipairs(mp.get_property_native("playlist")) do
        table.insert(playlist, 2, f.filename)
        if f.title then table.insert(playlist, 2, "#EXTINF:0,"..f.title) end

        if f.filename == current_file then new_pos = 1
        elseif new_pos then new_pos = new_pos + 1
        end
    end
    mp.commandv("loadlist", "memory://"..table.concat(playlist,"\n"), "replace")
    mp.set_property_number("playlist-pos-1", new_pos)

    local function seeker()
        mp.commandv("seek", current_time, "absolute")
        mp.unregister_event(seeker)
    end
    mp.register_event("file-loaded", seeker)
end

mp.add_key_binding("Meta+r", "reverse-playlist", reverse_playlist)
