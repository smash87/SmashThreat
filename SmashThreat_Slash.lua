
SLASH_SMASHTHREAT1 = "/smashthreat"
SLASH_SMASHTHREAT2 = "/st"

SlashCmdList["SMASHTHREAT"] = function(msg)
    msg = msg:lower()
    if msg == "lock" then
        SmashThreatDB.locked = true
        print("SmashThreat locked")
    elseif msg == "unlock" then
        SmashThreatDB.locked = false
        print("SmashThreat unlocked")
    elseif msg == "test" then
        SmashThreatDB.testMode = not SmashThreatDB.testMode
        print("Test mode:", SmashThreatDB.testMode)
    else
        print("/st lock, /st unlock, /st test")
    end
end
