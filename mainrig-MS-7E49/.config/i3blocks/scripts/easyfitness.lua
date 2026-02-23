#!/usr/bin/env luajit
-- easyfitness.lua - Fetches current occupancy and class schedule for EasyFitness gym in Wiesloch

-- 1. Load Environment
local env = {}
local home = os.getenv("HOME")
local f = io.open(home .. "/.secure_env", "r")
if f then
    local content = f:read("*a")
    f:close()
    for k, v in content:gmatch('export%s+(%w+)="?([^"%s]+)"?') do
        env[k] = v
    end
end
local city = env["CITY_HOME"] or "wiesloch"

-- 2. Pre-checks (VPN & Time)
local vpn_f = io.open("/dev/shm/mullvad_cache", "r")
if vpn_f then
    local s = vpn_f:read("*l")
    vpn_f:close()
    if not s:find("Connected") then print("VPN Offline") os.exit() end
else
    print("VPN Offline") os.exit()
end

local t = os.date("*t")
local d = (t.wday == 1 and 7 or t.wday - 1)
local h = t.hour
if not ((d <= 5 and h >= 6 and h < 23) or (d >= 6 and h >= 8 and h < 21)) then
    print("Gym Closed") os.exit()
end

-- 3. Fetch and parse
local url = "https://easyfitness.club/studio/easyfitness-" .. city .. "/"
local handle = io.popen("curl -sL -A 'Mozilla/5.0' '" .. url .. "'")
local html = handle:read("*a")
handle:close()

local occ = html:match('class="meterbubble">(%d+)%%') or "0"

-- 4. Full Schedule (all classes, no umlauts)
local schedule = {
    ["1_10"]    = "Gemeinsam Gesund",
    ["1_10.5"]  = "Rueckenfit",
    ["1_17.75"] = "World Jumping",
    ["1_18.75"] = "Rueckenfit",
    ["1_19"]    = "Spinning Kurs",
    ["1_19.5"]  = "Workout Mix",
    ["1_20"]    = "Boxkurs",
    ["2_17.75"] = "Zumba",
    ["2_18.75"] = "Rueckenfit",
    ["2_19"]    = "Hyrox",
    ["3_10"]    = "Yoga",
    ["3_18"]    = "Piloxing Knockout",
    ["3_18.5"]  = "Piloxing",
    ["3_19"]    = "Piloxing Booty",
    ["4_10"]    = "Gemeinsam Gesund",
    ["4_10.5"]  = "Rueckenfit",
    ["4_16.5"]  = "Hip Hop Dance",
    ["4_18"]    = "Piloxing Knockout",
    ["4_18.5"]  = "Piloxing",
    ["5_10"]    = "Yoga",
    ["5_17.5"]  = "Dance Workout",
    ["5_18"]    = "Hyrox",
    ["6_10"]    = "Spinning",
    ["6_11"]    = "World Jumping",
    ["7_10"]    = "Piloxing",
    ["7_10.75"] = "Piloxing Booty",
    ["7_11"]    = "Functional Kurs",
    ["7_16"]    = "Power Yoga",
    ["7_17"]    = "Hatha Yoga",
}

-- 5. Check current class
local now_total = t.hour * 60 + t.min
local current_class = nil

for key, name in pairs(schedule) do
    local s_day, s_hour = key:match("^(%d+)_(%d+%.?%d*)$")
    if tonumber(s_day) == d then
        local sched_total = math.floor(tonumber(s_hour) * 60)
        if math.abs(now_total - sched_total) <= 12 then
            current_class = name
            break
        end
    end
end

-- 6. Output
if current_class then
    print(string.format("%s%% Gym (likely full: %s)", occ, current_class))
else
    print(string.format("%s%% Gym", occ))
end
