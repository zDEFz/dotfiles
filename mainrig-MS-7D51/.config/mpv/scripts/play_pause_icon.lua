-- Define overlay_id as a global variable with a numeric value
local overlay_id = 1

-- Locate the pause icon using mp.find_config_file
local pause_icon = mp.find_config_file("icons/pause.bgra")
if not pause_icon then
    mp.msg.error("Could not locate pause icon file in ~/.config/mpv/icons!")
    return
end

-- Define the original overlay image dimensions
local overlay_w = 166
local overlay_h = 74

-- Function to update the overlay (centered)
function update_pause_overlay(paused)
    if paused then
        -- Get current OSD dimensions (with reasonable defaults)
        local osd_w = mp.get_property_number("osd-width", 1280)
        local osd_h = mp.get_property_number("osd-height", 720)
        
        -- Calculate centered coordinates
        local x = math.floor((osd_w - overlay_w) / 2)
        local y = math.floor((osd_h - overlay_h) / 2)
        
        -- Remove previous overlay if it exists
        mp.commandv("overlay-remove", overlay_id)
        
        -- Add the overlay with the correct parameters
        mp.commandv("overlay-add", 
                   overlay_id, 
                   x, 
                   y, 
                   pause_icon, 
                   0,
                   "bgra", 
                   overlay_w, 
                   overlay_h, 
                   overlay_w * 4)
    else
        mp.commandv("overlay-remove", overlay_id)
    end
end

-- Listen for pause changes
mp.observe_property("pause", "bool", function(name, paused)
    if paused ~= nil then
        update_pause_overlay(paused)
    end
end)

-- Set overlay on file load (if starting paused)
mp.register_event("file-loaded", function()
    local paused = mp.get_property_native("pause")
    update_pause_overlay(paused)
end)

-- Remove overlay when playback ends
mp.register_event("end-file", function()
    mp.commandv("overlay-remove", overlay_id)
end)
