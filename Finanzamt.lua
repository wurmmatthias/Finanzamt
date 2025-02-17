-- Add-On Name: Finanzamt
-- Description: Überprüft, ob alle Gildenmitglieder in diesem Monat mindestens 10.000 Gold in die Gildenbank eingezahlt haben und stellt eine GUI zur Verfügung.
---@class Finanzamt : AceAddon, AceConsole-3.0, AceEvent-3.0
local Finanzamt = LibStub("AceAddon-3.0"):NewAddon("Finanzamt", "AceConsole-3.0")
local AceDB = LibStub("AceDB-3.0")

-- Load required libraries
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Variable declaration
---@type AceDBObject-3.0
Finanzamt.db = nil  -- Will be initialized later
Finanzamt.lines = {}

Finanzamt.guildDeposits = {}
Finanzamt.guildBankMoney = {}

Finanzamt.Config = {}      -- Store config settings
Finanzamt.UI = {}      -- Table for UI elements
Finanzamt.UI.Main = {}      -- Variable for main frame
Finanzamt.UI.ItemContentFrame = {} -- Variable for item content frame
Finanzamt.UI.GB_Gold = {} -- Variable for item content frame
Finanzamt.UI.GB_Silver = {} -- Variable for item content frame
Finanzamt.UI.GB_Copper = {} -- Variable for item content frame



-- Create the database object
function Finanzamt:OnInitialize()
    self.db = AceDB:New("FinanzamtDB", {
        profile = {
            totalMoney = 0,
            totalMoneyTimestamp = 0;
            totalPlayerMoney = 0,
            minimap = { minimapPos = 180 },
            transactions = {},
            MoneyTransactions = {}
        },
        global = {
            enableDebugMessages = false
        }
    }, true) -- 'true' means it will use the profile system

    self.db:SetProfile(UnitName("player") .. " - " .. GetRealmName())

    -- Print to confirm it's working
    Finanzamt:DebugMessage("FinanzamtDB loaded! Current money:", self.db.profile.totalMoney)
end


function Finanzamt:OnEnable()
    -- Prepare UI with stored data from SavedVariables
    Finanzamt:UpdateMoneyTransactionDisplay()
    
    -- Create a data broker object for the minimap icon
    local minimapButton = LDB:NewDataObject("Finanzamt", {
        type = "launcher",
        text = "Finanzamt",
        icon = "Interface\\AddOns\\Finanzamt\\adler.tga", -- Change this to any icon path you prefer
        OnClick = function(_, button)
            if button == "LeftButton" then
                if Finanzamt.UI.Main and Finanzamt.UI.Main:IsShown() then
                    Finanzamt.UI.Main:Hide()
                    Finanzamt.UI.Main:Hide()
                else
                    Finanzamt.UI.Main:Show()
                    Finanzamt:DebugMessage("Letzter gespeicherter Wert (in Kupfer):", Finanzamt.db.profile.totalMoney)
                end
            elseif button == "RightButton" then
                print("Finanzamt Addon - Optionen in Kürze")
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Finanzamt Overlay")
            tooltip:AddLine("Linksklick zum öffnen", 1, 1, 1)
            tooltip:AddLine("Rechtsklick für Einstellungen", 1, 1, 1)
        end
    })

    -- Register the minimap button

    LDBIcon:Register("Finanzamt", minimapButton, Finanzamt.db.profile.minimap)
end


function Finanzamt:ConsoleMessage(...)
    print("FINANZAMT:", ...)
end

function Finanzamt:DebugMessage(...)
    if Finanzamt.db.global.enableDebugMessages then
        print("FINANZAMT_DEBUG:", ...)
    end
end


















