-- Core.lua
local Core = {}
SmashThreat.Core = Core

-- Default DB
SmashThreat.db = SmashThreat.db or {
	bgAlpha = 0.8,
	locked = false,
	barTexture = "BantoBar",
}

SmashThreat.currentThreat = {}
SmashThreat.testMode = false
SmashThreat.updating = false

-- Initialize threat bars
function SmashThreat:InitThreatBars()
	if not self.ThreatBars then
		local BarsClass = SmashThreat.ThreatBarsClass
		self.ThreatBars = BarsClass:Create(UIParent)
		self.ThreatBars:RefreshTexture()
	end
end

-- Clear bars
function SmashThreat:ClearBars()
	if self.ThreatBars then
		self.ThreatBars:Clear()
	end
	self.currentThreat = {}
end

-- Populate threat data
function SmashThreat:Update()
	if self.updating then
		return
	end
	self.updating = true
	self:InitThreatBars()
	if not self.ThreatBars or not self.ThreatBars.frame then
		self.updating = false
		return
	end

	local threatTable = {}

	if self.testMode then
		threatTable = {
			{ name = "TankPlayer", threat = 100, unitRole = "TANK" },
			{ name = "HealerPlayer", threat = 80, unitRole = "HEALER" },
			{ name = "DPS1", threat = 60, unitRole = "DAMAGER" },
			{ name = "DPS2", threat = 40, unitRole = "DAMAGER" },
			{ name = "DPS3", threat = 20, unitRole = "DAMAGER" },
		}
	else
		local target = "target"
		if UnitExists(target) then
			local numGroup = IsInRaid() and GetNumGroupMembers() or (IsInGroup() and GetNumGroupMembers() - 1) or 0
			local units = { "player" }
			for i = 1, numGroup do
				table.insert(units, IsInRaid() and "raid" .. i or "party" .. i)
			end

			for _, unit in ipairs(units) do
				if UnitExists(unit) then
					local name = UnitName(unit)
					local threatpct = select(3, UnitDetailedThreatSituation(unit, target)) or 0
					local role = UnitGroupRolesAssigned(unit) or "DAMAGER"
					table.insert(threatTable, { name = name, threat = math.floor(threatpct), unitRole = role })
				end
			end
		end
	end

	local cleaned = {}
	for _, t in ipairs(threatTable) do
		if t then
			table.insert(cleaned, t)
		end
	end

	SmashThreat.currentThreat = cleaned
	SmashThreat.ThreatBars:Update()
	self.updating = false
end

-- Event handler
local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", function(_, event)
	if event == "UNIT_THREAT_LIST_UPDATE" then
		SmashThreat:Update()
	elseif event == "PLAYER_REGEN_ENABLED" then
		SmashThreat:ClearBars()
	end
end)

-- Slash commands
SLASH_SMASHTHREAT1 = "/st"
SlashCmdList["SMASHTHREAT"] = function(msg)
	msg = msg:lower()
	if msg == "lock" then
		if SmashThreat.ThreatBars then
			SmashThreat.ThreatBars:SetLocked(true)
		end
		print("ThreatBar Locked")
	elseif msg == "unlock" then
		if SmashThreat.ThreatBars then
			SmashThreat.ThreatBars:SetLocked(false)
		end
		print("ThreatBar Unlocked")
	elseif msg == "test" then
		SmashThreat.testMode = not SmashThreat.testMode
		print("Test Mode " .. (SmashThreat.testMode and "ON" or "OFF"))
		SmashThreat:Update()
	elseif msg == "edit" then
		if not SmashThreat.OptionsWindow then
			SmashThreat.Options:CreateMenu()
		end
		SmashThreat.OptionsWindow:Show()
	else
		print("Commands: lock, unlock, test, edit")
	end
end
