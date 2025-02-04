-- Add-On Name: Finanzamt
-- Description: Überprüft, ob alle Gildenmitglieder in diesem Monat mindestens 10.000 Gold in die Gildenbank eingezahlt haben und stellt eine GUI zur Verfügung.

-- Load required libraries
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Create a saved variable to store minimap settings
FinanzamtDB = FinanzamtDB or {}

-- Create a data broker object for the minimap icon
local minimapButton = LDB:NewDataObject("Finanzamt", {
    type = "launcher",
    text = "Finanzamt",
    icon = "Interface\\AddOns\\Finanzamt\\adler.tga", -- Change this to any icon path you prefer
    OnClick = function(_, button)
        if button == "LeftButton" then
            if FinanzamtFrame and FinanzamtFrame:IsShown() then
                FinanzamtFrame:Hide()
                ItemTransFrame:Hide()
            else
                FinanzamtFrame:Show()
                print("Letzter gespeicherter Wert (in Kupfer):", FinanzamtDB.totalMoney)
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
LDBIcon:Register("Finanzamt", minimapButton, FinanzamtDB)

-- Create the main frame for the Add-On
local frame = CreateFrame("Frame", "FinanzamtFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(600, 400) -- Width, Height---
frame:SetPoint("CENTER") -- Center of the screen
frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
frame.title:SetText("Raufasertapete - Finanzamt")

-- Button to open the Item Transaktionen window
local itemTransButton = CreateFrame("Button", "FinanzamtItemTransButton", frame, "GameMenuButtonTemplate")
itemTransButton:SetSize(180, 25)

-- Scrollable list to display guild members and their deposits
local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(260, 260)
scrollFrame:SetPoint("TOP", frame, "TOP", 0, -70)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(260, 260)
scrollFrame:SetScrollChild(content)

-- Create a texture for the image
local imageTexture = frame:CreateTexture(nil, "ARTWORK")
imageTexture:SetSize(64, 64)  -- Set the width and height (adjust as needed)
imageTexture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 64, 64)  -- Position in bottom left
imageTexture:SetTexture("Interface\\AddOns\\Finanzamt\\adler.tga") 

-- Create FontStrings for displaying the guild balance
local guildBalanceText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
guildBalanceText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -100, 15) -- Adjusted to fit all icons
guildBalanceText:SetText("0")

-- Create the gold coin icon
local goldIcon = frame:CreateTexture(nil, "ARTWORK")
goldIcon:SetSize(16, 16)
goldIcon:SetPoint("LEFT", guildBalanceText, "RIGHT", 2, 0)
goldIcon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")

-- Create the silver coin icon
local silverText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
silverText:SetPoint("LEFT", goldIcon, "RIGHT", 5, 0)
silverText:SetText("0")

local silverIcon = frame:CreateTexture(nil, "ARTWORK")
silverIcon:SetSize(16, 16)
silverIcon:SetPoint("LEFT", silverText, "RIGHT", 2, 0)
silverIcon:SetTexture("Interface\\MoneyFrame\\UI-SilverIcon")

-- Create the copper coin icon
local copperText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
copperText:SetPoint("LEFT", silverIcon, "RIGHT", 5, 0)
copperText:SetText("0")

local copperIcon = frame:CreateTexture(nil, "ARTWORK")
copperIcon:SetSize(16, 16)
copperIcon:SetPoint("LEFT", copperText, "RIGHT", 2, 0)
copperIcon:SetTexture("Interface\\MoneyFrame\\UI-CopperIcon")

frame:Hide()

-- Item Transaction Frame
-- Create a new frame for item transactions
local ItemTransFrame = CreateFrame("Frame", "FinanzamtItemTransFrame", UIParent, "BasicFrameTemplateWithInset")
ItemTransFrame:SetSize(700, 500)
ItemTransFrame:SetPoint("CENTER")
ItemTransFrame.title = ItemTransFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
ItemTransFrame.title:SetPoint("CENTER", ItemTransFrame.TitleBg, "CENTER", 0, 0)
ItemTransFrame.title:SetText("Item Transaktionen | Sachspenden")

ItemTransFrame:SetFrameStrata("DIALOG")   -- DIALOG is above the default (MEDIUM) strata.
ItemTransFrame:SetFrameLevel(100)         -- Set a high frame level to guarantee it appears on top.

ItemTransFrame:Hide()

-- Create a scroll frame inside the item transactions frame
local itemScrollFrame = CreateFrame("ScrollFrame", nil, ItemTransFrame, "UIPanelScrollFrameTemplate")
itemScrollFrame:SetSize(600, 400)
itemScrollFrame:SetPoint("TOP", ItemTransFrame, "TOP", 0, -40)

local itemContent = CreateFrame("Frame", nil, itemScrollFrame)
itemContent:SetSize(700, 380)  -- adjust height as needed
itemScrollFrame:SetScrollChild(itemContent)

-- Create a table of lines that will display each transaction (here we create 30 lines)
local itemLines = {}
for i = 1, 30 do
    local line = CreateFrame("Button", nil, itemContent)
    line:SetSize(540, 20)
    line:SetPoint("TOPLEFT", itemContent, "TOPLEFT", 10, -20 * (i - 1))
    
    line.text = line:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    line.text:SetPoint("LEFT")
    line.text:SetSize(540, 20)
    line.text:SetJustifyH("LEFT")
    
    itemLines[i] = line
end

-- Make the main frame movable
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- Make the ItemTransFrame movable
ItemTransFrame:SetMovable(true)
ItemTransFrame:EnableMouse(true)
ItemTransFrame:RegisterForDrag("LeftButton")
ItemTransFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
ItemTransFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

local lines = {}
for i = 1, 20 do -- Assuming a maximum of 20 guild members displayed
    local line = CreateFrame("Button", nil, content)
    line:SetSize(240, 20)
    line:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -20 * (i - 1))

    line.text = line:CreateFontString(nil, "OVERLAY")
    line.text:SetFontObject("GameFontNormal")
    line.text:SetPoint("LEFT")
    line.text:SetSize(240, 20)
    line.text:SetJustifyH("LEFT")

    lines[i] = line
end

-- Create a warning window for sending a message
local warnFrame = CreateFrame("Frame", "FinanzamtWarnFrame", UIParent, "BasicFrameTemplateWithInset")
warnFrame:SetSize(300, 120)
warnFrame:SetPoint("CENTER")
warnFrame:SetFrameStrata("DIALOG")  -- Ensure it appears on top
warnFrame:Hide()  -- Hide it initially

warnFrame.title = warnFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
warnFrame.title:SetPoint("CENTER", warnFrame.TitleBg, "CENTER", 0, 0)
warnFrame.title:SetText("Mahnung senden")

-- Create a dropdown menu for selecting a recipient
local recipientDropdown = CreateFrame("Frame", "FinanzamtWarnRecipientDropdown", warnFrame, "UIDropDownMenuTemplate")
recipientDropdown:SetPoint("TOP", warnFrame, "TOP", 0, -40)
UIDropDownMenu_SetWidth(recipientDropdown, 200)
UIDropDownMenu_SetText(recipientDropdown, "Empfänger wählen")

-- Initialization function for the dropdown menu
local function InitializeRecipientDropdown(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    local numMembers = GetNumGuildMembers()  -- Retrieves the number of guild members
    for i = 1, numMembers do
        local name, rank, rankIndex, memberLevel, class, zone, note, officernote, online, status, classFileName, achievementPoints = GetGuildRosterInfo(i)
        if name then
            local fullName = name
            if not string.find(name, "-") then
                fullName = name .. "-" .. GetRealmName()
            end
            info.text = fullName
            info.value = fullName
            info.func = function(self)
                UIDropDownMenu_SetSelectedValue(recipientDropdown, self.value)
                UIDropDownMenu_SetText(recipientDropdown, self.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

UIDropDownMenu_Initialize(recipientDropdown, InitializeRecipientDropdown)

-- Create the Send button
local sendButton = CreateFrame("Button", "FinanzamtWarnSendButton", warnFrame, "GameMenuButtonTemplate")
sendButton:SetSize(120, 25)
sendButton:SetPoint("BOTTOM", warnFrame, "BOTTOM", 55, 20)
sendButton:SetText("Senden")
sendButton:SetNormalFontObject("GameFontNormal")
sendButton:SetScript("OnClick", function(self)
    local recipient = UIDropDownMenu_GetSelectedValue(recipientDropdown)
    if recipient and recipient ~= "" then
        local message = "Dies ist eine Mahnung! Der Monatsbeitrag von 10.000 Gold für die Gilde Raufasertapete ist noch nicht erfolgt! Bitte überweisen Sie das nötige Gold zeitnah!"
        local subject = "Mahnung"
        
        -- Check if the MailFrame is open (which indicates you are at a mailbox)
        if MailFrame and MailFrame:IsShown() then
            SendMail(recipient, subject, message)
            print("Mahnung an " .. recipient .. " per Mail gesendet.")
        else
            -- Send a whisper if the recipient is online.
            SendChatMessage(message, "WHISPER", nil, recipient)
            print("Mahnung an " .. recipient .. " per Whisper gesendet.")
        end
        
        warnFrame:Hide()
    else
        print("Bitte wählen Sie einen Empfänger aus.")
    end
end)

-- Create a Cancel button to close the window without sending
local cancelButton = CreateFrame("Button", "FinanzamtWarnCancelButton", warnFrame, "GameMenuButtonTemplate")
cancelButton:SetSize(120, 25)
cancelButton:SetPoint("RIGHT", sendButton, "LEFT", 10, 0)
cancelButton:SetText("Abbrechen")
cancelButton:SetScript("OnClick", function(self)
    warnFrame:Hide()
end)


-- Stores deposits per player
local guildDeposits = {}

local function RequestGuildBankData()
    if not IsInGuild() then
        print("[Finanzamt] Du bist nicht in einer Gilde.")
        return
    end

    if not GuildBankFrame or not GuildBankFrame:IsShown() then
        print("[Finanzamt] Öffne die Gildenbank, um Daten zu laden.")
        return
    end

    for tab = 1, GetNumGuildBankTabs() do
        QueryGuildBankLog(tab)
    end
end

local function UpdateGuildBankMoneyDisplay()
    if not GuildBankFrame or not GuildBankFrame:IsShown() then
        print("[Finanzamt] Öffne die Gildenbank, um Daten zu laden.")
        return
    end

    local totalMoney = GetGuildBankMoney()  -- Returns money in copper
    if not totalMoney then return end
    
    -- Save the money value to the saved variable:
    FinanzamtDB.totalMoney = totalMoney

    local goldAmount   = math.floor(totalMoney / 10000)
    local silverAmount = math.floor((totalMoney % 10000) / 100)
    local copperAmount = totalMoney % 100

    guildBalanceText:SetText(goldAmount)
    silverText:SetText(silverAmount)
    copperText:SetText(copperAmount)
end

local function UpdateGuildBankDeposits()
    if not GuildBankFrame or not GuildBankFrame:IsShown() then
        print("[Finanzamt] Öffne die Gildenbank, um die Transaktionsdaten zu laden.")
        return
    end

    guildDeposits = {}

    for transactionNumber = 1, GetNumGuildBankMoneyTransactions() do
        local transactionType, playerName, amount, years, months, days, hours = GetGuildBankMoneyTransaction(transactionNumber)

        print("DEBUG: Transaktion", transactionNumber, "Typ:", transactionType, "Spieler:", playerName, "Amount:", amount, "years:", years, "months:", months, "days:", days, "hours:", hours)

        if transactionType == "deposit" then
            if amount and amount > 0 then
                guildDeposits[playerName] = (guildDeposits[playerName] or 0) + amount
            end
        end
        
    end


    -- Umrechnung von Kupfer zu Gold (1 Gold = 10.000 Kupfer)
    for player, amount in pairs(guildDeposits) do
        guildDeposits[player] = math.floor(amount / 10000)
    end

    -- Leere alle alten Zeilen (optional)
    for i = 1, #lines do
        lines[i].text:SetText("")
        if lines[i].icon then
            lines[i].icon:Hide()
        end
    end

    -- Sortiere die Spielernamen alphabetisch
    local sortedPlayers = {}
    for player in pairs(guildDeposits) do
        table.insert(sortedPlayers, player)
    end
    table.sort(sortedPlayers)

    -- Fülle das ScrollFrame mit den Daten
    for i, player in ipairs(sortedPlayers) do
        if lines[i] then
            local depositGold = guildDeposits[player] or 0
            lines[i].text:SetText(player .. ": " .. depositGold .. " gold")

            if not lines[i].icon then
                lines[i].icon = lines[i]:CreateTexture(nil, "OVERLAY")
                lines[i].icon:SetSize(16, 16)
                lines[i].icon:SetPoint("RIGHT", lines[i], "RIGHT", -10, 0)
            end

            if depositGold >= 10000 then
                lines[i].icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
            else
                lines[i].icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
            end
            lines[i].icon:Show()
        end
    end

    if #sortedPlayers == 0 then
        print("[Finanzamt] Keine Geldatransaktionen gefunden.")
    end
end

-- NEW FUNCTION:
-- Update the full transaction history by iterating over all guild bank tabs
-- and saving the transaction strings in FinanzamtDB.transactions.
local function UpdateTransactionHistory()
    -- Clear out any previous transaction history
    FinanzamtDB.transactions = {}
    
    if not GuildBankFrame or not GuildBankFrame:IsShown() then
        print("[Finanzamt] Öffne die Gildenbank, um die Transaktionsdaten zu laden.")
        return
    end

    local transactions = {}  -- Start fresh

    for tab = 1, GetNumGuildBankTabs() do
        local numTrans = GetNumGuildBankTransactions(tab)
        for i = 1, numTrans do
            local numReturn = select("#", GetGuildBankTransaction(tab, i))
            local transactionType, playerName, arg3, arg4, arg5 = GetGuildBankTransaction(tab, i)

            -- Choose an icon based on the transaction type.
            local iconPath
            if transactionType == "deposit" then
                iconPath = "Interface\\RAIDFRAME\\ReadyCheck-Ready"
            elseif transactionType == "withdraw" then
                iconPath = "Interface\\RAIDFRAME\\ReadyCheck-NotReady"
            else
                iconPath = "Interface\\Icons\\INV_Misc_QuestionMark" -- Fallback icon.
            end

            local item, amount
            -- If arg3 is a string, we assume it's an item link.
            if type(arg3) == "string" then
                item = arg3
                amount = arg4 or 0
            elseif type(arg3) == "number" then
                item = "Geld"  -- For money-only transactions.
                amount = arg3
            else
                item = "Unknown"
                amount = 0
            end

            -- Build the string using the inline texture tag.
            -- Format: Playername | [Icon] | Item | Amount
            local transactionString = playerName .. " |T" .. iconPath .. ":16:16|t | " .. item .. " | Anzahl: " .. amount
            table.insert(transactions, transactionString)
        end
    end

    FinanzamtDB.transactions = transactions
end


SLASH_FINANZAMTRESET1 = "/finreset"
SlashCmdList["FINANZAMTRESET"] = function(msg)
    FinanzamtDB.transactions = {}
    print("[Finanzamt] Item Transaktionen zurückgesetzt. Historie geleert.")
end

-- Modify the event handler to also update the transaction history
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("GUILDBANKLOG_UPDATE")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "GUILDBANKLOG_UPDATE" then
        UpdateGuildBankDeposits()
        UpdateGuildBankMoneyDisplay()
        UpdateTransactionHistory()  -- update and save the full transaction history
    end
end)

-- Test 
local function TestDaten()
    local testMoney = 0
    testMoney = testMoney + 1000
    guildBalanceText:SetText(testMoney)
end
-- Test Ende

-- Display the saved money when the main frame is shown
local function DisplaySavedMoney()
    if FinanzamtDB and FinanzamtDB.totalMoney then
        local totalMoney = FinanzamtDB.totalMoney
        local goldAmount   = math.floor(totalMoney / 10000)
        local silverAmount = math.floor((totalMoney % 10000) / 100)
        local copperAmount = totalMoney % 100

        guildBalanceText:SetText(goldAmount)
        silverText:SetText(silverAmount)
        copperText:SetText(copperAmount)
    end
end

frame:SetScript("OnShow", DisplaySavedMoney)

-- MODIFIED FUNCTION:
-- Update the ItemTransFrame using the saved transaction history from FinanzamtDB.
local function UpdateItemTransFrame()
    -- Clear all previous transaction lines
    for i = 1, #itemLines do
        itemLines[i].text:SetText("")
    end

    local transactions = FinanzamtDB.transactions or {}

    -- Populate the itemLines with the transaction data
    for i, transaction in ipairs(transactions) do
        if itemLines[i] then
            itemLines[i].text:SetText(transaction)
        end
    end
end

-- Button to manually refresh guild bank data
local refreshButton = CreateFrame("Button", "FinanzamtRefreshButton", frame, "GameMenuButtonTemplate")
refreshButton:SetSize(180, 25)
refreshButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 10)
refreshButton:SetText("Daten aktualisieren")
refreshButton:SetScript("OnClick", function()
    print("[Finanzamt] Lade Bankdaten....")
    RequestGuildBankData()
    UpdateGuildBankMoneyDisplay()
end)

-- Position the Item Transaktionen button to the right of the refresh button
itemTransButton:SetPoint("LEFT", refreshButton, "RIGHT", 10, 0)
itemTransButton:SetText("Item Transaktionen")
itemTransButton:SetScript("OnClick", function()
    if ItemTransFrame and ItemTransFrame:IsShown() then
        ItemTransFrame:Hide()
    else
        UpdateItemTransFrame()  -- refresh the transaction list from storage
        ItemTransFrame:Show()
    end
end)

-- Create the "Mahnung senden" button on the right-hand side of the main frame
local warnButton = CreateFrame("Button", "FinanzamtWarnButton", frame, "GameMenuButtonTemplate")
warnButton:SetSize(100, 25)
-- Position the button on the right-hand side of the main frame (adjust the offsets as needed)
warnButton:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
warnButton:SetText("Mahnungen")
warnButton:SetNormalFontObject("GameFontNormal")

-- Optionally, add an OnClick handler for the button
warnButton:SetScript("OnClick", function(self)
    warnFrame:Show()
    UIDropDownMenu_Initialize(recipientDropdown, InitializeRecipientDropdown) -- Refresh the list in case the guild roster has changed.
end)