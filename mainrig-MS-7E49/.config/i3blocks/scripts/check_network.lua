#!/usr/bin/luajit
-- check_network.lua

local cache_file = "/dev/shm/mullvad_cache"

-- Helper to safely read files
local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*all")
    f:close()
    return content
end

-- 1. Watcher Management (Check specifically for the background flag)
local pcheck = io.popen("pgrep -f 'luajit .* --watch'"):read("*all")
if pcheck == "" and arg[1] ~= "--watch" then
    os.execute("luajit " .. arg[0] .. " --watch > /dev/null 2>&1 &")
end

-- 2. The Watcher Loop
if arg[1] == "--watch" then
    local handle = io.popen("mullvad status listen 2>/dev/null")
    if not handle then os.exit(1) end

    for line in handle:lines() do
        local status = line:match("^(%a+)")
        local relay = line:match("Relay: (%S+)") or ""
        
        if status then
            local f = io.open(cache_file, "w")
            if f then
                f:write(status .. "|" .. relay)
                f:close()
            end
        end
    end
    os.exit()
end

-- 3. Data Retrieval
local raw = read_file(cache_file)
local status, relay

if raw then
    status, relay = raw:match("([^|]*)|?(.*)")
end

-- Fallback if cache is empty or missing
if not status or status == "" then
    local m_out = io.popen("mullvad status"):read("*all")
    status = m_out:match("^(%a+)") or "Unknown"
    relay = m_out:match("Relay: (%S+)") or ""
end

-- 4. Formatting Logic
local colors = {
    Connected     = "#1AAFEF",
    Connecting    = "#FFDF00",
    Disconnecting = "#FFDF00",
    Disconnected  = "#FF8A65"
}

local text = status
if status == "Connected" and relay ~= "" then
    text = "Connected to " .. relay
end

local color = colors[status] or "#93A1A1"

-- i3blocks expects: Full Text \n Short Text \n Color \n
-- We use Pango for the color directly in the first line.
local output = string.format("<span foreground='%s'>%s</span>", color, text)
print(output)
-- print(output) -- Short text
-- print(color)  -- Color override for some bar configurations
