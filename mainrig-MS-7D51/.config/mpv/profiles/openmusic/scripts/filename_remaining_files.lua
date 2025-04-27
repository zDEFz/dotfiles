local mp = require 'mp'

-- create two ASS overlays, always visible (false = playback_only flag)
local top    = mp.create_osd_overlay("ass-events", false)
local bottom = mp.create_osd_overlay("ass-events", false)

-- Set font size (increase the number for larger text)
local font_size = 120

-- Function to extract the folder name from the file path
local function extract_folder_name(file_path)
    -- Split the path into segments using '/' or '\\' as separators
    local path_segments = {}
    for segment in file_path:gmatch("[^/\\]+") do
        table.insert(path_segments, segment)
    end
    
    -- Get the second-to-last segment (the folder before the file)
    local folder_name = path_segments[#path_segments - 1]  -- This is the folder name

    -- If the folder name is nil (no folder), return an empty string
    return folder_name or ""
end

-- Function to show folder name and filename at the top
local function update_filename()
    local file_path = mp.get_property("path")  -- Get the full path
    local filename = mp.get_property("filename")  -- Get just the filename

    -- Debugging output to check what is returned
    mp.msg.info("File path: " .. tostring(file_path))  -- Debug: Check full path
    mp.msg.info("Filename: " .. tostring(filename))  -- Debug: Check filename

    if file_path and filename then
        -- Extract the folder name using the helper function
        local folder_name = extract_folder_name(file_path)

        -- Debugging: log the extracted folder name
        mp.msg.info("Extracted folder name: " .. tostring(folder_name))

        -- Show the folder name and the filename at the top
        top.data = string.format("{\\fs%d\\an8}%s - %s", font_size, folder_name, filename)
        top:update()
    else
        top:remove()
    end
end

-- Function to show remaining files at the bottom
local function update_remaining()
    local pos   = mp.get_property_number("playlist-pos", 0) + 1  -- 1-based index (current file)
    local tot   = mp.get_property_number("playlist-count", 1)
    bottom.data = string.format("{\\fs%d\\an2}Remaining: %d/%d", font_size, pos, tot)
    bottom:update()
end

-- update both overlays once per second
mp.add_periodic_timer(1, update_filename)
mp.add_periodic_timer(1, update_remaining)

-- clear everything at end of file
mp.register_event("end-file", function()
    top:remove()
    bottom:remove()
end)
