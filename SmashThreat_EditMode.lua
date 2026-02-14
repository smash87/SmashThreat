
local frame = SmashThreatAnchor

frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript("OnDragStart", function(self)
    if SmashThreatDB.locked then return end
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p,_,_,x,y = self:GetPoint()
    SmashThreatDB.position = { point=p, x=x, y=y }
end)
