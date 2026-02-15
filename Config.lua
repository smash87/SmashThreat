SmashThreat = SmashThreat or {}

SmashThreatDB = SmashThreatDB or {}

local defaults = {
	displayMode = "both", -- "percent", "diff", "both"
	animSpeed = 0.25,
	maxBars = 5,
	showTopAggro = true,
	showBars = true,
	locked = false,
}

local db = SmashThreatDB
for k, v in pairs(defaults) do
	if db[k] == nil then
		db[k] = v
	end
end

SmashThreat.db = db
