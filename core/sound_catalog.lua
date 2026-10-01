local RLU = _G["RLU"]

local SOUND_DEFINITIONS = {
    { id = "rep_default", label = "Default Reputation" }, -- display label overridden at runtime with L.SOUND_DEFAULT_REPUTATION
    { id = "pokemon", label = "Pokemon" },
    { id = "final_fantasy", label = "Final Fantasy" },
    { id = "fire_emblem", label = "Fire Emblem" },
    { id = "fire_emblem_awakening", label = "Fire Emblem Awakening" },
    { id = "dragon_quest", label = "Dragon Quest" },
    { id = "warcraft_3", label = "Warcraft III" },
    { id = "diablo_2", label = "Diablo II" },
    { id = "everquest", label = "EverQuest" },
    { id = "ragnarok_online", label = "Ragnarok Online" },
    { id = "maplestory", label = "MapleStory" },
    { id = "old_school_runescape", label = "Old School RuneScape" },
    { id = "path_of_exile", label = "Path of Exile" },
    { id = "league_of_legends", label = "League of Legends" },
    { id = "dota_2", label = "Dota 2" },
    { id = "fortnite", label = "Fortnite" },
    { id = "minecraft", label = "Minecraft" },
    { id = "palworld", label = "Palworld" },
    { id = "kingdom_hearts_3", label = "Kingdom Hearts III" },
    { id = "castlevania", label = "Castlevania" },
    { id = "sonic_the_hedgehog", label = "Sonic the Hedgehog" },
    { id = "spyro_the_dragon", label = "Spyro the Dragon" },
    { id = "super_mario_bros_3", label = "Super Mario Bros. 3" },
    { id = "legends_of_zelda", label = "The Legend of Zelda" },
    { id = "kirby-1", label = "Kirby 1" },
    { id = "kirby-2", label = "Kirby 2" },
    { id = "metalgear_solid", label = "Metal Gear Solid" },
    { id = "modern_warfare_2", label = "Modern Warfare 2" },
    { id = "gta_san_andreas", label = "GTA San Andreas" },
    { id = "fallout_3", label = "Fallout 3" },
    { id = "fallout_new_vegas", label = "Fallout New Vegas" },
    { id = "morrowind", label = "Morrowind" },
    { id = "skyrim", label = "Skyrim" },
    { id = "witcher_3-1", label = "The Witcher 3 I" },
    { id = "witcher_3-2", label = "The Witcher 3 II" },
    { id = "elden_ring-1", label = "Elden Ring I" },
    { id = "elden_ring-2", label = "Elden Ring II" },
    { id = "elden_ring-3", label = "Elden Ring III" },
    { id = "elden_ring-4", label = "Elden Ring IV" },
    { id = "elden_ring-5", label = "Elden Ring V" },
    { id = "elden_ring-6", label = "Elden Ring VI" },
    { id = "shining_force_2", label = "Shining Force II" },
    { id = "shining_force_3-1", label = "Shining Force 3-1" },
    { id = "shining_force_3-2", label = "Shining Force 3-2" },
    { id = "shining_force_3-3", label = "Shining Force 3-3" },
    { id = "shining_force_3-4", label = "Shining Force 3-4" },
    { id = "shining_force_3-5", label = "Shining Force 3-5" },
    { id = "shining_force_3-6", label = "Shining Force 3-6" },
    { id = "shining_force_3-7", label = "Shining Force 3-7" },
    { id = "shining_force_3-8", label = "Shining Force 3-8" },
    { id = "shining_force_3-9", label = "Shining Force 3-9" },
    { id = "shining_force_3-10", label = "Shining Force 3-10" },
    { id = "shining_force_3-11", label = "Shining Force 3-11" },
}

RLU.SoundCatalog = {
    defaultSoundId = "rep_default",
    items = {},
    order = {},
}

function RLU:GetQualityLabel(quality)
    if quality == "low" then
        return self:Locale("QUALITY_LOW")
    elseif quality == "high" then
        return self:Locale("QUALITY_HIGH")
    end
    return self:Locale("QUALITY_MED")
end

local function BuildPath(id, quality)
    return "Interface\\AddOns\\ReputationLevelUp\\sounds\\" .. id .. "_" .. quality .. ".ogg"
end

for _, entry in ipairs(SOUND_DEFINITIONS) do
    local sound = {
        id = entry.id,
        label = entry.label,
        files = {
            low = BuildPath(entry.id, "low"),
            med = BuildPath(entry.id, "med"),
            high = BuildPath(entry.id, "high"),
        },
    }

    RLU.SoundCatalog.items[entry.id] = sound
    RLU.SoundCatalog.order[#RLU.SoundCatalog.order + 1] = sound
end

function RLU:GetSoundCatalog()
    return self.SoundCatalog
end

function RLU:GetSoundInfo(soundId)
    local catalog = self:GetSoundCatalog()
    local sound = catalog.items[soundId or catalog.defaultSoundId] or catalog.items[catalog.defaultSoundId]
    if sound and sound.id == catalog.defaultSoundId then
        sound.label = self:Locale("SOUND_DEFAULT_REPUTATION")
    end
    return sound
end

function RLU:GetSoundFile(soundId, quality)
    local sound = self:GetSoundInfo(soundId)
    local selectedQuality = quality or (self.db and self.db.profile and self.db.profile.defaultSoundQuality) or "med"
    return sound and sound.files and sound.files[selectedQuality]
end

function RLU:IterateSounds()
    return ipairs(self.SoundCatalog.order)
end
