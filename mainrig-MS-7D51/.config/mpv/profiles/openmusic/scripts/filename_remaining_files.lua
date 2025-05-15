local mp = require 'mp'

-- === Overlay setup ===
local top_overlay    = mp.create_osd_overlay("ass-events", false)  -- File info (top)
local bottom_overlay = mp.create_osd_overlay("ass-events", false)  -- Remaining count (bottom)

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

-- === Helper: Extract parent folder name ===
local function extract_folder_name(path)
    local segs = {}
    for s in path:gmatch("[^/\\]+") do table.insert(segs, s) end
    return segs[#segs - 1] or ""
end

-- === Helper: Remove file extension ===
local function remove_extension(filename)
    return filename:match("^(.*)%.") or filename
end

-- === Helper: Wrap text if it exceeds max width ===
local function wrap_text(text, max_width)
    if #text <= max_width then return text end
    local wrap_pos = max_width
    while wrap_pos > 0 and text:sub(wrap_pos, wrap_pos) ~= " " do
        wrap_pos = wrap_pos - 1
    end
    if wrap_pos == 0 then wrap_pos = max_width end
    return text:sub(1, wrap_pos) .. "\\N" .. wrap_text(text:sub(wrap_pos + 1), max_width)
end

-- === Update top overlay: Folder + filename ===
local function update_file_info()
    local full = mp.get_property("path")
    local name = mp.get_property("filename")
    if not (full and name) then
        top_overlay:remove()
        last_file_info = ""
        return
    end

    local folder = extract_folder_name(full)
    local name_no_ext = remove_extension(name)
    local wrapped_filename = wrap_text(name_no_ext, max_width_chars)

    local ass_text = string.format(
        "{\\an4\\bord3\\shad0\\fs%d\\b1\\q2\\3c&H%s&\\3a&H00&}{\\1c&H%s&}%s\\N{\\1c&H%s&}%s", 
        font_size, bg_color,
        folder_color, folder,
        filename_color, wrapped_filename
    )

    -- Only update if changed
    if ass_text ~= last_file_info then
        top_overlay.data = ass_text
        top_overlay:update()
        last_file_info = ass_text
    end
end

-- === Update bottom overlay: Remaining count ===
local function update_remaining()
    local pos = mp.get_property_number("playlist-pos", 0) + 1
    local tot = mp.get_property_number("playlist-count", 1)

    local ass_text = string.format(
        "{\\an2\\bord3\\shad0\\fs%d\\b1\\q2\\1c&H%s&\\3c&H%s&\\3a&H00&}Remaining: %d/%d", 
        font_size, counter_color, bg_color, pos, tot
    )

    -- Only update if changed
    if ass_text ~= last_remaining then
        bottom_overlay.data = ass_text
        bottom_overlay:update()
        last_remaining = ass_text
    end
end

-- === Clean up on end ===
mp.register_event("end-file", function()
    top_overlay:remove()
    bottom_overlay:remove()
    last_file_info = ""
    last_remaining = ""
end)

-- === Event-based updating ===

-- Allow manual refresh via IPC
mp.register_script_message("refresh-osd", function()
    update_file_info()
    update_remaining()
end)

-- Update file info when a new file is loaded
mp.register_event("file-loaded", update_file_info)

-- Update remaining count when playlist position or playlist itself changes
mp.observe_property("playlist-pos", "number", function() update_remaining() end)
mp.observe_property("playlist-count", "number", function() update_remaining() end)

-- OPTIONAL: Initial update in case mpv starts mid-playlist
update_file_info()
update_remaining()
