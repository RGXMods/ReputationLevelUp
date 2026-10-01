local RLU = _G["RLU"]

function RLU.CreateSimpleButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 120, height or 24)
    button:SetText(text or RLU:Locale("BUTTON_FALLBACK"))
    return button
end

function RLU.CreateSection(parent, title)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetBackdrop(RLU.Design.Backdrops.Dark)
    frame:SetBackdropColor(unpack(RLU.Brand.colors.panel))
    frame:SetBackdropBorderColor(unpack(RLU.Brand.colors.primary))

    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 10, -10)
    header:SetText("|cff3bbc00" .. title .. "|r")

    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    frame.header = header
    frame.content = content
    return frame
end

function RLU.CreateCheckbox(parent, label, initialValue, onClick)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetChecked(initialValue and true or false)
    checkbox.text:SetText(label or RLU:Locale("CHECKBOX_FALLBACK"))
    checkbox:SetScript("OnClick", function(self)
        if onClick then
            onClick(self:GetChecked())
        end
    end)
    return checkbox
end
