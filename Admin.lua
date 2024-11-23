-- Ouverture du modem
rednet.open("back") -- Assurez-vous que le modem est connecté

-- Fonction pour découvrir les clients disponibles
local function discoverClients()
    print("Recherche de clients actifs...")
    rednet.broadcast({action = "ping"}) -- Envoi d'un signal de découverte

    local clients = {}
    local timer = os.startTimer(5) -- Temps d'attente de 5 secondes
    while true do
        local event, senderID, message = os.pullEvent()
        if event == "rednet_message" and message == "pong" then
            table.insert(clients, senderID)
        elseif event == "timer" and senderID == timer then
            break
        end
    end

    return clients
end

-- Recherche des clients
local clients = discoverClients()

if #clients == 0 then
    print("Aucun client trouvé.")
    return
else
    print("Clients disponibles :")
    for i, client in ipairs(clients) do
        print(i .. ". ID : " .. client)
    end
end

-- Sélection du client
print("\nEntrez le numéro du client cible :")
local choice = tonumber(read())
local clientID = clients[choice]

if not clientID then
    print("Choix invalide.")
    return
end

-- Lister les fichiers disponibles
local files = fs.list(".")
print("\nFichiers disponibles :")
for i, file in ipairs(files) do
    print(i .. ". " .. file)
end

-- Sélection du fichier à envoyer
print("\nEntrez le numéro du fichier à envoyer :")
local choice = tonumber(read())
local fileName = files[choice]

if not fileName or not fs.exists(fileName) then
    print("Fichier invalide.")
    return
end

-- Lecture du contenu du fichier
local file = fs.open(fileName, "r")
local fileData = file.readAll()
file.close()

-- Envoi des métadonnées au client
rednet.send(clientID, {action = "start", fileName = fileName})

-- Attente de confirmation du client
local senderID, message = rednet.receive(5)
if message ~= "ready" then
    print("Le client n'a pas répondu.")
    return
end

-- Envoi des données au client
rednet.send(clientID, {action = "data", content = fileData})

-- Attente de confirmation finale
senderID, message = rednet.receive(5)
if message == "done" then
    print("Fichier '" .. fileName .. "' envoyé avec succès.")
else
    print("Erreur lors de l'envoi.")
end
