---@type _, Finanzamt
local Finanzamt = LibStub("AceAddon-3.0"):GetAddon("Finanzamt") -- Get Addon Namespace

SLASH_FINANZAMTRESET1 = "/finreset"
SlashCmdList["FINANZAMTRESET"] = function(msg)
    Finanzamt.db.profile.transactions = {}
    print("[Finanzamt] Item Transaktionen zurückgesetzt. Historie geleert.")
end

SLASH_FINANZAMTDEBUG1 = "/findebug"
SlashCmdList["FINANZAMTDEBUG"] = function(msg)
    Finanzamt.db.global.enableDebugMessages = not Finanzamt.db.global.enableDebugMessages
    if Finanzamt.db.global.enableDebugMessages then
        Finanzamt:ConsoleMessage("Debug enabled")
    else
        Finanzamt:ConsoleMessage("Debug disabled")
    end
end
