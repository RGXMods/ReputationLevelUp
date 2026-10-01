local RLU = _G["RLU"]

local function BuildDefaultSoundDropdown(parent, yOffset, panel)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 4, yOffset)
    label:SetText(RLU:Locale("DEFAULT_SOUND"))

    local dropdown = CreateFrame("Frame", "RLUDefaultSoundDropdown", parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -16, -6)
    UIDropDownMenu_SetWidth(dropdown, 260)

    UIDropDownMenu_Initialize(dropdown, function(self, level)
        level = level or 1

        for _, sound in RLU:IterateSounds() do
            local info = UIDropDownMenu_CreateInfo()
            local soundLabel = RLU:GetSoundLabel(sound.id)
            info.text = soundLabel
            info.checked = RLU:GetSetting("defaultSoundId") == sound.id
            info.func = function()
                RLU:SetSetting("defaultSoundId", sound.id)
                UIDropDownMenu_SetText(dropdown, RLU:GetSoundLabel(sound.id))
                if panel and panel.RefreshGeneral then
                    panel:RefreshGeneral()
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    UIDropDownMenu_SetText(dropdown, RLU:GetSoundLabel(RLU:GetSetting("defaultSoundId")))
    return dropdown
end

local function BuildQualitySlider(parent, yOffset, panel)
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", 4, yOffset)
    container:SetSize(260, 44)

    local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetText(RLU:Locale("DEFAULT_QUALITY"))

    local slider = CreateFrame("Slider", nil, container, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    slider:SetWidth(160)
    slider:SetMinMaxValues(1, 3)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider.Low:SetText("")
    slider.High:SetText("")
    slider.Text:SetText("")

    local valueLabel = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueLabel:SetPoint("LEFT", slider, "RIGHT", 8, 0)

    local valueMap = {
        [1] = "low",
        [2] = "med",
        [3] = "high",
    }

    local function SetStep(step)
        slider:SetValue(step)
        valueLabel:SetText(RLU:FormatQualityLabel(valueMap[step]))
    end

    slider:SetScript("OnValueChanged", function(self, value)
        local step = math.floor((value or 2) + 0.5)
        if step < 1 then step = 1 end
        if step > 3 then step = 3 end
        local quality = valueMap[step]
        RLU:SetSetting("defaultSoundQuality", quality)
        valueLabel:SetText(RLU:FormatQualityLabel(quality))
        if panel and panel.RefreshGeneral then
            panel:RefreshGeneral()
        end
    end)

    local initialQuality = RLU:GetSetting("defaultSoundQuality") or "med"
    local initialStep = 2
    for step, quality in pairs(valueMap) do
        if quality == initialQuality then
            initialStep = step
            break
        end
    end
    SetStep(initialStep)
    return container
end

function RLU.CreateGeneralPanel(panel)
    local section = RLU.CreateSection(panel, RLU:Locale("GENERAL"))
    section:SetPoint("TOPLEFT", 12, -12)
    section:SetPoint("TOPRIGHT", -12, -12)
    section:SetPoint("BOTTOMRIGHT", -12, 12)

    local title = section.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOPLEFT", 0, 0)
    title:SetWidth(620)
    title:SetJustifyH("LEFT")
    title:SetText(RLU:Locale("GENERAL_INTRO"))

    local welcome = RLU.CreateCheckbox(section.content, RLU:Locale("SHOW_LOGIN_MESSAGE"), RLU:GetSetting("showWelcomeMessage"), function(checked)
        RLU:SetSetting("showWelcomeMessage", checked and true or false)
    end)
    welcome:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -4, -18)

    local debug = RLU.CreateCheckbox(section.content, RLU:Locale("ENABLE_DEBUG_MODE"), RLU:GetSetting("debugMode"), function(checked)
        RLU:SetSetting("debugMode", checked and true or false)
        RLU.debugMode = checked and true or false
    end)
    debug:SetPoint("TOPLEFT", welcome, "BOTTOMLEFT", 0, -8)

    local defaultDropdown = BuildDefaultSoundDropdown(section.content, -120, panel)
    local qualityControl = BuildQualitySlider(section.content, -200, panel)
    qualityControl:SetPoint("TOPLEFT", defaultDropdown, "BOTTOMLEFT", 16, -18)

    local testButton = RLU.CreateSimpleButton(section.content, RLU:Locale("TEST_DEFAULT"), 100, 24)
    testButton:SetPoint("TOPLEFT", qualityControl, "BOTTOMLEFT", -4, -18)
    testButton:SetScript("OnClick", function()
        local module = RLU.Modules and RLU.Modules.reputation
        if module and module.PlayAssignedSound then
            module:PlayAssignedSound(nil, {
                enabled = true,
                soundId = RLU:GetSetting("defaultSoundId"),
                quality = RLU:GetSetting("defaultSoundQuality"),
            })
        end
    end)

    local status = section.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("LEFT", testButton, "RIGHT", 12, 0)
    status:SetWidth(420)
    status:SetJustifyH("LEFT")
    status:SetText(RLU:Locale("CURRENT_DEFAULT") .. "|cff3bbc00" .. RLU:GetSoundLabel(RLU:GetSetting("defaultSoundId")) .. "|r / " .. RLU:FormatQualityLabel(RLU:GetSetting("defaultSoundQuality")))

    panel.RefreshGeneral = function()
        UIDropDownMenu_SetText(defaultDropdown, RLU:GetSoundLabel(RLU:GetSetting("defaultSoundId")))
        status:SetText(RLU:Locale("CURRENT_DEFAULT") .. "|cff3bbc00" .. RLU:GetSoundLabel(RLU:GetSetting("defaultSoundId")) .. "|r / " .. RLU:FormatQualityLabel(RLU:GetSetting("defaultSoundQuality")))
    end
end
