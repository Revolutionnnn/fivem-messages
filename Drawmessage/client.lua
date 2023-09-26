local function examplefunction()
    TriggerEvent('qb-core:client:DrawText', 'This is a test', 'left')
    Wait(5000) -- display text for 5 seconds
    TriggerEvent('qb-core:client:HideText')
end
RegisterCommand('draw', function()
    examplefunction()
end)
