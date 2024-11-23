while true do
    -- Réception de messages
    local senderID, message = rednet.receive()

    if message.action == "ping" then
        -- Répondre au ping
        rednet.send(senderID, "pong")
    elseif message.action == "start" then
        -- Gestion normale des fichiers (comme précédemment)
        local fileName = message.fileName
        print("Préparation pour recevoir : " .. fileName)

        -- Confirmation de réception
        rednet.send(senderID, "ready")

        -- Réception du contenu
        senderID, message = rednet.receive()
        if message.action == "data" then
            local content = message.content

            -- Sauvegarde du fichier
            local file = fs.open(saveFolder .. "/" .. fileName, "w")
            file.write(content)
            file.close()

            print("Fichier reçu et sauvegardé dans " .. saveFolder .. "/" .. fileName)

            -- Confirmation finale
            rednet.send(senderID, "done")
        end
    end
end
