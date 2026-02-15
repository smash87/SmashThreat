local f = CreateFrame("Frame", "SmashThreatTopAggro", UIParent)
f:SetSize(180, 100)
f:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -30, -150)

f.rows = {}

function f:Create()
	for i = 1, 5 do
		local row = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -((i - 1) * 18))
		row:SetText("")
		self.rows[i] = row
	end
end

function f:Update()
	if not UnitExists("target") then
		for _, row in ipairs(self.rows) do
			row:SetText("")
		end
		return
	end

	local aggrotbl = {}
	for i = 1, GetNumGroupMembers() do
		local unit = IsInRaid() and ("raid" .. i) or ("party" .. i)
		if UnitExists(unit) and UnitCanAttack(unit, "target") then
			local _, perc, raw = UnitDetailedThreatSituation(unit, "target")
			if perc then
				table.insert(aggrotbl, {
					name = UnitName(unit),
					perc = perc * 100,
					raw = raw,
				})
			end
		end
	end

	table.sort(aggrotbl, function(a, b)
		return a.raw > b.raw
	end)

	for i = 1, 5 do
		local data = aggrotbl[i]
		if data then
			self.rows[i]:SetText(("%d) %s - %d%% (+%d)"):format(i, data.name, data.perc, data.raw))
		else
			self.rows[i]:SetText("")
		end
	end
end

SmashThreat.TopAggro = f
