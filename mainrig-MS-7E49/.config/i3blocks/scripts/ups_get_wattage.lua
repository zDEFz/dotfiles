#!/usr/bin/env luajit
-- ups_get_wattage.lua - Pull-based with 1s cache protection

-- Configuration
local HOST      = "eaton-5PX-2200i"
local COMMUNITY = "public"
local MIB_PATH  = "/usr/share/snmp/mibs:" .. (os.getenv("HOME") or "/root") .. "/MIBs"
local KWH_PRICE = 0.35
local CACHE     = "/dev/shm/ups_data"
local CACHE_TTL = 1  -- seconds

-- Returns age of cache file in seconds, or math.huge if it doesn't exist.
-- Uses stat(1) via popen — no lfs dependency needed.
local function cache_age()
    local f = io.popen("stat -c %Y " .. CACHE .. " 2>/dev/null")
    if not f then return math.huge end
    local t = tonumber(f:read("*l"))
    f:close()
    if not t then return math.huge end
    return os.time() - t
end

-- Atomically write content to path via a .tmp swap
local function atomic_write(path, content)
    local tmp = path .. ".tmp"
    local f = io.open(tmp, "w")
    if not f then return end
    f:write(content)
    f:close()
    os.rename(tmp, path)
end

-- Fetch OIDs, compute output lines, update cache
local function fetch_and_cache()
    local cmd = string.format(
        "snmpget -v2c -c %s -M '%s' -m XUPS-MIB -Oqvn %s "
        .. "XUPS-MIB::xupsOutputPercentLoad.1 "
        .. "XUPS-MIB::xupsOutputTotalWatts.0 "
        .. "XUPS-MIB::xupsBatTimeRemaining.0 "
        .. "XUPS-MIB::xupsBatCapacity.0 2>/dev/null",
        COMMUNITY, MIB_PATH, HOST
    )

    local handle = io.popen(cmd)
    if not handle then return end
    local raw = handle:read("*a")
    handle:close()

    -- Extract first integer from each line (mirrors bash: tr -cd '0-9\n')
    local values = {}
    for line in raw:gmatch("[^\n]+") do
        values[#values + 1] = tonumber(line:match("%d+")) or 0
    end

    local ld = values[1] or 0  -- output load %
    local wt = values[2] or 0  -- output watts
    local tr = values[3] or 0  -- battery time remaining (seconds)
    local bc = values[4] or 0  -- battery capacity %

    -- Guard: don't cache if UPS is idle / SNMP returned garbage
    if wt <= 10 then return end

    local time_h = math.floor(tr / 3600)
    local time_m = math.floor((tr % 3600) / 60)
    local d_cost  = wt * 24  * KWH_PRICE / 1000
    local m_cost  = wt * 730 * KWH_PRICE / 1000

    -- Line 1: full  |  Line 2: short  (i3blocks two-line convention)
    local out = string.format(
        ">>> %d%% %dW | bat %d%% %dh%02dm | €%.2f/d | €%.2f/mo\n%dW | €%.2f/mo\n",
        ld, wt, bc, time_h, time_m, d_cost, m_cost, wt, m_cost
    )

    atomic_write(CACHE, out)
end

-- Refresh cache if stale, then always print whatever is cached
if cache_age() >= CACHE_TTL then
    fetch_and_cache()
end

local f = io.open(CACHE, "r")
if f then
    io.write(f:read("*a"))
    f:close()
end
