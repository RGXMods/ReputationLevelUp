local RLU = _G["RLU"]

function RLU:HandleSlashCommand(input)
    input = string.lower((input or ""):gsub("^%s+", ""):gsub("%s+$", ""))

    if input == "" then
        self:OpenOptions()
        return
    end

    if input == "help" then
        self:Print(self:Locale("HELP_COMMANDS"))
        return
    end

    if input == "debug" then
        local enabled = self:ToggleSetting("debugMode")
        self.debugMode = enabled
        if enabled then
            self:Print(self:Locale("DEBUG_ENABLED"))
        else
            self:Print(self:Locale("DEBUG_DISABLED"))
        end
        return
    end

    if input == "welcome" then
        local enabled = self:ToggleSetting("showWelcomeMessage")
        if enabled then
            self:Print(self:Locale("LOGIN_ENABLED"))
        else
            self:Print(self:Locale("LOGIN_DISABLED"))
        end
        return
    end

    if input == "status" then
        self:Print(self:Locale("STATUS_SELECTED_EXPANSION") .. "|cffffffff" .. (self:GetSelectedExpansion().label or self:Locale("QUALITY_UNKNOWN")) .. "|r")
        self:Print(self:Locale("STATUS_DEFAULT_SOUND") .. "|cffffffff" .. self:GetSoundLabel(self:GetSetting("defaultSoundId")) .. "|r (" .. self:FormatQualityLabel(self:GetSetting("defaultSoundQuality")) .. ")")
        return
    end

    if input == "test" then
        local module = self.Modules and self.Modules.reputation
        if module and module.PlayAssignedSound then
            module:PlayAssignedSound(nil, self:GetEffectiveAssignment(0))
        else
            self:PrintError("Reputation sound module is not available yet.")
        end
        return
    end

    self:OpenOptions()
end

RLU:RegisterSlashCommand({ "rlu", "rep" }, function(msg)
    RLU:HandleSlashCommand(msg)
end)
