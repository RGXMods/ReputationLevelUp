local RLU = _G["RLU"]

RLU.OptionsTabs = {
    { text = function() return RLU:Locale("GENERAL") end, create = function(panel) RLU.CreateGeneralPanel(panel) end },
    { text = function() return RLU:Locale("REPUTATIONS") end, create = function(panel) RLU.CreateReputationsPanel(panel) end },
    { text = function() return RLU:Locale("ABOUT") end, create = function(panel) RLU.CreateAboutPanel(panel) end },
}
