w-- place-current-file-path-in-tmp.lua
local filepath = "/var/tmp/current_mpv_file"

function on_file_loaded()
    local path = mp.get_property("path")
    local working_directory = mp.get_property("working-directory")

    if path and working_directory then
        -- Convert relative path to absolute path
        if string.sub(path, 1, 2) == "./" then
            path = working_directory .. "/" .. string.sub(path, 3)
        elseif not string.match(path, "^/") then
            path = working_directory .. "/" .. path
        end

        local file = io.open(filepath, "w")
        file:write(path)
        file:close()
    else
        print("Error: Unable to retrieve the file path or working directory.")
    end
end

mp.register_event("file-loaded", on_file_loaded)
