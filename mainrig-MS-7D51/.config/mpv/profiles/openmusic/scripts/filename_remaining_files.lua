 local mp = require 'mp'
-- create two ASS overlays (false = playback_only)
local top_overlay        = mp.create_osd_overlay("ass-events", false)  -- File info (top)
local bottom_overlay     = mp.create_osd_overlay("ass-events", false)  -- Remaining count (bottom)
-- Font size
local font_size = 94
-- Toggles
local show_file_info       = true
local show_remaining_count = true
-- Max width (characters) before wrapping
local max_width_chars = 40

-- Colors (ASS format: BBGGRR)
local bg_color = "000000"     -- Black background
local folder_color = "AAAAFF" -- Light yellow for folder
local filename_color = "FFFFFF" -- White for filename
local counter_color = "FFFFFF"  -- White for counter

-- Helper: get parent folder name
local function extract_folder_name(path)
    local segs = {}
    for s in path:gmatch("[^/\\]+") do table.insert(segs, s) end
    return segs[#segs - 1] or ""
end

-- Helper: wrap text if it exceeds maximum width
local function wrap_text(text, max_width)
    if #text <= max_width then
        return text
    end
    
    -- Find a good place to wrap (space character)
    local wrap_pos = max_width
    while wrap_pos > 0 and text:sub(wrap_pos, wrap_pos) ~= " " do
        wrap_pos = wrap_pos - 1
    end
    
    -- If no space found, force wrap at max_width
    if wrap_pos == 0 then
        wrap_pos = max_width
    end
    
    -- Insert newline and continue with the rest
    return text:sub(1, wrap_pos) .. "\\N" .. wrap_text(text:sub(wrap_pos + 1), max_width)
end

-- Update top overlay with folder and filename on separate lines (with filename wrapping)
local function update_file_info()
    if not show_file_info then
        top_overlay:remove()
        return
    end
    
    local full = mp.get_property("path")
    local name = mp.get_property("filename")
    if not (full and name) then
        top_overlay:remove()
        return
    end
    
    local folder = extract_folder_name(full)
    
    -- Wrap filename if needed
    local wrapped_filename = wrap_text(name, max_width_chars)
    
    -- Create ASS markup with folder and wrapped filename
    local ass_text = string.format(
        "{\\an7\\bord3\\shad0\\fs%d\\b1\\q2\\3c&H%s&\\3a&H00&}{\\1c&H%s&}%s\\N{\\1c&H%s&}%s", 
        font_size, bg_color, 
        folder_color, folder,
        filename_color, wrapped_filename
    )
    
    top_overlay.data = ass_text
    top_overlay:update()
end

-- Update bottom overlay (Remaining: X/Y)
local function update_remaining()
    if not show_remaining_count then
        bottom_overlay:remove()
        return
    end
    
    local pos = mp.get_property_number("playlist-pos", 0) + 1
    local tot = mp.get_property_number("playlist-count", 1)
    
    -- Apply a black background box with counter color text (bottom center)
    local ass_text = string.format(
        "{\\an2\\bord3\\shad0\\fs%d\\b1\\q2\\1c&H%s&\\3c&H%s&\\3a&H00&}Remaining: %d/%d", 
        font_size, counter_color, bg_color, pos, tot
    )
    
    bottom_overlay.data = ass_text
    bottom_overlay:update()
end

-- Refresh once per second
mp.add_periodic_timer(1, update_file_info)
mp.add_periodic_timer(1, update_remaining)

-- Clean up on end
mp.register_event("end-file", function()
    top_overlay:remove()
    bottom_overlay:remove()
end)
