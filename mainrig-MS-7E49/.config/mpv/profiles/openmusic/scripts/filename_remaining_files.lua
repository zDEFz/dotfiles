local mp = require 'mp'

-- === Overlay setup ===
local top_overlay    = mp.create_osd_overlay("ass-events", false)
local bottom_overlay = mp.create_osd_overlay("ass-events", false)

local font_size = 94
local max_width_chars = 40

-- === Colors (ASS format: BBGGRR) ===
local bg_color = "000000"
local folder_color = "AAAAFF"
local filename_color = "FFFFFF"
local counter_color = "FFFFFF"

-- === State tracking ===
local last_file_info = ""
local last_remaining = ""
local current_path = ""
local current_filename = ""
local overlays_visible = true  -- Toggle state

-- Pre-compile patterns
local extension_pattern = "^(.*)%."

-- === Helper: Extract parent folder name ===
local function extract_folder_name(path)
    local segments = {}
    for segment in path:gmatch("[^/\\]+") do
        segments[#segments + 1] = segment
    end
    return segments[#segments - 1] or ""
end

-- === Helper: Remove file extension ===
local function remove_extension(filename)
    return filename:match(extension_pattern) or filename
end

-- === Helper: Wrap text ===
local function wrap_text(text, max_width)
    if #text <= max_width then 
        return text 
    end
    
    local wrap_pos = max_width
    while wrap_pos > 0 and text:sub(wrap_pos, wrap_pos) ~= " " do
        wrap_pos = wrap_pos - 1
    end
    
    if wrap_pos == 0 then 
        wrap_pos = max_width 
    end
    
    local first_part = text:sub(1, wrap_pos)
    local remaining = text:sub(wrap_pos + 1)
    
    return first_part .. "\\N" .. wrap_text(remaining, max_width)
end

-- === Update functions with visibility check ===

local function update_file_info()
    if not overlays_visible then return end
    
    local path = mp.get_property("path")
    local filename = mp.get_property("filename")
    
    if not (path and filename) then
        if last_file_info ~= "" then
            top_overlay:remove()
            last_file_info = ""
        end
        return
    end
    
    if path == current_path and filename == current_filename and last_file_info ~= "" then
        return
    end
    
    current_path = path
    current_filename = filename
    
    local folder = extract_folder_name(path)
    local name_no_ext = remove_extension(filename)
    local wrapped_filename = wrap_text(name_no_ext, max_width_chars)
    
    local ass_text = string.format(
        "{\\an4\\bord3\\shad0\\fs%d\\b1\\q2\\3c&H%s&\\3a&H00&}{\\1c&H%s&}%s\\N{\\1c&H%s&}%s", 
        font_size, bg_color,
        folder_color, folder,
        filename_color, wrapped_filename
    )
    
    if ass_text ~= last_file_info then
        top_overlay.data = ass_text
        top_overlay:update()
        last_file_info = ass_text
    end
end

local function update_remaining()
    if not overlays_visible then return end
    
    local pos = mp.get_property_number("playlist-pos")
    local tot = mp.get_property_number("playlist-count")
    
    if not (pos and tot) then
        return
    end
    
    pos = pos + 1
    
    local ass_text = string.format(
        "{\\an2\\bord3\\shad0\\fs%d\\b1\\q2\\1c&H%s&\\3c&H%s&\\3a&H00&}Remaining: %d/%d", 
        font_size, counter_color, bg_color, pos, tot
    )
    
    if ass_text ~= last_remaining then
        bottom_overlay.data = ass_text
        bottom_overlay:update()
        last_remaining = ass_text
    end
end

-- === Toggle Logic ===
local function toggle_labels()
    overlays_visible = not overlays_visible
    if overlays_visible then
        -- Force refresh
        last_file_info = ""
        last_remaining = ""
        update_file_info()
        update_remaining()
    else
        top_overlay:remove()
        bottom_overlay:remove()
    end
end

-- === Events ===
mp.register_event("end-file", function()
    top_overlay:remove()
    bottom_overlay:remove()
    last_file_info = ""
    last_remaining = ""
    current_path = ""
    current_filename = ""
end)

mp.register_script_message("refresh-osd", function()
    update_file_info()
    update_remaining()
end)

mp.register_event("file-loaded", update_file_info)

local remaining_timer = nil
local function schedule_remaining_update()
    if remaining_timer then
        remaining_timer:kill()
    end
    remaining_timer = mp.add_timeout(0.1, update_remaining)
end

mp.observe_property("playlist-pos", "number", schedule_remaining_update)
mp.observe_property("playlist-count", "number", schedule_remaining_update)

-- === Keybindings ===
-- You can change "h" to any key you prefer
mp.add_key_binding("h", "toggle-labels", toggle_labels)

-- Initial update
mp.add_timeout(0.5, function()
    update_file_info()
    update_remaining()
end)
