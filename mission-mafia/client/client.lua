local circleCenter = vector3(-1549.38, -89.44, 54.93)
local npcCoords = vector3(-1549.38, -89.44, 54.93)
local destinationPoint = vector3(-180.29, 884.56, 233.47)

-- Radio del círculo (ajusta según tus necesidades)
local circleRadius = 1.3
local destinationRadius = 10.0

local missionNPC = nil

local missionInProgress = false
local missionCompleted = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Obtén la posición del jugador más cercano
        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)
        local blip = AddBlipForCoord(npcCoords)
        SetBlipSprite(blip, 110)
        BeginTextCommandSetBlipName("MISION")
        AddTextComponentString("Mision Mafia")
        EndTextCommandSetBlipName(blip)

        -- Calcula la distancia entre el jugador y el centro del círculo
        local distance = #(playerCoords - circleCenter)

        -- Dibuja el marcador en el juego si el jugador está lo suficientemente cerca
        if distance <= circleRadius and not missionInProgress then
            DrawMarker(1, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0,
                circleRadius * 2.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)

            if not missionInProgress and not missionCompleted and #(playerCoords - npcCoords) <= destinationRadius then
                DisplayHelpText("Presiona ~INPUT_CONTEXT~ para hablar con el NPC.")
                OpenMissionDialogue()
                if IsControlJustReleased(0, 38) then
                    StartMission(destinationPoint)
                end
            end
        end

        -- Dibuja el marcador del destino solo cuando la misión está en progreso y el jugador está cerca
        if missionInProgress and not missionCompleted and #(playerCoords - destinationPoint) <= circleRadius then
            DrawMarker(1, destinationPoint.x, destinationPoint.y, destinationPoint.z - 1.0, 0, 0, 0, 0, 0, 0,
                circleRadius * 2.0,
                circleRadius * 2.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)
            DisplayHelpText("Presiona ~INPUT_CONTEXT~ para completar la misión.")
            if IsControlJustReleased(0, 38) then
                CompleteMission()
                TriggerServerEvent('mission-01:server:pay')
            end
        end
    end
end)


function StartMission()
    local npcs = {}
    local i = 0
    TriggerEvent('QBCore:Notify', 'Llega al punto de destino', 'error', 5000)
    SetNewWaypoint(destinationPoint.x, destinationPoint.y)
    missionInProgress = true


    Citizen.CreateThread(function()
        while missionInProgress and not missionCompleted do
            if not npcs[i] then
                npcs[i] = {} -- Inicializa npcs[i] como una tabla si aún no existe
            end

            if #npcs[i] < 5 then
                GenerateNPC(npcs[i])
            else
                missionCompleted = false
            end

            Citizen.Wait(1000) -- Esperar un segundo antes de verificar nuevamente
        end
    end)
end

function GenerateNPC(npcTable)
    local npcModel = "g_m_y_mexgoon_03"
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Citizen.Wait(1)
    end

    local separationDistance = 15.0
    local xOffset = math.random(-separationDistance, separationDistance)
    local yOffset = math.random(-separationDistance, separationDistance)
    local npc = CreatePed(4, npcModel, destinationPoint.x + xOffset, destinationPoint.y + yOffset, destinationPoint.z, 0,
        true, true)
    SetPedRelationshipGroupHash(npc, GetHashKey("HATES_PLAYER"))
    TaskCombatPed(npc, PlayerPedId(), 0, 1)
    SetPedAsCop(npc, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetEntityInvincible(npc, false)
    SetEntityHasGravity(npc, true)
    SetEntityCollision(npc, true, true)
    local weaponHash = GetHashKey("weapon_vintagepistol")
    GiveWeaponToPed(npc, weaponHash, 500, true, true)

    table.insert(npcTable, npc) -- Agregar el NPC generado a la lista
end

function CompleteMission()
    TriggerEvent('QBCore:Notify', 'Misión completada. ¡Bien hecho!', 'success', 5000)

    missionInProgress = false
    missionCompleted = true
    ClearGpsCustomRoute()
    ClearGpsPlayerWaypoint()
end

function DisplayHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
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
    if not missionCompleted then
        missionNPC = CreatePed(1, hash, destinationPoint.x, destinationPoint.y, destinationPoint.z - 1.0, 0.0, true, true)
        SetEntityInvincible(missionNPC, false) -- Hace que el NPC sea invulnerable
        FreezeEntityPosition(missionNPC, true) -- Hace que el NPC esté estático
        SetBlockingOfNonTemporaryEvents(missionNPC, true)
    end
end)

function OpenMissionDialogue()
    TriggerEvent("chatMessage", "Mafioso", { 255, 0, 0 }, "¡Hola! tengo un trabajo para ti")
    TriggerEvent("chatMessage", "Tú", { 0, 128, 255 }, "Sí jefe digame")
    TriggerEvent("chatMessage", "Mafioso", { 255, 0, 0 },
        "Joey La Serpiente Ricci ha cruzado la línea. Nos ha traicionado y ha vendido nuestra confianza al enemigo. Este es el trato, jefe. Deja que tus balas hablen.")
    TriggerEvent("chatMessage", "Mafioso", { 255, 0, 0 },
        "Una vez que hayas hecho el trabajo, asegúrate de que Joey reciba un mensaje claro. Deja una nota en su cuerpo que diga, 'Esto es por la familia'.")

    TriggerEvent("chatMessage", "Mafioso", { 255, 0, 0 },
        "Hazlo rápido y sin problemas. No podemos permitir que este tipo arruine nuestro imperio. Ahora ve y elimina esta amenaza.")
end
