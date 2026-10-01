local RLU = _G["RLU"]

function RLU:CreateOptionsPanel()
    if self.OptionsPanel then
        return self.OptionsPanel
    end

    local panel = CreateFrame("Frame", "RLUOptionsPanel", UIParent, "BackdropTemplate")
    panel.name = self:Locale("PANEL_NAME")
    panel.settingsCategoryName = "|TInterface\\AddOns\\ReputationLevelUp\\media\\Textures\\icon:16:16:0:0|t |cff3bbc00R|r|cffffffffeputation |cff3bbc00L|r|cffffffffevel-|cff3bbc00U|r|cffffffffp|cff3bbc00!|r"
    self.OptionsPanel = panel

    local container = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    container:SetPoint("TOPLEFT", 0, 0)
    container:SetPoint("BOTTOMRIGHT", 0, 0)
    container:SetBackdrop(self.Design.Backdrops.Dark)
    container:SetBackdropColor(unpack(self.Brand.colors.bg))
    container:SetBackdropBorderColor(unpack(self.Brand.colors.primary))

    local header = CreateFrame("Frame", nil, container, "BackdropTemplate")
    header:SetPoint("TOPLEFT", 8, -8)
    header:SetPoint("TOPRIGHT", -8, -8)
    header:SetHeight(64)
    header:SetBackdrop(self.Design.Backdrops.Dark)
    header:SetBackdropColor(unpack(self.Brand.colors.panel))
    header:SetBackdropBorderColor(unpack(self.Brand.colors.primary))

    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(36, 36)
    icon:SetPoint("LEFT", 12, 0)
    icon:SetTexture("Interface\\AddOns\\ReputationLevelUp\\media\\Textures\\icon.tga")

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 6)
    title:SetText(self:Locale("OPTIONS_TITLE"))

    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    subtitle:SetText(self:Locale("OPTIONS_SUBTITLE"))
    subtitle:SetTextColor(unpack(self.Brand.colors.muted))

    local tabs = {}
    local contents = {}
    local previous
    for index, tabInfo in ipairs(self.OptionsTabs) do
        local button = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        button:SetSize(120, 24)
        if previous then
            button:SetPoint("TOPLEFT", previous, "TOPRIGHT", 8, 0)
        else
            button:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
        end
        button:SetText(tabInfo.text)
        previous = button
        tabs[index] = button

        local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
        content:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -8)
        content:SetPoint("BOTTOMRIGHT", -8, 8)
        content:SetBackdrop(self.Design.Backdrops.Dark)
        content:SetBackdropColor(unpack(self.Brand.colors.panel))
        content:SetBackdropBorderColor(unpack(self.Brand.colors.primary))
        content:Hide()
        contents[index] = content

        if tabInfo.create then
            tabInfo.create(content)
        end

        button:SetScript("OnClick", function()
            panel:SelectTab(index)
        end)
    end

    panel.tabs = tabs
    panel.contents = contents

    function panel:SelectTab(index)
        for i = 1, #self.tabs do
            self.contents[i]:SetShown(i == index)
        end
    end

    panel:SelectTab(1)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.settingsCategoryName)
        Settings.RegisterAddOnCategory(category)
        self.OptionsCategory = category
    else
        InterfaceOptions_AddCategory(panel)
        self.OptionsCategory = panel
    end

    return panel
end

function RLU:OpenOptions()
    if not self.OptionsPanel then
        self:CreateOptionsPanel()
    end

    if Settings and Settings.OpenToCategory and self.OptionsPanel.settingsCategoryName then
        Settings.OpenToCategory(self.OptionsPanel.settingsCategoryName)
        return
    end

    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
        InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
    end
end
