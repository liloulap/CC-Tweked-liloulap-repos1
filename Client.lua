-- Dossier où sauvegarder les fichiers reçus
local saveFolder = "Téléchargements"

-- Création du dossier si nécessaire
if not fs.exists(saveFolder) then
    fs.makeDir(saveFolder)
end

-- Ouverture du modem
rednet.open("back") -- Assurez-vous que le modem est connecté

print("En attente d'une connexion ou d'un fichier...")

while true do
    -- Réception des messages
    local senderID, message = rednet.receive()

    if message.action == "ping" then
        -- Réponse au ping
        rednet.send(senderID, "pong")
    elseif message.action == "start" then
        local fileName = message.fileName
        print("Préparation pour recevoir : " .. fileName)

        -- Confirmation de réception des métadonnées
        rednet.send(senderID, "ready")

        -- Réception des données
        senderID, message = rednet.receive()
        if message.action == "data" then
            local content = message.content

            -- Sauvegarde du fichier reçu
            local file = fs.open(saveFolder .. "/" .. fileName, "w")
            file.write(content)
            file.close()

            print("Fichier reçu et sauvegardé dans " .. saveFolder .. "/" .. fileName)

            -- Confirmation finale
            rednet.send(senderID, "done")
        end
    end
end
