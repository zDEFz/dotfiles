#!/usr/bin/luajit
-- holiday.lua - Displays the next public holiday in Germany with an icon, name, and date. Highlights if today is a holiday.


-- 1. Date Configuration
local now = os.time()
local today_table = os.date("*t", now)
local current_year = today_table.year
local today_str = os.date("%Y-%m-%d", now)

-- 2. Gauss Easter Algorithm (Returns a Unix timestamp for Easter Sunday)
local function get_easter(yr)
    local a = yr % 19
    local b = math.floor(yr / 100)
    local c = yr % 100
    local d = math.floor(b / 4)
    local e = b % 4
    local f = math.floor((b + 8) / 25)
    local g = math.floor((b - f + 1) / 3)
    local h = (19 * a + b - d - g + 15) % 30
    local i = math.floor(c / 4)
    local k = c % 4
    local l = (32 + 2 * e + 2 * i - h - k) % 7
    local m = math.floor((a + 11 * h + 22 * l) / 451)
    local month = math.floor((h + l - 7 * m + 114) / 31)
    local day = ((h + l - 7 * m + 114) % 31) + 1
    
    return os.time({year = yr, month = month, day = day, hour = 0})
end

-- 3. Generate Holiday List
local function generate_holidays(yr)
    local holidays = {}
    local day_sec = 86400 -- Seconds in a day
    local easter = get_easter(yr)

    -- Fixed Holidays
    table.insert(holidays, {date = string.format("%d-01-01", yr), name = "🎉 Neujahr"})
    table.insert(holidays, {date = string.format("%d-01-06", yr), name = "👑 Drei Könige"})
    table.insert(holidays, {date = string.format("%d-05-01", yr), name = "💼 Tag der Arbeit"})
    table.insert(holidays, {date = string.format("%d-10-03", yr), name = "🇩🇪 Dt. Einheit"})
    table.insert(holidays, {date = string.format("%d-11-01", yr), name = "🕊️ Allerheiligen"})
    table.insert(holidays, {date = string.format("%d-12-25", yr), name = "🎄 1. Weihnacht"})
    table.insert(holidays, {date = string.format("%d-12-26", yr), name = "🎁 2. Weihnacht"})
    table.insert(holidays, {date = string.format("%d-12-31", yr), name = "🎆 Silvester"})

    -- Moving Holidays (Offset from Easter in seconds)
    local moving = {
        {offset = -2,  name = "✝️ Karfreitag"},
        {offset = 1,   name = "🐣 Ostermontag"},
        {offset = 39,  name = "☁️ Christi Himmelfahrt"},
        {offset = 50,  name = "🕊️ Pfingstmontag"}
    }

    for _, h in ipairs(moving) do
        local timestamp = easter + (h.offset * day_sec)
        table.insert(holidays, {date = os.date("%Y-%m-%d", timestamp), name = h.name})
    end

    -- Sort by date string
    table.sort(holidays, function(a, b) return a.date < b.date end)
    return holidays
end

-- 4. Logic: Find Next Holiday
local list = generate_holidays(current_year)

-- If late December, add next year's holidays to the list
if today_str > current_year .. "-12-26" then
    local next_yr_list = generate_holidays(current_year + 1)
    for _, h in ipairs(next_yr_list) do table.insert(list, h) end
end

local found = false
for _, h in ipairs(list) do
    if h.date == today_str then
        print(string.format("<span color=\"yellow\">Today: %s</span>", h.name))
        found = true
        break
    elseif h.date > today_str then
        print(string.format("<span>%s (%s)</span>", h.name, h.date))
        found = true
        break
    end
end

if not found then
    print("No upcoming holidays")
end
