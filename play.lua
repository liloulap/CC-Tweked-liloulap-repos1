-- Nom du fichier audio (assurez-vous qu'il est présent dans le même dossier que ce script)
local audioFile = "Aron Smith-Dancin Speed Up🩷🫶🏼.dfpwm"

-- Vérifie si le fichier audio existe
if not fs.exists(audioFile) then
    print("Fichier audio introuvable : " .. audioFile)
    return
end

-- Charge le fichier audio
local handle = fs.open(audioFile, "rb")
local audioData = handle.readAll()
handle.close()

-- Cherche toutes les enceintes connectées
local speakers = {}
for _, side in ipairs(rs.getSides()) do
    if peripheral.getType(side) == "speaker" then
        table.insert(speakers, peripheral.wrap(side))
    end
end

if #speakers == 0 then
    print("Aucune enceinte connectée trouvée.")
    return
end

print("Enceintes trouvées : " .. #speakers)

-- Fonction pour diffuser l'audio sur une enceinte
local function playOnSpeaker(speaker, data)
    local decoder = audio.dfpwm.make_decoder()
    for chunk in decoder(data) do
        while not speaker.playAudio(chunk) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

-- Diffuse l'audio sur toutes les enceintes
print("Diffusion en cours...")
parallel.waitForAll(
    function()
        for _, speaker in ipairs(speakers) do
            playOnSpeaker(speaker, audioData)
        end
    end
)

print("Lecture terminée.")
