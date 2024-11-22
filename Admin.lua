-- Ouverture du modem
rednet.open("back") -- Assurez-vous que le modem est branché à l'arrière

-- Demander l'ID du client
print("Entrez l'ID de l'ordinateur client :")
local clientID = tonumber(read())

-- Lister les fichiers disponibles
local files = fs.list(".")
print("\nFichiers disponibles :")
for i, file in ipairs(files) do
    print(i .. ". " .. file)
end

-- Demander quel fichier envoyer
print("\nEntrez le numéro du fichier à envoyer :")
local choice = tonumber(read())

local fileName = files[choice]
if not fileName or not fs.exists(fileName) then
    print("Fichier invalide.")
    return
end

-- Lire le contenu du fichier
local file = fs.open(fileName, "r")
local fileData = file.readAll()
file.close()

-- Envoi des métadonnées
rednet.send(clientID, {action = "start", fileName = fileName})

-- Attente de confirmation
local senderID, message = rednet.receive(5)
if message ~= "ready" then
    print("Le client n'est pas prêt.")
    return
end

-- Envoi des données
rednet.send(clientID, {action = "data", content = fileData})

-- Confirmation finale
senderID, message = rednet.receive(5)
if message == "done" then
    print("Fichier '" .. fileName .. "' envoyé avec succès.")
else
    print("Erreur lors de l'envoi.")
end
