-- Add-On Name: Finanzamt
-- Description: Überprüft, ob alle Gildenmitglieder in diesem Monat mindestens 10.000 Gold in die Gildenbank eingezahlt haben und stellt eine GUI zur Verfügung.
---@class Finanzamt
local Finanzamt, finanzamtName -- AddonName and Namespace

finanzamtName, Finanzamt = ...

-- Create a saved variable to store minimap settings
FinanzamtDB = FinanzamtDB or {}


-- Variable declaration
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


print("Finanzamt loaded!")
















