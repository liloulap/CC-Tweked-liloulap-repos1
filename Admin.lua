-- Nom du fichier à envoyer
local function getFileName()
    print("Entrez le nom du fichier à envoyer :")
    return read()
end

-- Lecture du contenu du fichier
local function readFile(fileName)
    if not fs.exists(fileName) then
        print("Fichier non trouvé : " .. fileName)
        return nil
    end
    local file = fs.open(fileName, "r")
    local content = file.readAll()
    file.close()
    return content
end

-- Envoi du fichier via rednet
local function sendFile(fileName, content)
    print("Envoi du fichier '" .. fileName .. "'...")
    local modem = peripheral.find("modem")
    if not modem then
        print("Aucun modem détecté. Connectez un modem et réessayez.")
        return false
    end

    rednet.open(peripheral.getName(modem)) -- Ouvre rednet sur le modem trouvé

    local senderId = os.getComputerID()
    rednet.broadcast({
        type = "file_transfer",
        fileName = fileName,
        content = content
    }, "file_transfer")

    print("Fichier envoyé à tous les ordinateurs connectés.")
    rednet.close()
    return true
end

-- Programme principal
local function main()
    local fileName = getFileName()
    local content = readFile(fileName)
    if content then
        sendFile(fileName, content)
    else
        print("Erreur : Impossible de lire le fichier.")
    end
end

main()
