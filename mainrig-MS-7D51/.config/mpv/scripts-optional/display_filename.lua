-- filename: show_filename.lua
local mp = require("mp")

local show_filename = function()
    -- Get the current filename being played
    local filename = mp.get_property("filename")
    if filename then
        -- Display the filename as an OSD message
        mp.osd_message("Playing: " .. filename, 2)  -- '2' means the message will stay for 2 seconds
    end
end

-- Set a periodic timer to show the filename every second
mp.add_periodic_timer(1, show_filename)
