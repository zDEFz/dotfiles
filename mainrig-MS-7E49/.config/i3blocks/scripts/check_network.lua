#!/usr/bin/luajit
-- check_network.lua - Monitors Mullvad VPN status and current relay, outputting formatted text for i3blocks. Uses a cache file to minimize command calls.

local cache_file = "/dev/shm/mullvad_cache"

local function read_cache()
    local f = io.open(cache_file, "r")
    if not f then return nil, nil end
    local content = f:read("*all")
    f:close()
    -- Strip any newlines from the raw file content to prevent breaking Pango
    content = content:gsub("[\r\n]", "")
    return content:match("([^|]*)|?(.*)")
end

local function write_cache(status, relay)
    local f = io.open(cache_file, "w")
    if f then
        -- Sanitize inputs to prevent broken output
        status = (status or "Unknown"):gsub("%s+", "")
        relay = (relay or ""):gsub("%s+", "")
        f:write(string.format("%s|%s", status, relay))
        f:close()
    end
end

local function start_watcher()
    local handle = io.popen("mullvad status listen 2>/dev/null")
    if not handle then return end

    for line in handle:lines() do
        local clean = line:match("^%s*(.-)%s*$")
        
        if clean == "Connected" or clean == "Disconnected" or 
           clean == "Connecting" or clean == "Disconnecting" then
            
            local relay = ""
            if clean == "Connected" then
                local m_status = io.popen("mullvad status"):read("*all")
                relay = m_status:match("Relay: (%S+)") or ""
            end
            write_cache(clean, relay)
            
        elseif clean:match("^Relay:") then
            local new_relay = clean:match("Relay: (%S+)")
            write_cache("Connected", new_relay)
        end
    end
end

-- 1. Watcher Management
local pcheck = io.popen("pgrep -f 'mullvad status listen'"):read("*all")
if pcheck == "" then
    os.execute("luajit " .. arg[0] .. " --watch &")
end

if arg[1] == "--watch" then
    start_watcher()
    os.exit()
end

-- 2. Data Retrieval
local status, relay = read_cache()

if not status or status == "" then
    local m_out = io.popen("mullvad status"):read("*all")
    status = (m_out:match("^(%a+)") or "Unknown"):gsub("%s+", "")
    relay = (m_out:match("Relay: (%S+)") or ""):gsub("%s+", "")
    write_cache(status, relay)
end

-- 3. Logic (Matching your original bash exactly)
local text = status
if status == "Connected" and relay ~= "" then
    text = "Connected to " .. relay
end

local colors = {
    Connected     = "#1AAFEF",
    Connecting    = "#FFDF00",
    Disconnecting = "#FFDF00",
    Disconnected  = "#FF8A65"
}
local color = colors[status] or "#93A1A1"

-- 4. Final Output (Standard print includes the necessary \n for i3blocks)
print(string.format("<span foreground=\"%s\">%s</span>", color, text))