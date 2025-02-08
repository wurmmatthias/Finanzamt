---@type _, Finanzamt
local Finanzamt = LibStub("AceAddon-3.0"):GetAddon("Finanzamt") -- Get Addon Namespace

SLASH_FINANZAMTRESET1 = "/finreset"
SlashCmdList["FINANZAMTRESET"] = function(msg)
    Finanzamt.db.profile.transactions = {}
    print("[Finanzamt] Item Transaktionen zurückgesetzt. Historie geleert.")
end
