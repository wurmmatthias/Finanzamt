---@type _, Finanzamt
local Finanzamt = LibStub("AceAddon-3.0"):GetAddon("Finanzamt") -- Get Addon Namespace

local eventHandlerFrame = CreateFrame("Frame")
local waitingForPlayerMoneyEvent = false
local timeoutSeconds = 3
eventHandlerFrame:RegisterEvent("GUILDBANKFRAME_OPENED") -- Fires when the Guild Bank UI opens
eventHandlerFrame:RegisterEvent("GUILDBANK_UPDATE_MONEY") -- Fires when money is added/removed
eventHandlerFrame:RegisterEvent("PLAYER_MONEY") -- Fires when money of player changes

local function timeoutFunction()
    if waitingForPlayerMoneyEvent then
        Finanzamt:ConsoleMessage("PLAYER_MONEY wurde nicht registriert. Wenn du Geld in die Gildenbank eingezahlt oder abgehoben hast, bitte informiere einen zuständigen Gildenoffizier! Falls nicht, kann diese Meldung ignoriert werden!")
        waitingForPlayerMoneyEvent = false
    end
end

eventHandlerFrame:SetScript("OnEvent", function(self, event)
    
    Finanzamt:DebugMessage("Event read", event)
    
    if event == "GUILDBANK_UPDATE_MONEY" then
        Finanzamt:DebugMessage("Waiting for PlayerMoney")
        waitingForPlayerMoneyEvent = true
        C_Timer.After(timeoutSeconds, timeoutFunction)
    elseif event == "PLAYER_MONEY" and waitingForPlayerMoneyEvent then
        Finanzamt:DebugMessage("PLAYER_MONEY found")
        waitingForPlayerMoneyEvent = false
        C_Timer.After(0.1, Finanzamt.CheckGuildBankMoneyTransaction) -- Ensure log updates after transaction
    end
end)

local playerInteractionFrame = CreateFrame("Frame")
playerInteractionFrame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
playerInteractionFrame:SetScript("OnEvent", function(self, event, interactionType)
    if event and interactionType == 10 then -- 10 = GuildBank opened
        Finanzamt.UpdateGuildbankMoney()
    end
end)