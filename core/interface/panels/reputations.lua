local RLU = _G["RLU"]

local function RefreshReputationPanel(panel)
    if panel.RefreshContent then
        panel:RefreshContent()
    end
end

local function OpenAssignmentMenu(panel, anchor, faction)
    local assignment = RLU:GetEffectiveAssignment(faction.id)
    local menu = {
        {
            text = faction.name,
            isTitle = true,
            notCheckable = true,
        },
        {
            text = RLU:Locale("USE_DEFAULT_ASSIGNMENT"),
            notCheckable = true,
            func = function()
                RLU:ClearReputationAssignment(faction.id)
                RefreshReputationPanel(panel)
            end,
        },
        {
            text = RLU:Locale("SOUND_PACKS"),
            notCheckable = true,
            hasArrow = true,
            menuList = {},
        },
        {
            text = RLU:Locale("QUALITY"),
            notCheckable = true,
            hasArrow = true,
            menuList = {},
        },
    }

    for _, sound in RLU:IterateSounds() do
        menu[3].menuList[#menu[3].menuList + 1] = {
            text = RLU:GetSoundLabel(sound.id),
            notCheckable = false,
            checked = assignment.soundId == sound.id,
            func = function()
                RLU:SetReputationAssignment(faction.id, {
                    enabled = true,
                    soundId = sound.id,
                    quality = RLU:GetEffectiveAssignment(faction.id).quality,
                })
                RefreshReputationPanel(panel)
            end,
        }
    end

    local qualityOrder = { "low", "med", "high" }
    for _, quality in ipairs(qualityOrder) do
        menu[4].menuList[#menu[4].menuList + 1] = {
            text = RLU:FormatQualityLabel(quality),
            notCheckable = false,
            checked = assignment.quality == quality,
            func = function()
                local current = RLU:GetEffectiveAssignment(faction.id)
                RLU:SetReputationAssignment(faction.id, {
                    enabled = true,
                    soundId = current.soundId,
                    quality = quality,
                })
                RefreshReputationPanel(panel)
            end,
        }
    end

    if not RLU.ReputationAssignmentMenu then
        RLU.ReputationAssignmentMenu = CreateFrame("Frame", "RLUReputationAssignmentMenu", UIParent, "UIDropDownMenuTemplate")
    end

    EasyMenu(menu, RLU.ReputationAssignmentMenu, anchor, 0, 0, "MENU", 2)
end

function RLU.CreateReputationsPanel(panel)
    local expansions = RLU:GetExpansionGroups(true)
    local section = RLU.CreateSection(panel, RLU:Locale("REPUTATIONS"))
    section:SetPoint("TOPLEFT", 12, -12)
    section:SetPoint("TOPRIGHT", -12, -12)
    section:SetPoint("BOTTOMRIGHT", -12, 12)

    local intro = section.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    intro:SetPoint("TOPLEFT", 0, 0)
    intro:SetText(RLU:Locale("REPUTATIONS_INTRO"))

    local listFrame = CreateFrame("Frame", nil, section.content)
    listFrame:SetPoint("TOPLEFT", intro, "BOTTOMLEFT", 0, -16)
    listFrame:SetPoint("BOTTOMRIGHT", 0, 0)

    local expansionButtons = {}
    local previousButton
    for index, expansion in ipairs(expansions) do
        local button = CreateFrame("Button", nil, listFrame, "UIPanelButtonTemplate")
        button:SetSize(132, 22)
        if previousButton then
            button:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, -6)
        else
            button:SetPoint("TOPLEFT", 0, 0)
        end
        button:SetText(expansion.label)
        button:SetScript("OnClick", function()
            RLU:SetSetting("selectedExpansion", expansion.id)
            RefreshReputationPanel(panel)
        end)
        expansionButtons[index] = button
        previousButton = button
    end

    local rows = {}
    for index = 1, 40 do
        local row = CreateFrame("Frame", nil, listFrame, "BackdropTemplate")
        row:SetSize(520, 36)
        if index == 1 then
            row:SetPoint("TOPLEFT", 150, 0)
        else
            row:SetPoint("TOPLEFT", rows[index - 1], "BOTTOMLEFT", 0, -6)
        end
        row:SetBackdrop(RLU.Design.Backdrops.Dark)
        row:SetBackdropColor(0.10, 0.14, 0.10, 0.90)
        row:SetBackdropBorderColor(unpack(RLU.Brand.colors.primary))

        row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.label:SetPoint("LEFT", 10, 0)
        row.label:SetWidth(180)
        row.label:SetJustifyH("LEFT")

        row.assignment = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.assignment:SetPoint("LEFT", row.label, "RIGHT", 10, 0)
        row.assignment:SetWidth(180)
        row.assignment:SetJustifyH("LEFT")

        row.assignButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.assignButton:SetSize(80, 22)
        row.assignButton:SetPoint("RIGHT", -90, 0)
        row.assignButton:SetText(RLU:Locale("ASSIGN"))

        row.testButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.testButton:SetSize(60, 22)
        row.testButton:SetPoint("RIGHT", -12, 0)
        row.testButton:SetText(RLU:Locale("TEST"))

        rows[index] = row
    end

    panel.RefreshContent = function()
        local expansion = RLU:GetSelectedExpansion()

        for _, button in ipairs(expansionButtons) do
            local active = button:GetText() == expansion.label
            if active then
                button:GetFontString():SetTextColor(unpack(RLU.Brand.colors.primary))
            else
                button:GetFontString():SetTextColor(1, 1, 1)
            end
        end

        for index, row in ipairs(rows) do
            local faction = expansion.reputations[index]
            if faction then
                local assignment = RLU:GetEffectiveAssignment(faction.id)
                row:Show()
                row.label:SetText(faction.name)
                row.assignment:SetText(RLU:GetSoundLabel(assignment.soundId) .. " / " .. RLU:FormatQualityLabel(assignment.quality))
                row.assignButton:SetScript("OnClick", function(self)
                    OpenAssignmentMenu(panel, self, faction)
                end)
                row.testButton:SetScript("OnClick", function()
                    local module = RLU.Modules and RLU.Modules.reputation
                    if module and module.PlayAssignedSound then
                        module:PlayAssignedSound(faction, assignment)
                    end
                end)
            else
                row:Hide()
            end
        end
    end

    panel:RefreshContent()
end
