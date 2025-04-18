local mpv = require "mp"

-- Path to the shared control file
local CONTROL_FILE = "/tmp/wayland_app_id.txt"

-- Get this instance's Wayland app ID
local current_id = mp.get_property("wayland-app-id")

-- Defensive: Ensure we have an ID
if not current_id or current_id == "" then
    mp.msg.error("No wayland-app-id found. Exiting script.")
    return
end

-- Writes this instance's ID to the control file
local function become_primary()
    local file = io.open(CONTROL_FILE, "w")
    if file then
        file:write(current_id)
        file:close()
        mp.msg.info("[wayland-control] Claimed playback control: " .. current_id)
    else
        mp.msg.error("Failed to write to " .. CONTROL_FILE)
    end
end

-- Reads current allowed app ID from file
local function get_allowed_id()
    local file = io.open(CONTROL_FILE, "r")
    if not file then return nil end
    local id = file:read("*l")
    file:close()
    return id
end

-- Pauses this instance if it's not allowed and is unpaused
local function enforce_playback_lock()
    local allowed_id = get_allowed_id()
    local is_paused = mp.get_property_native("pause")

    -- If no allowed ID, let everything be
    if not allowed_id or allowed_id == "" then
        return
    end

 -- If the current instance is not allowed and it's unpaused, pause it after a delay
    if allowed_id ~= current_id and not is_paused then
        mp.msg.info("[wayland-control] Not allowed (" .. current_id .. "), pausing after delay.")

        -- Add a delay of 2 seconds (or any other desired time) before pausing
        mp.add_timeout(2, function()
            mp.msg.info("[wayland-control] Pausing after delay.")
            mp.set_property("pause", "yes")
        end)
    end
end

-- React to pause/unpause changes
local function on_pause_change(name, value)
    local allowed_id = get_allowed_id()

    -- If this instance is unpaused and not the allowed one, we become the primary
    if value == false then -- Unpaused
        if allowed_id ~= current_id then
            mp.msg.info("[wayland-control] Unpaused — claiming control.")
            become_primary()
        end
    else -- Paused — no need to do anything here, let the user manually pause
        mp.msg.info("[wayland-control] Paused manually. Will stay paused.")
    end
end


-- Observe the pause state (unpause actions)
mp.observe_property("pause", "bool", on_pause_change)

-- Periodically check if we need to enforce the playback lock (pause others)
mp.add_periodic_timer(0.5, enforce_playback_lock)

mp.msg.info("[wayland-control] Script loaded for app_id: " .. current_id)
