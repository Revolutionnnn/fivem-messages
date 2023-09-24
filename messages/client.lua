Citizen.CreateThread(function()
    while true do
        -- Define el mensaje que deseas mostrar en el chat
        local mensaje = "¡Bienvenidos a nuestro servidor recuerda pasar por nuestro discord"
        -- Espera 15 minutos (900,000 milisegundos) antes de mostrar el siguiente mensaje
        local tiempo = 900000

        -- Envía el mensaje al chat de todos los jugadores en el servidor
        TriggerClientEvent('chatMessage', -1, "Servidor", { 255, 0, 0 }, mensaje)

        Citizen.Wait(tiempo)
    end
end)
