---@type _, Finanzamt
local _, Finanzamt = ... -- Get Addon Namespace

SLASH_FINANZAMTRESET1 = "/finreset"
SlashCmdList["FINANZAMTRESET"] = function(msg)
    FinanzamtDB.transactions = {}
    print("[Finanzamt] Item Transaktionen zurückgesetzt. Historie geleert.")
end
