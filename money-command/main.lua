local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('money', function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.Functions.AddMoney('bank', 1000)
        TriggerClientEvent('QBCore:Notify', source, 'Has recibido $1000 en tu cuenta bancaria', 'success', 5000)
    else
        TriggerClientEvent('QBCore:Notify', source, 'Error', 'success', 5000)
    end
end, false)
