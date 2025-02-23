---@class Finanzamt : AceAddon, AceConsole-3.0, AceEvent-3.0
local Finanzamt = LibStub("AceAddon-3.0"):GetAddon("Finanzamt") -- Get Addon Namespace



-- Create the main frame for the Add-On
local frame = CreateFrame("Frame", "FinanzamtFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(600, 400) -- Width, Height---
frame:SetPoint("CENTER") -- Center of the screen
frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
frame.title:SetText("Raufasertapete - Finanzamt")
frame:SetFrameStrata("HIGH")

-- Make the main frame movable
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
frame:SetScript("OnShow", Finanzamt.DisplaySavedMoney)

-- Button to open the Item Transaktionen window
local itemTransButton = CreateFrame("Button", "FinanzamtItemTransButton", frame, "GameMenuButtonTemplate")
itemTransButton:SetSize(180, 25)

-- Scrollable list to display all transactions that are still locally stored
local scrollFrameInfo = CreateFrame("Button", nil, frame)
scrollFrameInfo:SetSize(300, 20)
scrollFrameInfo:SetPoint("TOPLEFT", frame, "TOPLEFT", 100, -40)
scrollFrameInfo.text = scrollFrameInfo:CreateFontString(nil, "OVERLAY")
scrollFrameInfo.text:SetFontObject("ChatFontNormal")
scrollFrameInfo.text:SetPoint("LEFT")
scrollFrameInfo.text:SetSize(300, 20)
scrollFrameInfo.text:SetJustifyH("LEFT")
scrollFrameInfo.text:SetText("Lokal gespeicherte Transaktionen:")

local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(450, 260)
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 100, -70)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(450, 260)
scrollFrame:SetScrollChild(content)

-- Create a texture for the image
local imageTexture = frame:CreateTexture(nil, "ARTWORK")
imageTexture:SetSize(64, 64)  -- Set the width and height (adjust as needed)
imageTexture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 30, 30)  -- Position in bottom left
imageTexture:SetTexture("Interface\\AddOns\\Finanzamt\\adler.tga") 

-- Create FontStrings for displaying the guild balance
local goldText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -110, 15) -- Adjusted to fit all icons
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

function Finanzamt:UpdateMoneyTransactionDisplay()
    for i = 1,#Finanzamt.db.profile.MoneyTransactions do
        local line = CreateFrame("Frame", nil, content)
        line:SetSize(400, 20)
        line:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -20 * (i - 1))

        local btnTimeStamp = CreateFrame("Button", nil, line)
        btnTimeStamp:SetSize(150, 20)
        btnTimeStamp:SetPoint("LEFT", line, "LEFT", 0, 0)
        btnTimeStamp.text = btnTimeStamp:CreateFontString(nil, "OVERLAY")
        btnTimeStamp.text:SetFontObject("ChatFontNormal")
        btnTimeStamp.text:SetPoint("LEFT")
        btnTimeStamp.text:SetSize(150, 20)
        btnTimeStamp.text:SetJustifyH("LEFT")
        local timeStamp = date("%d.%m.%Y %H:%M:%S", Finanzamt.db.profile.MoneyTransactions[i].TimeStamp)
        btnTimeStamp.text:SetText(timeStamp .. " ||")
        line.btnTimeStamp = btnTimeStamp

        local btnMoney = CreateFrame("Button", nil, line)
        btnMoney:SetSize(100, 20)
        btnMoney:SetPoint("LEFT", btnTimeStamp, "RIGHT", 10, 0)
        btnMoney.text = btnMoney:CreateFontString(nil, "OVERLAY")
        btnMoney.text:SetFontObject("ChatFontNormal")
        btnMoney.text:SetPoint("LEFT")
        btnMoney.text:SetSize(100, 20)
        btnMoney.text:SetJustifyH("RIGHT")
        local value = C_CurrencyInfo.GetCoinTextureString(Finanzamt.db.profile.MoneyTransactions[i].Value)
        btnMoney.text:SetText(value)
        line.btnMoney = btnMoney

        local btnAction = CreateFrame("Button", nil, line)
        btnAction:SetSize(70, 20)
        btnAction:SetPoint("LEFT", btnMoney, "RIGHT", 10, 0)
        btnAction.text = btnAction:CreateFontString(nil, "OVERLAY")
        btnAction.text:SetFontObject("ChatFontNormal")
        btnAction.text:SetPoint("LEFT")
        btnAction.text:SetSize(70, 20)
        btnAction.text:SetJustifyH("LEFT")

        local action = "abgehoben"
        if Finanzamt.db.profile.MoneyTransactions[i].Action == "Deposit" then
            action = "eingezahlt"
        end
        btnAction.text:SetText(action)
        line.btnAction = btnAction

        local btnComment = CreateFrame("Button", nil, line, "UIPanelButtonTemplate")
        btnComment:SetSize(100, 20)
        btnComment:SetPoint("LEFT", btnAction, "RIGHT", 0, 0)
        btnComment.text = btnComment:CreateFontString(nil, "OVERLAY")
        btnComment.text:SetFontObject("ChatFontNormal")
        btnComment.text:SetPoint("CENTER")
        btnComment.text:SetSize(100, 20)
        btnComment.text:SetJustifyH("CENTER")
        btnComment.text:SetText("Kommentar")
        btnComment:SetScript("OnClick", function()
            Finanzamt:CreateCommentWindow(i) -- Pass the index to edit the correct entry
        end)
        btnComment:RegisterForClicks("AnyDown", "AnyUp")
        line.btnComment = btnComment

        Finanzamt.lines[i] = line
    end
end

function Finanzamt:CreateCommentWindow(index)
    if Finanzamt.commentWindow then
        Finanzamt.commentWindow:Hide() -- Hide previous window if it exists
    end

    -- Create the main frame (window)
    local commentFrame = CreateFrame("Frame", "FinanzamtCommentWindow", UIParent, "BackdropTemplate")
    commentFrame:SetSize(300, 150)
    commentFrame:SetPoint("CENTER")
    commentFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    commentFrame:SetFrameStrata("DIALOG")
    commentFrame:SetMovable(true)
    commentFrame:EnableMouse(true)
    commentFrame:RegisterForDrag("LeftButton")
    commentFrame:SetScript("OnDragStart", commentFrame.StartMoving)
    commentFrame:SetScript("OnDragStop", commentFrame.StopMovingOrSizing)

    -- Title text
    local title = commentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", commentFrame, "TOP", 0, -10)
    title:SetText("Kommentar bearbeiten")

    -- Input field
    local editBox = CreateFrame("EditBox", nil, commentFrame, "InputBoxTemplate")
    editBox:SetSize(260, 25)
    editBox:SetPoint("TOP", commentFrame, "TOP", 0, -40)
    editBox:SetAutoFocus(true)
    editBox:SetText(Finanzamt.db.profile.MoneyTransactions[index].Comment or "") -- Preload value

    -- Save Button
    local btnSave = CreateFrame("Button", nil, commentFrame, "UIPanelButtonTemplate")
    btnSave:SetSize(80, 22)
    btnSave:SetPoint("BOTTOMLEFT", commentFrame, "BOTTOMLEFT", 20, 20)
    btnSave:SetText("Speichern")
    btnSave:SetScript("OnClick", function()
        Finanzamt.db.profile.MoneyTransactions[index].Comment = editBox:GetText()
        Finanzamt:DebugMessage("Kommentar gespeichert:", editBox:GetText())
        commentFrame:Hide()
    end)

    -- Cancel Button
    local btnCancel = CreateFrame("Button", nil, commentFrame, "UIPanelButtonTemplate")
    btnCancel:SetSize(80, 22)
    btnCancel:SetPoint("BOTTOMRIGHT", commentFrame, "BOTTOMRIGHT", -20, 20)
    btnCancel:SetText("Abbrechen")
    btnCancel:SetScript("OnClick", function()
        Finanzamt:DebugMessage("Kommentar Bearbeitung abgebrochen.")
        commentFrame:Hide()
    end)

    Finanzamt.commentWindow = commentFrame -- Store window reference
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
            Finanzamt:DebugMessage("Mahnung an " .. recipient .. " per Mail gesendet.")
        else
            -- Send a whisper if the recipient is online.
            SendChatMessage(message, "WHISPER", nil, recipient)
            Finanzamt:DebugMessage("Mahnung an " .. recipient .. " per Whisper gesendet.")
        end
        
        warnFrame:Hide()
    else
        Finanzamt:ConsoleMessage("Bitte wählen Sie einen Empfänger aus.")
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
    Finanzamt:ConsoleMessage("Lade Bankdaten....")
    Finanzamt:RequestGuildBankData()
    Finanzamt:UpdateGuildBankMoneyDisplay()
end)


-- Update the ItemTransFrame using the saved transaction history from FinanzamtDB.
local function UpdateItemTransFrame()
    -- Clear all previous transaction lines
    for i = 1, #itemLines do
        itemLines[i].text:SetText("")
    end

    local transactions = Finanzamt.db.profile.transactions or {}
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



--Disabled functionality that is not ready for live yet
refreshButton:Hide()
itemTransButton:Hide()
warnButton:Hide()