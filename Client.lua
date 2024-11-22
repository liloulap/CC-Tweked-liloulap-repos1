-- Dossier où sauvegarder les fichiers reçus
local saveFolder = "Téléchargements"

-- Création du dossier si nécessaire
if not fs.exists(saveFolder) then
    fs.makeDir(saveFolder)
end

-- Ouverture du modem
rednet.open("back") -- Assurez-vous que le modem est branché à l'arrière

print("En attente d'un fichier...")

while true do
    -- Réception des métadonnées
    local senderID, message = rednet.receive()

    if message.action == "start" then
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
