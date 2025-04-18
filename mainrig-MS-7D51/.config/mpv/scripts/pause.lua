local my_stable_app_id = nil
local last_seen_file_id = nil
local file_check_timer = nil
local initialized = false

local function debug(msg)
    mp.msg.info("[check_app_id] " .. msg)
end

-- Get our stable app ID once
local function get_stable_app_id()
    if not my_stable_app_id then
        my_stable_app_id = mp.get_property_native("wayland-app-id")
        if my_stable_app_id then
            debug("Initialized with app ID: " .. my_stable_app_id)
        else
            debug("Failed to get app ID!")
        end
    end
    return my_stable_app_id
end

-- Check the file and handle pause logic
local function check_file()
    -- Get our app ID if not already set
    local my_id = get_stable_app_id()
    if not my_id then return end
    
    -- Read current active app ID from file
    local file = io.open("/tmp/wayland_app_id.txt", "r")
    if not file then return end
    
    local file_id = file:read("*l")
    file:close()
    
    if not file_id then return end
    
    -- Only process if this is a new file ID we haven't seen before
    if file_id ~= last_seen_file_id then
        debug("Active window changed to: " .. file_id)
        last_seen_file_id = file_id
        
        -- If we're not the active window, pause
        if file_id ~= my_id then
            local pause_state = mp.get_property_native("pause")
            if not pause_state then
                debug("Not active window, pausing playback")
                mp.set_property_bool("pause", true)
            end
        else
            debug("We are the active window")
            -- Don't unpause automatically
        end
    end
end

-- Start the file watcher with delay
local function start_delayed_watcher()
    debug("Starting watcher with 5-second delay")
    
    -- Cancel any existing timer
    if file_check_timer then
        file_check_timer:kill()
    end
    
    -- Wait 5 seconds before starting
    mp.add_timeout(5, function()
        -- Get our stable ID
        get_stable_app_id()
        
        -- Check initial file state
        local file = io.open("/tmp/wayland_app_id.txt", "r")
        if file then
            last_seen_file_id = file:read("*l")
            file:close()
            debug("Initial active app ID: " .. (last_seen_file_id or "nil"))
        end
        
        -- Start periodic checks
        file_check_timer = mp.add_periodic_timer(1, check_file)
        initialized = true
        debug("File watcher now active")
    end)
end

-- Initialize on file load
mp.register_event("file-loaded", function()
    if not initialized then
        start_delayed_watcher()
    end
end)

-- Clean up on shutdown
mp.register_event("shutdown", function()
    if file_check_timer then
        file_check_timer:kill()
    end
end)
