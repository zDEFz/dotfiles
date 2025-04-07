-- Debug message to check if script is loaded
mp.msg.info("remaining_files.lua script loaded")

-- Function to show the remaining files message while paused
function show_remaining_files_message()
    local current_pos = mp.get_property("playlist-pos")
    local total_files = mp.get_property("playlist-count")

    -- Debug: check values of playlist properties
    mp.msg.info(string.format("Current position: %d, Total files: %d", current_pos, total_files))

    -- Calculate the remaining files
    local remaining_files = total_files - current_pos - 1  -- Subtract 1 to exclude the current file

    -- Create the text message
    local remaining_message = "Remaining Files: " .. remaining_files

    -- Set the font size to a larger value
    mp.set_property("osd-font-size", 100)  -- Larger font for visibility

    -- Clear any existing overlays (pause icon)
    mp.commandv("overlay-remove", 1)  -- Remove the pause icon overlay

    -- Display the message at the top-left of the screen
    mp.osd_message(remaining_message, 10)  -- Display for 10 seconds, you can adjust as needed
end

-- React to pause property changes
mp.observe_property("pause", "bool", function(name, paused)
    -- Debug: Output pause state
    mp.msg.info(string.format("Pause state: %s", paused and "Paused" or "Playing"))

    if paused then
        -- Show the message if paused
        show_remaining_files_message()
    else
        -- Clear the message when unpaused
        mp.osd_message("", 0)  -- Clears the OSD message
    end
end)

-- On file load, show the message if starting paused
mp.register_event("file-loaded", function()
    mp.msg.info("File loaded event triggered")
    local paused = mp.get_property_native("pause")
    -- Only show the message if starting paused
    if paused then
        show_remaining_files_message()
    end
end)

-- On playback restart, show the message again if paused
mp.register_event("playback-restart", function()
    mp.msg.info("Playback restart event triggered")
    local paused = mp.get_property_native("pause")
    -- Only show the message if paused
    if paused then
        show_remaining_files_message()
    end
end)

-- On fullscreen change, ensure the message stays
mp.register_event("fullscreen", function()
    if mp.get_property_native("pause") then
        show_remaining_files_message()
    end
end)

-- On window size change, ensure the message stays
mp.register_event("window-size", function()
    if mp.get_property_native("pause") then
        show_remaining_files_message()
    end
end)

-- On file end, clear the OSD message
mp.register_event("end-file", function()
    mp.osd_message("", 0)  -- Clears the OSD message when file ends
end)
