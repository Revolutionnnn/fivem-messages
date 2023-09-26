RegisterCommand('3dtext', function(_, args)
    local message = table.concat(args, ' ')
    TriggerEvent('QBCore:Command:ShowMe3D', PlayerId(), message)
end)
