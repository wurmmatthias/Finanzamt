---@type _, Finanzamt
local Finanzamt = LibStub("AceAddon-3.0"):GetAddon("Finanzamt") -- Get Addon Namespace

local eventHandlerFrame = CreateFrame("Frame")
eventHandlerFrame:RegisterEvent("GUILDBANKFRAME_OPENED") -- Fires when the Guild Bank UI opens
eventHandlerFrame:RegisterEvent("GUILDBANK_UPDATE_MONEY") -- Fires when money is added/removed

eventHandlerFrame:SetScript("OnEvent", function(self, event)
    if event == "GUILDBANK_UPDATE_MONEY" then
        C_Timer.After(0.1, Finanzamt.CheckGuildBankMoneyTransaction) -- Ensure log updates after transaction
    end
end)


-- Modify the event handler to also update the transaction history
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("GUILDBANKLOG_UPDATE")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "GUILDBANKLOG_UPDATE" then
        Finanzamt:UpdateGuildBankDeposits()
        Finanzamt:UpdateGuildBankMoneyDisplay()
        Finanzamt:UpdateTransactionHistory()  -- update and save the full transaction history
    end
end)

local playerInteractionFrame = CreateFrame("Frame")
playerInteractionFrame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
playerInteractionFrame:SetScript("OnEvent", function(self, event, interactionType)
    if event and interactionType == 10 then -- 10 = GuildBank opened
        Finanzamt.UpdateGuildbankMoney()
    end
end)