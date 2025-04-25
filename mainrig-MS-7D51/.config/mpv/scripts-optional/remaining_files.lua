local mp = require("mp")

-- Display the remaining files at the bottom of the screen
local show_remaining_files = function()
    -- Get the playlist length (total number of items in the playlist)
    local playlist_length = mp.get_property_number("playlist-count")
    
    if playlist_length then
        local current_index = mp.get_property_number("playlist-pos")
        local remaining_files = playlist_length - current_index - 1  -- Exclude the current file
        
        -- Display the remaining files as an OSD message for 2 seconds
        mp.osd_message(string.format("Remaining Files: %d", remaining_files), 2)  -- Show for 2 seconds
    end
end

-- Set a periodic timer to show the remaining files every second
mp.add_periodic_timer(1, show_remaining_files)
