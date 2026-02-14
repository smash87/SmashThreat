
local addonName, SmashThreat = ...
SmashThreat = SmashThreat or {}

SmashThreat.defaults = {
    locked = false,
    alwaysShow = false,
    testMode = false,
    texture = "Blizzard",
    width = 220,
    height = 18,
    position = { point="CENTER", x=0, y=200 }
}

local function CopyDefaults(src, dst)
    if not dst then dst = {} end
    for k,v in pairs(src) do
        if type(v) == "table" then
            dst[k] = CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

local frame = CreateFrame("Frame", "SmashThreatAnchor", UIParent, "BackdropTemplate")
frame:SetSize(240, 60)
frame:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background"})
frame:SetBackdropColor(0,0,0,.4)

SmashThreat.anchor = frame
_G["SmashThreatAnchor"] = frame

local bars = {}
SmashThreat.bars = bars

function SmashThreat:CreateBar(index)
    local bar = CreateFrame("StatusBar", "SmashThreatBar"..index, frame)
    bar:SetSize(SmashThreatDB.width, SmashThreatDB.height)
    bar:SetPoint("TOP", frame, "TOP", 0, -(index-1)*(SmashThreatDB.height+4))

    bar.bg = bar:CreateTexture(nil,"BACKGROUND")
    bar.bg:SetAllPoints()
    bar.bg:SetColorTexture(0,0,0,.5)

    bar.text = bar:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    bar.text:SetPoint("CENTER")

    bars[index] = bar
    _G["SmashThreatBar"..index] = bar

    return bar
end

function SmashThreat:ApplyTexture()
    local tex = SmashThreat.Media:GetTexture(SmashThreatDB.texture)
    for _,bar in ipairs(bars) do
        bar:SetStatusBarTexture(tex)
    end
end

function SmashThreat:GetThreat(unit)
    if SmashThreatDB.testMode then
        return math.random(0,100)
    end
    if not UnitExists(unit) then return 0 end
    local _,_,percent = UnitDetailedThreatSituation("player", unit)
    return percent or 0
end

function SmashThreat:Update()
    local percent = self:GetThreat("target")
    local bar = bars[1]
    bar:SetMinMaxValues(0,100)
    bar:SetValue(percent)
    bar.text:SetText(string.format("Threat: %.1f%%", percent))

    if percent == 0 and not SmashThreatDB.alwaysShow then
        frame:Hide()
    else
        frame:Show()
    end
end

local updater = CreateFrame("Frame")
local elapsed = 0
updater:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed > .05 then
        SmashThreat:Update()
        elapsed = 0
    end
end)

local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:SetScript("OnEvent", function(_,_,name)
    if name ~= addonName then return end
    SmashThreatDB = CopyDefaults(SmashThreat.defaults, SmashThreatDB)
    SmashThreat.Media:Init()

    frame:SetPoint(SmashThreatDB.position.point, UIParent, SmashThreatDB.position.point, SmashThreatDB.position.x, SmashThreatDB.position.y)

    SmashThreat:CreateBar(1)
    SmashThreat:ApplyTexture()
    SmashThreat:CreateSettings()
end)
