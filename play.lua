-- URL du fichier DFPWM
local audioURL = "https://github.com/liloulap/CC-Tweked-liloulap-repos1/raw/refs/heads/main/Dancin.dfpwm"
local audioFile = "Dancin.dfpwm" -- Nom du fichier local

-- Télécharge le fichier audio s'il n'est pas déjà présent
if not fs.exists(audioFile) then
    print("Téléchargement du fichier audio...")
    local ok, err = pcall(function()
        shell.run("wget", audioURL, audioFile)
    end)
    if not ok then
        print("Échec du téléchargement : " .. (err or "Erreur inconnue"))
        return
    end
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
