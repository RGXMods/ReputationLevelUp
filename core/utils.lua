local RLU = _G["RLU"]

-- Locale string accessor. Always returns a usable string: the enUS base table
-- defines every key, so even a missing or partial locale override file degrades
-- cleanly to enUS with no nil access at any consumption site.
function RLU:Locale(key)
    return (self.L and self.L[key]) or key
end

function RLU:GetSetting(key)
    if not self.db or not self.db.profile then
        return nil
    end
    return self.db.profile[key]
end

function RLU:SetSetting(key, value)
    if not self.db or not self.db.profile then
        return
    end
    self.db.profile[key] = value
end

function RLU:ToggleSetting(key)
    local current = self:GetSetting(key)
    self:SetSetting(key, not current)
    return not current
end

function RLU:GetBrandColorHex()
    return "3bbc00"
end

function RLU:FormatQualityLabel(quality)
    if self.GetQualityLabel then
        return self:GetQualityLabel(quality)
    end
    return quality or self:Locale("QUALITY_MEDIUM_FALLBACK")
end

function RLU:GetSoundLabel(soundId)
    local sound = self:GetSoundInfo(soundId)
    if sound and sound.label then
        if sound.id == self.SoundCatalog.defaultSoundId then
            return self:Locale("SOUND_DEFAULT_REPUTATION")
        end
        return sound.label
    end
    return self:Locale("QUALITY_UNKNOWN")
end

function RLU:GetFactionDisplayText(faction)
    if not faction then
        return self:Locale("UNKNOWN_FACTION")
    end

    return faction.name or ("Faction " .. tostring(faction.id))
end
