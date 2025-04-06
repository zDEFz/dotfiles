-- Define overlay ID
local overlay_id = 1

-- Locate the pause icon file
local pause_icon = mp.find_config_file("icons/pause.bgra")
if not pause_icon then
    mp.msg.error("Could not locate pause icon at ~/.config/mpv/icons/pause.bgra")
    return
end

-- Function to display or remove the pause overlay
function update_pause_overlay(paused)
    if paused then
        -- Define overlay dimensions (50% of screen size)
        local overlay_w = 64
        local overlay_h = 64
        local overlay_stride = overlay_w * 4  -- 4 bytes per pixel (BGRA)

        -- Get OSD width and height
        local osd_width = mp.get_property("osd-width")
        local osd_height = mp.get_property("osd-height")

        -- Ensure the properties are valid
        if not osd_width or not osd_height then
            mp.msg.error("Failed to retrieve valid OSD dimensions")
            return
        end

        -- Center the overlay based on OSD dimensions
        local x = math.floor((osd_width - overlay_w) / 2)
        local y = math.floor((osd_height - overlay_h) / 2)

        -- Debug info
        mp.msg.info(string.format("Showing pause overlay at (%d, %d), size: %dx%d", x, y, overlay_w, overlay_h))

        -- Remove existing overlay and add new one
        mp.commandv("overlay-remove", overlay_id)
        mp.commandv("overlay-add",
            overlay_id,
            x, y,
            pause_icon,
            0,
            "bgra",
            overlay_w,
            overlay_h,
            overlay_stride,
            0,
            0
        )
    else
        -- Remove overlay when unpaused
        mp.commandv("overlay-remove", overlay_id)
    end
end

-- Function to ensure OSD dimensions are valid before updating the overlay
function wait_for_osd_dimensions_and_update()
    local osd_width = mp.get_property("osd-width")
    local osd_height = mp.get_property("osd-height")

    -- Check if OSD dimensions are valid
    if osd_width and osd_height then
        local paused = mp.get_property_native("pause")
        update_pause_overlay(paused)
    else
        -- Retry after a short delay if dimensions are still invalid
        mp.add_timeout(0.2, wait_for_osd_dimensions_and_update)
    end
end

-- React to pause property changes
mp.observe_property("pause", "bool", function(name, paused)
    if paused then
        -- Only show overlay if paused
        update_pause_overlay(true)
    else
        -- Remove overlay if unpaused
        update_pause_overlay(false)
    end
end)

-- On file load, show overlay if starting paused
mp.register_event("file-loaded", function()
    local paused = mp.get_property_native("pause")
    -- Only show overlay if starting paused
    update_pause_overlay(paused)
end)

-- On playback restart, show overlay again if paused
mp.register_event("playback-restart", function()
    local paused = mp.get_property_native("pause")
    -- Only show overlay if paused
    update_pause_overlay(paused)
end)

-- On fullscreen change, wait for OSD dimensions to update and refresh the overlay
mp.register_event("fullscreen", function()
    -- Force refresh after fullscreen mode
    mp.msg.info("Fullscreen mode detected. Refreshing overlay...")
    wait_for_osd_dimensions_and_update()
end)

-- On window size change (e.g., resizing the window), wait for OSD dimensions to update and refresh the overlay
mp.register_event("window-size", function()
    -- Force refresh after window resize
    mp.msg.info("Window size change detected. Refreshing overlay...")
    wait_for_osd_dimensions_and_update()
end)

-- On file end, remove overlay
mp.register_event("end-file", function()
    mp.commandv("overlay-remove", overlay_id)
end)
