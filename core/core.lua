local addonName = ...

RLU = {
    name = addonName or "ReputationLevelUp",
    version = "v4.0.4",
    Modules = {},
    LoadedModules = {},
    events = {},
    timers = {},
    initialized = {},
    isInitialized = false,
}

_G["RLU"] = RLU

RLU.eventFrame = CreateFrame("Frame")
RLU.eventFrame:SetScript("OnEvent", function(_, event, ...)
    RLU:FireEvent(event, ...)
end)

function RLU:GetPrefix()
    return "|TInterface\\AddOns\\ReputationLevelUp\\media\\Textures\\icon:16:16|t |cff3bbc00[RLU]|r"
end

function RLU:Print(message)
    print(self:GetPrefix() .. " " .. tostring(message))
end

function RLU:PrintError(message)
    print(self:GetPrefix() .. " |cffff4444[ERROR]|r " .. tostring(message))
end

function RLU:PrintDebug(message)
    if self.debugMode then
        print(self:GetPrefix() .. " |cff808080[DEBUG]|r " .. tostring(message))
    end
end

function RLU:GetMetadata(field)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(self.name, field)
    end
    if GetAddOnMetadata then
        return GetAddOnMetadata(self.name, field)
    end
    return nil
end

function RLU:RegisterModule(module, key)
    if type(module) == "string" then
        local temp = module
        module = key
        key = temp
    end

    if not key or not module then
        return
    end

    self.Modules[key] = module
end

function RLU:RegisterEvent(event, callback, id)
    id = id or "core"

    if not self.events[event] then
        self.events[event] = {}
        self.eventFrame:RegisterEvent(event)
    end

    self.events[event][id] = callback
end

function RLU:UnregisterEvent(event, id)
    id = id or "core"

    if not self.events[event] then
        return
    end

    self.events[event][id] = nil
    if not next(self.events[event]) then
        self.eventFrame:UnregisterEvent(event)
        self.events[event] = nil
    end
end

function RLU:FireEvent(event, ...)
    local callbacks = self.events[event]
    if not callbacks then
        return
    end

    local queue = {}
    for id, callback in pairs(callbacks) do
        queue[#queue + 1] = { id = id, callback = callback }
    end

    for _, entry in ipairs(queue) do
        local ok, err = pcall(entry.callback, event, ...)
        if not ok then
            self:PrintError("Event failure for " .. tostring(event) .. " (" .. tostring(entry.id) .. "): " .. tostring(err))
        end
    end
end

function RLU:CreateTimer(duration, callback, repeating)
    local timer = {
        duration = duration,
        callback = callback,
        repeating = repeating,
        elapsed = 0,
        active = true,
    }

    self.timers[#self.timers + 1] = timer

    if not self.timerFrame then
        self.timerFrame = CreateFrame("Frame")
        self.timerFrame:SetScript("OnUpdate", function(_, elapsed)
            RLU:UpdateTimers(elapsed)
        end)
    end

    return timer
end

function RLU:UpdateTimers(elapsed)
    for index = #self.timers, 1, -1 do
        local timer = self.timers[index]
        if timer.active then
            timer.elapsed = timer.elapsed + elapsed
            if timer.elapsed >= timer.duration then
                local ok, err = pcall(timer.callback)
                if not ok then
                    self:PrintError("Timer failure: " .. tostring(err))
                end

                if timer.repeating then
                    timer.elapsed = 0
                else
                    table.remove(self.timers, index)
                end
            end
        else
            table.remove(self.timers, index)
        end
    end

    if #self.timers == 0 and self.timerFrame then
        self.timerFrame:SetScript("OnUpdate", nil)
        self.timerFrame = nil
    end
end

function RLU:CancelTimer(timer)
    if timer then
        timer.active = false
    end
end

function RLU:RegisterSlashCommand(commands, callback)
    local list = type(commands) == "table" and commands or { commands }
    local cmdName = self.name .. "CMD"

    for index, command in ipairs(list) do
        _G["SLASH_" .. cmdName .. index] = "/" .. command
    end

    SlashCmdList[cmdName] = callback
end

function RLU:ShowWelcomeMessage()
    if not (self.db and self.db.profile and self.db.profile.showWelcomeMessage ~= false) then
        return
    end

    local version = self:GetMetadata("Version") or self.version or "Unknown"
    self:Print("Ready. Use |cffffffff/rlu|r to open options or |cffffffff/rlu help|r for commands.")
    self:Print("|cffffff00Version:|r |cff8080ff" .. version .. "|r")
end
