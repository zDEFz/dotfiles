-- Filename: display_text_if_no_video.lua

-- Function to show text (current filename)
function show_text()
    -- Get the filename of the current media
    local filename = mp.get_property("filename")

    -- Log the retrieval of the filename
    mp.msg.info("Inside show_text function.")  -- Debug log
    mp.msg.info("Attempting to retrieve filename...")  -- Debug log

    -- Check if filename was retrieved correctly
    if filename then
        mp.msg.info("Filename retrieved successfully: " .. filename)  -- Log the filename to ensure it was correctly retrieved

        -- Set consistent font size and alignment
        mp.set_property("osd-font-size", 60)  -- Set OSD font size (adjust the size as needed)
        mp.set_property("osd-align-x", "center")  -- Center horizontally
        mp.set_property("osd-align-y", "center")  -- Center vertically

        -- Set the custom OSD message (this will be persistent)
        mp.set_property("osd-msg1", filename)  -- Display filename persistently
        mp.msg.info("OSD message function called.")  -- Confirm that OSD function was called
    else
        mp.msg.info("Failed to retrieve filename.")  -- Log failure if filename isn't retrieved
    end
end

-- Main function to run the check and show text if no video stream
function check_for_video()
    mp.msg.info("Checking for video stream...")  -- Log the check for video stream

    -- Get the current video property
    local video_stream = mp.get_property("video")
    mp.msg.info("Video stream property: " .. tostring(video_stream))  -- Log the video property value (auto/no/yes)

    -- Check for a valid video stream (consider "auto" as no video stream)
    if video_stream == "no" or video_stream == "auto" then
        mp.msg.info("No valid video stream detected.")  -- Debug log when no video stream is found
        show_text()  -- Display the filename in OSD
    else
        mp.msg.info("Video stream detected.")  -- Debug log when video stream is present
        -- If there's video, clear any existing OSD text
        mp.set_property("osd-msg1", "")  -- Clear the OSD message
        mp.msg.info("OSD message cleared.")  -- Log that the OSD has been cleared
    end
end

-- Debug log when the file is loaded
function on_file_loaded()
    mp.msg.info("File loaded event triggered.")  -- Log when a file is loaded
    check_for_video()  -- Trigger the video check when file is loaded
end

-- Debug log when the video reconfigures (changes resolution or streams)
function on_video_reconfig()
    mp.msg.info("Video reconfig event triggered.")  -- Log when the video reconfigures
    check_for_video()  -- Trigger the video check after reconfiguring
end

-- Function to refresh the OSD message periodically
function refresh_osd_message()
    check_for_video()  -- Refresh the video check and show the message again
end

-- Trigger to display text when playback is paused or unpaused
function on_pause_state_changed()
    mp.msg.info("Pause state changed.")  -- Log when the pause state changes
    check_for_video()  -- Check and show the filename again if needed
end

-- Register the event for when a file is loaded
mp.register_event("file-loaded", on_file_loaded)
mp.msg.info("file-loaded event registered.")  -- Confirm the file-loaded event registration

-- Also check the video stream status when video reconfigures during playback
mp.register_event("video-reconfig", on_video_reconfig)
mp.msg.info("video-reconfig event registered.")  -- Confirm the video-reconfig event registration

-- Register the event for pause state change (paused/unpaused)
mp.register_event("pause", on_pause_state_changed)
mp.msg.info("pause event registered.")  -- Confirm the pause event registration

-- Initial check at script load
mp.msg.info("Script loaded. Performing initial video check.")
check_for_video()  -- Perform an initial check when the script is loaded

-- Set a periodic refresh every 3 seconds
mp.add_timeout(3, function() refresh_osd_message() end)  -- Call refresh every 3 seconds to keep OSD updated
