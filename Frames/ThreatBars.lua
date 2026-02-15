-- Frames/ThreatBars.lua
SmashThreat.ThreatBarsClass = {}
local TB = SmashThreat.ThreatBarsClass
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

function TB:Create(parent)
	local self = {}
	self.frame = CreateFrame("Frame", "SmashThreatBarsFrame", parent, "BackdropTemplate")
	self.frame:SetSize(300, 200)
	self.frame:SetPoint("CENTER")
	self.frame:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
	self.frame:SetBackdropColor(0, 0, 0, SmashThreat.db.bgAlpha or 0.8)
	self.bars = {}
	self.locked = false

	-- Movable frame
	self.frame:SetMovable(true)
	self.frame:EnableMouse(true)
	self.frame:RegisterForDrag("LeftButton")
	self.frame:SetScript("OnDragStart", function(f)
		if not self.locked then
			f:StartMoving()
		end
	end)
	self.frame:SetScript("OnDragStop", function(f)
		f:StopMovingOrSizing()
	end)

	local topPadding = 10

	-- Helper: resolve texture safely
	local function GetTexturePath(tex)
		if not tex or tex == "" then
			return "Interface\\TargetingFrame\\UI-StatusBar"
		end
		if LSM then
			local lsmTex = LSM:Fetch("statusbar", tex)
			if lsmTex then
				return lsmTex
			end
		end
		return tex
	end

	-- Create 5 bars
	for i = 1, 5 do
		local bar = CreateFrame("StatusBar", nil, self.frame)
		bar:SetSize(280, 20)
		bar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -topPadding - (i - 1) * 25)

		local texPath = GetTexturePath(SmashThreat.db.barTexture)
		bar:SetStatusBarTexture(texPath)

		bar.bg = bar:CreateTexture(nil, "BACKGROUND")
		bar.bg:SetAllPoints(bar)
		bar.bg:SetColorTexture(0, 0, 0, 0.3)

		bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		bar.text:SetPoint("LEFT", bar, "LEFT", 5, 0)

		bar.value = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		bar.value:SetPoint("RIGHT", bar, "RIGHT", -5, 0)

		table.insert(self.bars, bar)
	end

	-- Lock/unlock
	function self:SetLocked(state)
		self.locked = state
		self.frame:EnableMouse(not state)
	end

	-- Clear bars
	function self:Clear()
		for _, b in ipairs(self.bars) do
			b:Hide()
			b:SetValue(0)
			b.text:SetText("")
			b.value:SetText("")
		end
	end

	-- Refresh bar texture
	function self:RefreshTexture()
		local tex = GetTexturePath(SmashThreat.db.barTexture)
		for _, b in ipairs(self.bars) do
			b:SetStatusBarTexture(tex)
		end
	end

	-- Update bars with currentThreat table
	function self:Update()
		local threatTable = SmashThreat.currentThreat
		for i = 1, 5 do
			local data = threatTable[i]
			local bar = self.bars[i]

			if data then
				bar:Show() -- show only if data exists
				bar:SetValue(data.threat or 0)

				-- Role/self coloring
				if data.name == UnitName("player") then
					bar:SetStatusBarColor(0.6, 0, 0.6) -- purple
					bar.text:SetTextColor(1, 1, 1)
				elseif data.unitRole == "TANK" then
					bar:SetStatusBarColor(0, 1, 0)
					bar.text:SetTextColor(1, 1, 1)
				elseif data.unitRole == "HEALER" then
					bar:SetStatusBarColor(1, 1, 1)
					bar.text:SetTextColor(1, 1, 0)
				else
					bar:SetStatusBarColor(1, 0, 0)
					bar.text:SetTextColor(1, 1, 1)
				end

				bar.text:SetText(data.name or "")
				bar.value:SetText((data.threat or 0) .. "%")
			else
				bar:Hide() -- hide bar if no data
				bar:SetValue(0)
				bar.text:SetText("")
				bar.value:SetText("")
			end
		end
	end

	return self
end
