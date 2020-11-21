loot = {copper = 0, silver = 0, gold = 0}

-- functions
local function handleloot(self, event, msg, author, ...)

	numLootItems = GetNumLootItems()

	if (numLootItems >= 1) then
		for i = numLootItems, 1, -1
		do
			local lootIcon,	lootName, lootQuantity, rarity = GetLootSlotInfo(i)

			hasGold = string.find(lootName, 'Gold')
			hasSilver = string.find(lootName, 'Silver')
			hasCopper = string.find(lootName, 'Copper')

			if (hasGold == nil and hasSilver == nil and hasCopper == nil) then
				if (loot[lootName]) then
					loot[lootName] =  loot[lootName] + lootQuantity
				else
					loot[lootName] =  lootQuantity
				end
			end
		end
	end
end

local function FormatMoney(money)
	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = mod(money, COPPER_PER_SILVER)
	return { gold = gold, silver = silver, copper = copper }
end

local function handleMoneyRollOver(moneyType, rollOverType, total)
	if (loot[moneyType] + total >= 100) then
		remainder = loot[moneyType] + total - 100
		loot[moneyType] = remainder
		if (rollOverType ~= nil) then
			loot[rollOverType] = loot[rollOverType] + 1
		end
	else
		loot[moneyType] =	loot[moneyType] + total
	end
end

local function handleMoney(self, event, msg,...)
	local tmpMoney = GetMoney()

	if self.CurrentMoney then
		self.DiffMoney = tmpMoney - self.CurrentMoney
	else
		self.DiffMoney = 0
	end

	self.CurrentMoney = tmpMoney
	moneyLooted = FormatMoney(self.DiffMoney)
	handleMoneyRollOver('gold', nil , moneyLooted.gold)
	handleMoneyRollOver( 'silver', 'gold', moneyLooted.silver)
	handleMoneyRollOver( 'copper', 'silver', moneyLooted.copper)
end

local function handleShowLootClick()
	print("This is your loot")
	-- print('Gold ' .. loot.gold .. ' Silver ' .. loot.silver .. ' Copper ' .. loot.copper)
	for k,v in pairs(loot) do
		print(k, v)
	end
end

-- slashCMD
SLASH_DISPLAY_LOOT1 = "/showloot"
SlashCmdList["DISPLAY_LOOT"] = function(msg)
	print("This is your loot")
	for k, v in pairs(loot) do
		print(k, v )
	end
end

SLASH_RESET_LOOT1 = "/resetloot"
SlashCmdList["RESET_LOOT"] = function(msg)
	print("Resetting Loot Treacker")
	loot = {copper = 0, silver = 0, gold = 0}
end

-- frames
local lootFrame=CreateFrame("Frame")
local moneyFrame = CreateFrame("Frame")
local showLootButton = CreateFrame("Button", "Loot Tracker", UIParent, 'UIPanelButtonTemplate')

-- register event
lootFrame:RegisterEvent("LOOT_OPENED")
moneyFrame:RegisterEvent("PLAYER_MONEY")
moneyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
showLootButton:RegisterForClicks("LeftButtonUp")

-- set script
lootFrame:SetScript("OnEvent", handleloot)
moneyFrame:SetScript("OnEvent", handleMoney)
showLootButton:SetScript("OnClick", handleShowLootClick)
showLootButton:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
showLootButton:SetScript("OnLeave", function(self) self:SetAlpha(0.2) end)

-- ui placment
showLootButton:SetSize(75,25)
showLootButton:SetPoint("BOTTOMLEFT", 25, 300)
showLootButton:SetText('Show Loot')
showLootButton:SetAlpha(1)