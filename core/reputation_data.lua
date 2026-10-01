local RLU = _G["RLU"]

local FALLBACK_EXPANSIONS = {
    {
        id = "current",
        labelKey = "EXPANSION_CURRENT",
        reputations = {
            { id = 2590, name = "Council of Dornogal" },
            { id = 2594, name = "Assembly of the Deeps" },
            { id = 2570, name = "Hallowfall Arathi" },
            { id = 2600, name = "The Severed Threads" },
        },
    },
    {
        id = "dragonflight",
        labelKey = "EXPANSION_DRAGONFLIGHT",
        reputations = {
            { id = 2507, name = "Dragonscale Expedition" },
            { id = 2510, name = "Valdrakken Accord" },
            { id = 2511, name = "Iskaara Tuskarr" },
            { id = 2517, name = "Maruuk Centaur" },
        },
    },
    {
        id = "shadowlands",
        labelKey = "EXPANSION_SHADOWLANDS",
        reputations = {
            { id = 2413, name = "Court of Harvesters" },
            { id = 2465, name = "The Wild Hunt" },
            { id = 2410, name = "The Undying Army" },
            { id = 2439, name = "The Ascended" },
        },
    },
    {
        id = "battle_for_azeroth",
        labelKey = "EXPANSION_BFA",
        reputations = {
            { id = 2164, name = "Champions of Azeroth" },
            { id = 2163, name = "Tortollan Seekers" },
            { id = 2159, name = "7th Legion" },
            { id = 2157, name = "Honorbound" },
        },
    },
    {
        id = "legion",
        labelKey = "EXPANSION_LEGION",
        reputations = {
            { id = 1883, name = "Dreamweavers" },
            { id = 1828, name = "Highmountain Tribe" },
            { id = 1859, name = "The Nightfallen" },
            { id = 1894, name = "The Wardens" },
        },
    },
    {
        id = "classic",
        labelKey = "EXPANSION_CLASSIC",
        reputations = {
            { id = 72, name = "Stormwind" },
            { id = 76, name = "Orgrimmar" },
            { id = 47, name = "Ironforge" },
            { id = 69, name = "Darnassus" },
        },
    },
}

local HEADER_ID_MAP = {
    ["The War Within"] = "current",
    ["Current Expansion"] = "current",
    ["Dragonflight"] = "dragonflight",
    ["Shadowlands"] = "shadowlands",
    ["Battle for Azeroth"] = "battle_for_azeroth",
    ["Legion"] = "legion",
    ["Warlords of Draenor"] = "warlords",
    ["Mists of Pandaria"] = "mists",
    ["Cataclysm"] = "cataclysm",
    ["Wrath of the Lich King"] = "wrath",
    ["The Burning Crusade"] = "burning_crusade",
    ["Classic"] = "classic",
    ["Alliance"] = "classic",
    ["Horde"] = "classic",
}

local function CloneTable(source)
    local target = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            target[key] = CloneTable(value)
        else
            target[key] = value
        end
    end
    return target
end

local function NormalizeHeaderName(name)
    if type(name) ~= "string" or name == "" then
        return RLU:Locale("EXPANSION_OTHER")
    end
    return name
end

local function NormalizeHeaderId(name)
    if HEADER_ID_MAP[name] then
        return HEADER_ID_MAP[name]
    end

    local id = string.lower(name)
    id = id:gsub("[^%w]+", "_")
    id = id:gsub("^_+", ""):gsub("_+$", "")
    if id == "" then
        id = "other"
    end
    return id
end

local function BuildFallbackCatalog()
    local expansions = {}
    for _, expansion in ipairs(FALLBACK_EXPANSIONS) do
        local entry = CloneTable(expansion)
        entry.label = RLU:Locale(expansion.labelKey or "EXPANSION_CURRENT")
        expansions[#expansions + 1] = entry
    end
    return expansions
end

local function GetFactionRow(index)
    if C_Reputation and C_Reputation.GetFactionDataByIndex then
        local factionData = C_Reputation.GetFactionDataByIndex(index)
        if factionData then
            return factionData
        end
    end

    if GetFactionInfo then
        local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID = GetFactionInfo(index)
        if name then
            return {
                name = name,
                description = description,
                reaction = standingID,
                currentStanding = barValue,
                barMin = barMin,
                barMax = barMax,
                atWarWith = atWarWith,
                canToggleAtWar = canToggleAtWar,
                isHeader = isHeader,
                isCollapsed = isCollapsed,
                hasRep = hasRep,
                isWatched = isWatched,
                isChild = isChild,
                factionID = factionID,
            }
        end
    end
end

local function GetFactionCount()
    if C_Reputation and C_Reputation.GetNumFactions then
        return C_Reputation.GetNumFactions()
    end

    if GetNumFactions then
        return GetNumFactions()
    end

    return 0
end

local function ExpandAllHeaders()
    local collapsedHeaders = {}
    local index = 1

    while index <= GetFactionCount() do
        local row = GetFactionRow(index)
        if row and row.isHeader and row.isCollapsed then
            collapsedHeaders[#collapsedHeaders + 1] = index
            if ExpandFactionHeader then
                ExpandFactionHeader(index)
            end
        end
        index = index + 1
    end

    return collapsedHeaders
end

local function RestoreCollapsedHeaders(collapsedHeaders)
    if not CollapseFactionHeader then
        return
    end

    for index = #collapsedHeaders, 1, -1 do
        CollapseFactionHeader(collapsedHeaders[index])
    end
end

local function BuildLiveCatalog()
    local expansions = {}
    local expansionMap = {}
    local currentExpansion
    local count = GetFactionCount()
    if count <= 0 then
        return nil
    end

    local collapsedHeaders = ExpandAllHeaders()

    for index = 1, GetFactionCount() do
        local row = GetFactionRow(index)
        if row then
            if row.isHeader and not row.isChild then
                local label = NormalizeHeaderName(row.name)
                local id = NormalizeHeaderId(label)
                currentExpansion = expansionMap[id]
                if not currentExpansion then
                    currentExpansion = {
                        id = id,
                        label = label,
                        reputations = {},
                    }
                    expansionMap[id] = currentExpansion
                    expansions[#expansions + 1] = currentExpansion
                end
            elseif not row.isHeader and row.name then
                if not currentExpansion then
                    currentExpansion = {
                        id = "other",
                        label = RLU:Locale("EXPANSION_OTHER"),
                        reputations = {},
                    }
                    expansionMap.other = currentExpansion
                    expansions[#expansions + 1] = currentExpansion
                end

                currentExpansion.reputations[#currentExpansion.reputations + 1] = {
                    id = row.factionID or row.name,
                    name = row.name,
                    standing = row.reaction,
                }
            end
        end
    end

    RestoreCollapsedHeaders(collapsedHeaders)

    local filtered = {}
    for _, expansion in ipairs(expansions) do
        if #expansion.reputations > 0 then
            filtered[#filtered + 1] = expansion
        end
    end

    if #filtered == 0 then
        return nil
    end

    return filtered
end

RLU.ReputationData = {
    fallback = BuildFallbackCatalog(),
    live = nil,
}

function RLU:BuildFactionCatalog(forceRefresh)
    if not forceRefresh and self.ReputationData.live and #self.ReputationData.live > 0 then
        return self.ReputationData.live
    end

    local liveCatalog = BuildLiveCatalog()
    if liveCatalog and #liveCatalog > 0 then
        self.ReputationData.live = liveCatalog
        return liveCatalog
    end

    self.ReputationData.live = nil
    return self.ReputationData.fallback
end

function RLU:GetExpansionGroups(forceRefresh)
    return self:BuildFactionCatalog(forceRefresh)
end

function RLU:GetSelectedExpansion()
    local selected = self:GetSetting("selectedExpansion") or "current"
    for _, expansion in ipairs(self:GetExpansionGroups()) do
        if expansion.id == selected then
            return expansion
        end
    end
    return self:GetExpansionGroups()[1]
end

function RLU:GetReputationExpansion(expansionId)
    for _, expansion in ipairs(self:GetExpansionGroups()) do
        if expansion.id == expansionId then
            return expansion
        end
    end
end

function RLU:GetReputationAssignment(factionId)
    local assignments = self:GetSetting("reputationAssignments") or {}
    return assignments[tostring(factionId)]
end

function RLU:SetReputationAssignment(factionId, assignment)
    if not self.db or not self.db.profile then
        return
    end

    self.db.profile.reputationAssignments = self.db.profile.reputationAssignments or {}
    self.db.profile.reputationAssignments[tostring(factionId)] = assignment
end

function RLU:ClearReputationAssignment(factionId)
    if not self.db or not self.db.profile or not self.db.profile.reputationAssignments then
        return
    end

    self.db.profile.reputationAssignments[tostring(factionId)] = nil
end

function RLU:GetEffectiveAssignment(factionId)
    local assignment = self:GetReputationAssignment(factionId)
    if assignment and assignment.enabled ~= false then
        return assignment
    end

    return {
        enabled = true,
        soundId = self:GetSetting("defaultSoundId") or self.SoundCatalog.defaultSoundId,
        quality = self:GetSetting("defaultSoundQuality") or "med",
    }
end
