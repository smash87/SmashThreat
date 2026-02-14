
local addonName, SmashThreat = ...
SmashThreat.Media = {}

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

function SmashThreat.Media:Init()
    if LSM then
        self.textures = LSM:List("statusbar")
    else
        self.textures = {"Blizzard"}
    end
end

function SmashThreat.Media:GetTexture(name)
    if LSM and name then
        return LSM:Fetch("statusbar", name)
    end
    return "Interface\\TARGETINGFRAME\\UI-StatusBar"
end
