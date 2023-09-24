local circleCenter = vector3(211.16, -945.61, 30.69)
local npcCoords = vector3(211.16, -945.61, 30.69)
local destinationPoint = vector3(222.11, -947.04, 30.09)

-- Radio del círculo (ajusta según tus necesidades)
local circleRadius = 1.5
local destinationRadius = 10.0

local missionNPC = nil

local missionInProgress = false
local missionMarkerVisible = false -- Variable para controlar la visibilidad del marcador

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Obtén la posición del jugador más cercano
        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)

        -- Calcula la distancia entre el jugador y el centro del círculo
        local distance = #(playerCoords - circleCenter)

        -- Dibuja el marcador en el juego si el jugador está lo suficientemente cerca
        if distance <= circleRadius then
            DrawMarker(1, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0,
                circleRadius * 2.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)

            if not missionInProgress and #(playerCoords - npcCoords) <= destinationRadius then
                DisplayHelpText("Presiona ~INPUT_CONTEXT~ para hablar con el NPC.")
                if IsControlJustReleased(0, 38) then
                    StartMission()
                end
            end
        else
            -- Si está fuera del círculo, muestra el marcador del destino si está en misión
            if missionInProgress then
                missionMarkerVisible = true
            else
                missionMarkerVisible = false
            end
        end

        -- Dibuja el marcador del destino si missionMarkerVisible es true
        if missionMarkerVisible then
            DrawMarker(1, destinationPoint.x, destinationPoint.y, destinationPoint.z - 1.0, 0, 0, 0, 0, 0, 0,
                circleRadius * 2.0,
                circleRadius * 2.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)
            DisplayHelpText("Presiona ~INPUT_CONTEXT~ para completar la misión.")
            if IsControlJustReleased(0, 38) then
                TriggerServerEvent('mission-01:server:pay')
                CompleteMission()
                missionMarkerVisible = false
            end
        end
    end
end)




function StartMission()
    TriggerEvent('QBCore:Notify', 'Llega al punto de destino', 'error', 5000)
    SetNewWaypoint(destinationPoint.x, destinationPoint.y)
    missionInProgress = true
end

function CompleteMission()
    TriggerEvent('QBCore:Notify', 'Misión completada. ¡Bien hecho!', 'success', 5000)

    missionInProgress = false
    ClearGpsMultiRoute()
    ClearGpsPlayerWaypoint()
end

function DisplayHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- No tiene utilidad esta funcion pero podria ser agregada si quieres agregarle dialogos al NPC
function OpenMissionDialogue()
    TriggerEvent("chatMessage", "NPC", { 255, 0, 0 }, "¡Hola! ¿En qué puedo ayudarte?")
    TriggerEvent("chatMessage", "Tú", { 0, 128, 255 }, "Sí")
end

-- Crea el NPC estático
Citizen.CreateThread(function()
    local hash = GetHashKey("a_m_y_business_02")
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Citizen.Wait(1)
    end

    missionNPC = CreatePed(1, hash, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, 0.0, true, true)
    SetEntityInvincible(missionNPC, true) -- Hace que el NPC sea invulnerable
    SetEntityAsMissionEntity(missionNPC, true, true)
    SetEntityCollision(missionNPC, false, false)
    FreezeEntityPosition(missionNPC, true) -- Hace que el NPC esté estático
end)
