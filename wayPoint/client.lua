local missionInProgress = false

RegisterCommand('mision', function()
    if missionInProgress then
        -- Si la misión está en progreso, cancelarla
        missionInProgress = false
        ClearGpsPlayerWaypoint() -- Eliminar el punto de destino del GPS
        TriggerEvent('QBCore:Notify', 'Misión cancelada', 'error', 5000) -- Mensaje de notificación
    else
        -- Si no hay una misión en progreso, comenzarla
        missionInProgress = true
        local missionDestination = vector3(211.16, -945.61, 30.69)
        SetNewWaypoint(missionDestination.x, missionDestination.y)
        TriggerEvent('QBCore:Notify', 'Misión iniciada', 'success', 5000) -- Mensaje de notificación
    end
end)
