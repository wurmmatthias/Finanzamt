---@class Finanzamt : AceAddon, AceConsole-3.0, AceEvent-3.0
local Finanzamt = LibStub("AceAddon-3.0"):GetAddon("Finanzamt") -- Get Addon Namespace


-- Subscribe to GUILDBANK_UPDATE_MONEY
function Finanzamt:CheckGuildBankMoneyTransaction()
    if GuildBankFrame and GuildBankFrame:IsShown() then
        local transactionValue = GetGuildBankMoney() - Finanzamt.db.profile.totalMoney
        local playerMoneyChange = Finanzamt.db.profile.totalPlayerMoney - GetMoney()

        Finanzamt:DebugMessage("GBM", GetGuildBankMoney(), "totalMoney:", Finanzamt.db.profile.totalMoney, "M", GetMoney(), "totalPlayerMoney", Finanzamt.db.profile.totalPlayerMoney)

        if transactionValue ~= playerMoneyChange then
            Finanzamt:DebugMessage("Es wurde eine Änderung am Gildenbetrag festgestellt:", transactionValue, "Diese kam aber nicht vom Spieler:", playerMoneyChange) 
            return
        else
            if transactionValue > 0 then
                local moneyTransaction = {}
                moneyTransaction.PlayerGUID = UnitGUID("player")
                moneyTransaction.Action = "Deposit"
                moneyTransaction.Value = transactionValue
                moneyTransaction.TimeStamp = GetServerTime()

                table.insert(Finanzamt.db.profile.MoneyTransactions, moneyTransaction)
                Finanzamt:ConsoleMessage("Es wurden ", transactionValue, " von ", UnitFullName("player"), " in die Gildenbank eingezahlt.")
            else
                local moneyTransaction = {}
                moneyTransaction.PlayerGUID = UnitGUID("player")
                moneyTransaction.Action = "Withdrawal"
                moneyTransaction.Value = transactionValue
                moneyTransaction.TimeStamp = GetServerTime()

                table.insert(Finanzamt.db.profile.MoneyTransactions, moneyTransaction)
                Finanzamt:ConsoleMessage("Es wurden ", transactionValue, " von ", UnitFullName("player"), " aus der Gildenbank abgehoben.")
            end    
        end
        Finanzamt:UpdateGuildBankMoneyDisplay()
        Finanzamt.db.profile.totalPlayerMoney = GetMoney()
        Finanzamt:UpdateMoneyTransactionDisplay()
    end
end



    
    -- Stores deposits per player
function Finanzamt:RequestGuildBankData()
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

function Finanzamt:UpdateGuildBankMoneyDisplay()
    if not GuildBankFrame or not GuildBankFrame:IsShown() then
        Finanzamt:ConsoleMessage("Öffne die Gildenbank, um Daten zu laden.")
        return
    end

    local totalMoney = GetGuildBankMoney()  -- Returns money in copper
    if not totalMoney then return end
    
    -- Save the money value to the saved variable:
    Finanzamt.db.profile.totalMoney = totalMoney

    local serverTime = GetServerTime()
    if not serverTime then return end
    Finanzamt.db.profile.totalMoneyTimestamp = serverTime

    local goldAmount   = math.floor(totalMoney / 10000)
    local silverAmount = math.floor((totalMoney % 10000) / 100)
    local copperAmount = totalMoney % 100

    Finanzamt.UI.GB_Gold:SetText(goldAmount)
    Finanzamt.UI.GB_Silver :SetText(silverAmount)
    Finanzamt.UI.GB_Copper:SetText(copperAmount)
end

function Finanzamt:UpdateGuildBankDeposits()
    if not GuildBankFrame or not GuildBankFrame:IsShown() then
        Finanzamt:ConsoleMessage("Öffne die Gildenbank, um die Transaktionsdaten zu laden.")
        return
    end

    for transactionNumber = 1, GetNumGuildBankMoneyTransactions() do
        local transactionType, playerName, amount, years, months, days, hours = GetGuildBankMoneyTransaction(transactionNumber)

        Finanzamt:DebugMessage("Transaktion", transactionNumber, "Typ:", transactionType, "Spieler:", playerName, "Amount:", amount, "years:", years, "months:", months, "days:", days, "hours:", hours)

        if transactionType == "deposit" then
            if amount and amount > 0 then
                Finanzamt.guildDeposits[playerName] = (Finanzamt.guildDeposits[playerName] or 0) + amount
            end
        end
        
    end

    -- Umrechnung von Kupfer zu Gold (1 Gold = 10.000 Kupfer)
    for player, amount in pairs(Finanzamt.guildDeposits) do
        Finanzamt.guildDeposits[player] = math.floor(amount / 10000)
    end

    -- Leere alle alten Zeilen (optional)
    for i = 1, #Finanzamt.lines do
        Finanzamt.lines[i].text:SetText("")
        if Finanzamt.lines[i].icon then
            Finanzamt.lines[i].icon:Hide()
        end
    end

    -- Sortiere die Spielernamen alphabetisch
    local sortedPlayers = {}
    for player in pairs(Finanzamt.guildDeposits) do
        table.insert(sortedPlayers, player)
    end
    table.sort(sortedPlayers)

    -- Fülle das ScrollFrame mit den Daten
    for i, player in ipairs(sortedPlayers) do
        if Finanzamt.lines[i] then
            local depositGold = Finanzamt.guildDeposits[player] or 0
            Finanzamt.lines[i].text:SetText(player .. ": " .. depositGold .. " gold")

            if not Finanzamt.lines[i].icon then
                Finanzamt.lines[i].icon = Finanzamt.lines[i]:CreateTexture(nil, "OVERLAY")
                Finanzamt.lines[i].icon:SetSize(16, 16)
                Finanzamt.lines[i].icon:SetPoint("RIGHT", Finanzamt.lines[i], "RIGHT", -10, 0)
            end

            if depositGold >= 10000 then
                Finanzamt.lines[i].icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
            else
                Finanzamt.lines[i].icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
            end
            Finanzamt.lines[i].icon:Show()
        end
    end

    if #sortedPlayers == 0 then
        Finanzamt:ConsoleMessage("Keine Geldatransaktionen gefunden.")
    end
end


-- NEW FUNCTION:
-- Update the full transaction history by iterating over all guild bank tabs
-- and saving the transaction strings in FinanzamtDB.transactions.
function Finanzamt:UpdateTransactionHistory()
    -- Clear out any previous transaction history
    Finanzamt.db.profile.transactions = {}
    
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

    Finanzamt.db.profile.transactions = transactions
end

-- Display the saved money when the main frame is shown
function Finanzamt:DisplaySavedMoney()
    if Finanzamt.db.profile and Finanzamt.db.profile.totalMoney then
        local totalMoney = Finanzamt.db.profile.totalMoney
        local goldAmount   = math.floor(totalMoney / 10000)
        local silverAmount = math.floor((totalMoney % 10000) / 100)
        local copperAmount = totalMoney % 100

        Finanzamt.UI.GB_Gold:SetText(goldAmount)
        Finanzamt.UI.GB_Silver :SetText(silverAmount)
        Finanzamt.UI.GB_Copper:SetText(copperAmount)
    end
end

function Finanzamt:UpdateGuildbankMoney()
    local totalMoney = GetGuildBankMoney()  -- Returns money in copper
    if not totalMoney then return end  
    -- Save the money value to the saved variable:
    Finanzamt.db.profile.totalMoney = totalMoney
    Finanzamt:DebugMessage("Updated guild money", Finanzamt.db.profile.totalMoney)

    local serverTime = GetServerTime()
    if not serverTime then return end
    Finanzamt.db.profile.totalMoneyTimestamp = serverTime

    Finanzamt:DebugMessage("Updated serverTime", Finanzamt.db.profile.totalMoneyTimestamp)


    local totalPlayerMoney = GetMoney()  -- Returns money in copper
    if not totalPlayerMoney then return end
    -- Save the money value to the saved variable:
    Finanzamt.db.profile.totalPlayerMoney = totalPlayerMoney
    Finanzamt:DebugMessage("Updated player money", Finanzamt.db.profile.totalPlayerMoney)
end

