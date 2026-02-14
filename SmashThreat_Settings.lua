
local addonName, SmashThreat = ...

function SmashThreat:CreateSettings()
    if not SmashThreatDB then return end

    local category = Settings.RegisterVerticalLayoutCategory("SmashThreat")

    local lockSetting = Settings.RegisterAddOnSetting(category,"locked","locked",SmashThreatDB,"boolean","Lock Frame",false)
    Settings.CreateCheckbox(category, lockSetting)

    local testSetting = Settings.RegisterAddOnSetting(category,"testMode","testMode",SmashThreatDB,"boolean","Test Mode",false)
    Settings.CreateCheckbox(category, testSetting)

    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        local textures = LSM:List("statusbar")
        local function GetOptions()
            local c = Settings.CreateControlTextContainer()
            for _,t in ipairs(textures) do c:Add(t,t) end
            return c:GetData()
        end

        local texSetting = Settings.RegisterAddOnSetting(category,"texture","texture",SmashThreatDB,"string","Texture",textures[1])
        Settings.CreateDropdown(category, texSetting, GetOptions, "Bar Texture")

        texSetting:SetValueChangedCallback(function(_,value)
            SmashThreatDB.texture = value
            SmashThreat:ApplyTexture()
        end)
    end

    Settings.RegisterAddOnCategory(category)
end
