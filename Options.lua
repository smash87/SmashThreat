-- Options.lua
SmashThreat.Options = {}
local Options = SmashThreat.Options
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

function Options:CreateMenu()
	if self.frame then
		return
	end

	local frame = CreateFrame("Frame", "SmashThreatOptionsWindow", UIParent, "BackdropTemplate")
	frame:SetSize(400, 300)
	frame:SetPoint("CENTER")
	frame:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	self.frame = frame
	SmashThreat.OptionsWindow = frame

	-- Close button
	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
	close:SetSize(20, 20)

	-- Test toggle
	local testBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	testBtn:SetSize(120, 25)
	testBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -40)
	testBtn:SetText("Toggle Test Mode")
	testBtn:SetScript("OnClick", function()
		SmashThreat.testMode = not SmashThreat.testMode
		print("Test Mode " .. (SmashThreat.testMode and "ON" or "OFF"))
		SmashThreat:Update()
	end)

	-- Lock/Unlock buttons
	local lockBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	lockBtn:SetSize(60, 25)
	lockBtn:SetPoint("TOPLEFT", testBtn, "BOTTOMLEFT", 0, -10)
	lockBtn:SetText("Lock")
	lockBtn:SetScript("OnClick", function()
		if SmashThreat.ThreatBars then
			SmashThreat.ThreatBars:SetLocked(true)
		end
		print("ThreatBar Locked")
	end)

	local unlockBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	unlockBtn:SetSize(60, 25)
	unlockBtn:SetPoint("LEFT", lockBtn, "RIGHT", 10, 0)
	unlockBtn:SetText("Unlock")
	unlockBtn:SetScript("OnClick", function()
		if SmashThreat.ThreatBars then
			SmashThreat.ThreatBars:SetLocked(false)
		end
		print("ThreatBar Unlocked")
	end)

	-- Transparency slider
	local slider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
	slider:SetPoint("TOPLEFT", unlockBtn, "BOTTOMLEFT", 0, -20)
	slider:SetWidth(200)
	slider:SetMinMaxValues(0, 1)
	slider:SetValueStep(0.05)
	slider:SetObeyStepOnDrag(true)
	slider.Text:ClearAllPoints()
	slider.Text:SetPoint("LEFT", slider, "LEFT", 0, 20)
	slider.Text:SetText("ThreatBar Transparency")
	slider:SetValue(SmashThreat.db.bgAlpha or 0.8)
	slider:SetScript("OnValueChanged", function(selfSlider, value)
		SmashThreat.db.bgAlpha = value
		if SmashThreat.ThreatBars and SmashThreat.ThreatBars.frame then
			SmashThreat.ThreatBars.frame:SetBackdropColor(0, 0, 0, value)
		end
	end)

	-- Texture dropdown
	local dropdown = CreateFrame("Frame", "SmashThreatTextureDropdown", frame, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -20)
	UIDropDownMenu_Initialize(dropdown, function(selfDD, level)
		local textures = { "BantoBar", "Details", "Omen" }
		if LSM then
			local lsmBars = LSM:List("statusbar")
			for _, t in ipairs(lsmBars) do
				table.insert(textures, t)
			end
		end
		for i, tex in ipairs(textures) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = tex
			info.func = function()
				SmashThreat.db.barTexture = tex
				if SmashThreat.ThreatBars then
					SmashThreat.ThreatBars:RefreshTexture()
				end
				UIDropDownMenu_SetSelectedID(dropdown, i)
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	UIDropDownMenu_SetWidth(dropdown, 150)
	UIDropDownMenu_SetSelectedID(dropdown, 1)
end
