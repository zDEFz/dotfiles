#!/usr/bin/luajit
-- weather.lua - OpenWeatherMap fetcher for i3blocks with caching

-- 1. Load Environment
local env = {}
local f = io.open(os.getenv("HOME") .. "/.secure_env", "r")
if f then
    for k, v in f:read("*a"):gmatch('([%w_]+)%s*=%s*[\'"]([^\'"]+)[\'"]') do
        env[k] = v
    end
    f:close()
end

local ZIP     = env["ZIP_CODE"]               or os.getenv("ZIP_CODE")               or ""
local COUNTRY = env["COUNTRY_CODE"]           or os.getenv("COUNTRY_CODE")           or "de"
local API_KEY = env["OPENWEATHERMAP_API_KEY"] or os.getenv("OPENWEATHERMAP_API_KEY") or ""
local CITY    = env["CITY_HOME"]              or os.getenv("CITY_HOME")              or "wiesloch"

-- 2. Cache Check
local CACHE_FILE = "/dev/shm/weather_cache/weather.txt"
os.execute("mkdir -p /dev/shm/weather_cache")

local function read_cache()
    local cf = io.open(CACHE_FILE, "r")
    if not cf then return nil end
    local content = cf:read("*a")
    cf:close()
    return content ~= "" and content or nil
end

local function cache_age()
    local h = io.popen("stat -c %Y " .. CACHE_FILE .. " 2>/dev/null")
    local mtime = tonumber(h:read("*l") or "0") or 0
    h:close()
    return os.time() - mtime
end

local cached = read_cache()
if cached and cache_age() < 300 then
    io.write(cached)
    os.exit(0)
end

-- 3. Fetch helper
local function curl(url)
    local h = io.popen("curl -s '" .. url .. "'")
    local data = h:read("*a")
    h:close()
    return data
end

-- 4. Fetch Weather
local weather_url = string.format(
    "https://api.openweathermap.org/data/2.5/weather?zip=%s,%s&appid=%s&units=metric",
    ZIP, COUNTRY, API_KEY
)
local data = curl(weather_url)

if not data:find('"cod":200') then
    print("Weather: API/Connection Error")
    os.exit(1)
end

-- 5. Parse
local function extract(str, key)
    return str:match('"' .. key .. '"%s*:%s*"?([^",}]+)"?')
end

local temp_raw = extract(data, "temp")
local temp     = temp_raw and math.floor(tonumber(temp_raw) + 0.5) or "?"
local desc     = extract(data, "description") or "unknown"
local hum      = extract(data, "humidity")    or "0"
local wind_s   = extract(data, "speed")       or "0"
local wind_d   = tonumber(extract(data, "deg") or "0") or 0
local lat      = extract(data, "lat")         or "0"
local lon      = extract(data, "lon")         or "0"
local rise_ts  = extract(data, "sunrise")     or "0"
local set_ts   = extract(data, "sunset")      or "0"

-- 6. Air Quality
local aqi_url = string.format(
    "https://api.openweathermap.org/data/2.5/air_pollution?lat=%s&lon=%s&appid=%s",
    lat, lon, API_KEY
)
local aqi_data = curl(aqi_url)
local aqi = tonumber(aqi_data:match('"aqi"%s*:%s*(%d)') or "0") or 0

-- 7. Formatting
local wind_dirs = {"↑","↗","→","↘","↓","↙","←","↖"}
local wind_icon = wind_dirs[math.floor((wind_d + 22) / 45) % 8 + 1]

local aqi_icons = {"⚪","🟢","🟡","🟠","🔴","🟣"}
local aqi_texts = {"N/A","Good","Fair","Moderate","Poor","Very Poor"}
local aqi_icon  = aqi_icons[aqi + 1] or "⚪"
local aqi_text  = aqi_texts[aqi + 1] or "N/A"

local desc_lower = desc:lower()
local icon = "🌤"
for _, pair in ipairs({
    {"clear", "☀"}, {"cloud", "☁"}, {"rain", "🌧"},
    {"storm", "⛈"}, {"snow", "❄"}, {"mist", "🌫"}, {"fog", "🌫"}
}) do
    if desc_lower:find(pair[1]) then icon = pair[2]; break end
end

-- 8. Sunrise/Sunset
local function fmt_time(ts)
    local h = io.popen("date -d @" .. ts .. " +%H:%M")
    local t = h:read("*l") or "?"
    h:close()
    return t
end
local sunrise = fmt_time(rise_ts)
local sunset  = fmt_time(set_ts)

-- 9. Output
local out = string.format(
    "%s %d°C | %s | 💧%s%% | 🌬%s m/s %s | %s Air: %s | 🌅%s 🌇%s\n",
    icon, temp, desc, hum, wind_s, wind_icon,
    aqi_icon, aqi_text, sunrise, sunset
)

local wf = io.open(CACHE_FILE, "w")
if wf then wf:write(out); wf:close() end
io.write(out)
