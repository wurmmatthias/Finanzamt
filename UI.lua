---@type _, Finanzamt
local _, Finanzamt = ... -- Get Adddon Namespace

-- Load required libraries
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

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

-- Make the main frame movable
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

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
local goldText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -100, 15) -- Adjusted to fit all icons
goldText:SetText("0")

-- Create the gold coin icon
local goldIcon = frame:CreateTexture(nil, "ARTWORK")
goldIcon:SetSize(16, 16)
goldIcon:SetPoint("LEFT", goldText, "RIGHT", 2, 0)
goldIcon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")

Finanzamt.UI.GB_Gold = goldText

-- Create the silver coin icon
local silverText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
silverText:SetPoint("LEFT", goldIcon, "RIGHT", 5, 0)
silverText:SetText("0")

local silverIcon = frame:CreateTexture(nil, "ARTWORK")
silverIcon:SetSize(16, 16)
silverIcon:SetPoint("LEFT", silverText, "RIGHT", 2, 0)
silverIcon:SetTexture("Interface\\MoneyFrame\\UI-SilverIcon")

Finanzamt.UI.GB_Silver = silverText

-- Create the copper coin icon
local copperText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
copperText:SetPoint("LEFT", silverIcon, "RIGHT", 5, 0)
copperText:SetText("0")

local copperIcon = frame:CreateTexture(nil, "ARTWORK")
copperIcon:SetSize(16, 16)
copperIcon:SetPoint("LEFT", copperText, "RIGHT", 2, 0)
copperIcon:SetTexture("Interface\\MoneyFrame\\UI-CopperIcon")

Finanzamt.UI.GB_Copper = copperText

frame:Hide()
Finanzamt.UI.Main = frame

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

-- Make the ItemTransFrame movable
ItemTransFrame:SetMovable(true)
ItemTransFrame:EnableMouse(true)
ItemTransFrame:RegisterForDrag("LeftButton")
ItemTransFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
ItemTransFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

ItemTransFrame:Hide()

-- Create a scroll frame inside the item transactions frame
local itemScrollFrame = CreateFrame("ScrollFrame", nil, ItemTransFrame, "UIPanelScrollFrameTemplate")
itemScrollFrame:SetSize(600, 400)
itemScrollFrame:SetPoint("TOP", ItemTransFrame, "TOP", 0, -40)

local itemContent = CreateFrame("Frame", nil, itemScrollFrame)
itemContent:SetSize(700, 380)  -- adjust height as needed
itemScrollFrame:SetScrollChild(itemContent)
Finanzamt.UI.ItemContentFrame = itemContent

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


for i = 1, 20 do -- Assuming a maximum of 20 guild members displayed
    local line = CreateFrame("Button", nil, content)
    line:SetSize(240, 20)
    line:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -20 * (i - 1))

    line.text = line:CreateFontString(nil, "OVERLAY")
    line.text:SetFontObject("GameFontNormal")
    line.text:SetPoint("LEFT")
    line.text:SetSize(240, 20)
    line.text:SetJustifyH("LEFT")

    Finanzamt.lines[i] = line
end

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


-- Button to manually refresh guild bank data
local refreshButton = CreateFrame("Button", "FinanzamtRefreshButton", frame, "GameMenuButtonTemplate")
refreshButton:SetSize(180, 25)
refreshButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 10)
refreshButton:SetText("Daten aktualisieren")
refreshButton:SetScript("OnClick", function()
    print("[Finanzamt] Lade Bankdaten....")
    Finanzamt:RequestGuildBankData()
    Finanzamt:UpdateGuildBankMoneyDisplay()
end)

-- Update the ItemTransFrame using the saved transaction history from FinanzamtDB.
local function UpdateItemTransFrame()
    -- Clear all previous transaction lines
    for i = 1, #itemLines do
        itemLines[i].text:SetText("")
    end

    local transactions = FinanzamtDB.transactions or {}
    local numTransactions = #transactions

    -- If we have fewer lines than transactions, create new lines dynamically.
    if #itemLines < numTransactions then
        for i = #itemLines + 1, numTransactions do
            local line = CreateFrame("Button", nil, itemContent)
            line:SetSize(540, 20)
            line:SetPoint("TOPLEFT", itemContent, "TOPLEFT", 10, -20 * (i - 1))

            line.text = line:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            line.text:SetPoint("LEFT")
            line.text:SetSize(540, 20)
            line.text:SetJustifyH("LEFT")
            itemLines[i] = line
        end
    end

    -- Populate the itemLines with the transaction data
    -- Update (or show/hide) each line according to the transaction data.
    for i, transaction in ipairs(transactions) do
        if itemLines[i] then
            itemLines[i].text:SetText(transaction)
            itemLines[i]:Show()
        end
    end

    -- Hide any extra lines that aren’t used.
    for i = numTransactions + 1, #itemLines do
        itemLines[i]:Hide()
    end

    -- Adjust the height of the scroll child (itemContent) based on the number of transactions.
    local newHeight = math.max(380, numTransactions * 20 + 20)
    itemContent:SetHeight(newHeight)
end

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
