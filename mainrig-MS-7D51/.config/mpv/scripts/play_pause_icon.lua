-- Define overlay ID
local overlay_id = 1

-- Locate icon files
local pause_icon = mp.find_config_file("icons/pause.bgra")
local play_icon = mp.find_config_file("icons/play.bgra")

if not pause_icon then
    mp.msg.error("Could not locate pause icon at ~/.config/mpv/icons/pause.bgra")
    return
end

if not play_icon then
    mp.msg.error("Could not locate play icon at ~/.config/mpv/icons/play.bgra")
    return
end

-- Function to display the overlay based on pause state
function update_overlay(paused)
    -- Define overlay dimensions
    local overlay_w = 128
    local overlay_h = 128
    local overlay_stride = overlay_w * 4  -- 4 bytes per pixel (BGRA)

    -- Get OSD dimensions
    local osd_width = mp.get_property("osd-width")
    local osd_height = mp.get_property("osd-height")

    if not osd_width or not osd_height then
        mp.msg.error("Failed to retrieve valid OSD dimensions")
        return
    end

    -- Center the overlay
    local x = math.floor((osd_width - overlay_w) / 2)
    local y = math.floor((osd_height - overlay_h) / 2)

    -- Select appropriate icon
    local icon_path = paused and pause_icon or play_icon

    -- Debug info
    mp.msg.info(string.format("Showing %s overlay at (%d, %d), size: %dx%d", paused and "pause" or "play", x, y, overlay_w, overlay_h))

    -- Remove existing overlay and add new one
    mp.commandv("overlay-remove", overlay_id)
    mp.commandv("overlay-add",
        overlay_id,
        x, y,
        icon_path,
        0,
        "bgra",
        overlay_w,
        overlay_h,
        overlay_stride,
        0,
        0
    )

    -- Remove the play icon after a short delay
    if not paused then
        mp.add_timeout(0.7, function()
            mp.commandv("overlay-remove", overlay_id)
        end)
    end
end

-- Function to check OSD validity before updating overlay
function wait_for_osd_dimensions_and_update()
    local osd_width = mp.get_property("osd-width")
    local osd_height = mp.get_property("osd-height")

    if osd_width and osd_height then
        local paused = mp.get_property_native("pause")
        update_overlay(paused)
    else
        mp.add_timeout(0.2, wait_for_osd_dimensions_and_update)
    end
end

-- Observe pause changes
mp.observe_property("pause", "bool", function(name, paused)
    update_overlay(paused)
end)

-- On file load
mp.register_event("file-loaded", function()
    update_overlay(mp.get_property_native("pause"))
end)

-- On playback restart
mp.register_event("playback-restart", function()
    update_overlay(mp.get_property_native("pause"))
end)

-- On fullscreen toggle
mp.register_event("fullscreen", function()
    wait_for_osd_dimensions_and_update()
end)

-- On window resize
mp.register_event("window-size", function()
    wait_for_osd_dimensions_and_update()
end)

-- On file end
mp.register_event("end-file", function()
    mp.commandv("overlay-remove", overlay_id)
end)
