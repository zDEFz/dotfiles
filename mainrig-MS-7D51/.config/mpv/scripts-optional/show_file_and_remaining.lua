-- filename: show_file_and_remaining.lua
local mp       = require 'mp'
local assdraw  = require 'mp.assdraw'

local function update()
    -- Get data
    local fn    = mp.get_property("filename") or ""
    local total = mp.get_property_number("playlist-count") or 0
    local pos   = mp.get_property_number("playlist-pos")   or 0
    local rem   = math.max(total - pos - 1, 0)

    -- Try to get OSD size; fall back if missing
    local w = mp.get_property_number("osd-width", 0)
    local h = mp.get_property_number("osd-height", 0)
    if w == 0 or h == 0 then
        w, h = mp.get_osd_size()
    end

    -- Build ASS
    local ass = assdraw.ass_new()
    -- Top-left corner for filename (\an7)
    ass:new_event()
    ass:pos(10, 10)
    ass:append("{\\an7}" .. fn)
    -- Bottom-left corner for remaining count (\an1)
    ass:new_event()
    ass:pos(10, h - 10)
    ass:append("{\\an1}Remaining: " .. rem)

    -- Render both messages together
    mp.set_osd_ass(w, h, ass.text)
end

-- Update on load and every second
mp.register_event("file-loaded", update)
mp.add_periodic_timer(1, update)
