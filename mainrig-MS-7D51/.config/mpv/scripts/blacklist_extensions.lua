local blacklist = {'txt', 'jpg', 'png', 'webp'}

local temp = {}
for _, ext in pairs(blacklist) do
    temp[ext] = true
end
blacklist = temp

function removeBlacklistedFiles()
    local playlist = mp.get_property_native('playlist')
    for i = #playlist, 1, -1 do
        if blacklist[playlist[i].filename:lower():match('%.(%w+)$')] then
            mp.commandv('playlist-remove', i-1)
        end
    end
end

mp.register_event('start-file', removeBlacklistedFiles)

mp.observe_property('playlist-count', 'native', function (_, count)
    if count == 1 then
        removeBlacklistedFiles()  -- Call the function when there's only one file in the playlist
        return
    end
end)
