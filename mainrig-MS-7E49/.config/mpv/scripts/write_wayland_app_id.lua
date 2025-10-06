-- Function to write Wayland app ID to /tmp
function write_wayland_app_id()
    local wayland_app_id = mp.get_property("wayland-app-id")
    if wayland_app_id then
        local file = io.open("/tmp/wayland_app_id.txt", "w")
        if file then
            file:write(wayland_app_id)
            file:close()
            mp.msg.info("Wayland App ID written to /tmp/wayland_app_id.txt")
        else
            mp.msg.error("Failed to open /tmp/wayland_app_id.txt for writing")
        end
    else
        mp.msg.error("Wayland App ID not found")
    end
end

-- Function to display or remove the pause overlay
function update_pause_overlay(paused)
    if paused then
        -- Write Wayland app ID to /tmp when paused
        write_wayland_app_id()
    end  -- This closing 'end' was missing
end

-- React to pause property changes
mp.observe_property("pause", "bool", function(name, paused)
    if paused then
        write_wayland_app_id()
    else
        write_wayland_app_id()
    end
end)

-- On file load, show overlay if starting paused
mp.register_event("file-loaded", function()
    local paused = mp.get_property_native("pause")
    write_wayland_app_id()
end)

-- On playback restart, show overlay again if paused
mp.register_event("playback-restart", function()
    local paused = mp.get_property_native("pause")
    -- Only show overlay if paused
    write_wayland_app_id()
end)

-- On fullscreen change, wait for OSD dimensions to update and refresh the overlay
mp.register_event("fullscreen", function()
    write_wayland_app_id()
end)

-- On window size change (e.g., resizing the window), wait for OSD dimensions to update and refresh the overlay
mp.register_event("window-size", function()
    write_wayland_app_id()
end)

-- On file end, remove overlay
mp.register_event("end-file", function()
    write_wayland_app_id()
end)
