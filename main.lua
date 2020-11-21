loot = {copper = 0, silver = 0, gold = 0}

local function handleloot(self, event, msg, author, ...)
	-- print('  start  ')
	-- for k in pairs(loot) do
	-- 	print(k)
	-- end

	numLootItems = GetNumLootItems();

	if (numLootItems >= 1) then
		for i = numLootItems, 1, -1
		do
			local lootIcon,	lootName, lootQuantity, rarity = GetLootSlotInfo(i)
			-- print(lootName)

			hasGold = string.find(lootName, 'Gold')
			hasSilver = string.find(lootName, 'Silver')
			hasCopper = string.find(lootName, 'Copper')

			if (hasGold == nil and hasSilver == nil and hasCopper == nil) then
				-- print('past money check')
				-- print(lootName)
				if (loot[lootName]) then
					-- print('add loot quantity ', lootName)
					loot[lootName] =  loot[lootName] + lootQuantity 
				else
					--  this is resetting loot for somereason
					-- print('add new loot ', lootName)
					loot[lootName] =  lootQuantity 
				end
			end
		end
	end

	-- print('  END END  ')
	-- for k, v in pairs(loot) do
	-- 	print(k)
	-- 	print(v)
	-- end

end

SLASH_DISPLAY_LOOT1 = "/showloot"
SlashCmdList["DISPLAY_LOOT"] = function(msg)
	print("This is your loot")
	for k, v in pairs(loot) do
		print(k, v[1] )
	end
end

SLASH_RESET_LOOT1 = "/resetloot"
SlashCmdList["RESET_LOOT"] = function(msg)
	print("Resetting Loot Treacker")
	loot = {}
end

local Frame=CreateFrame("Frame");
Frame:RegisterEvent("LOOT_OPENED");
Frame:SetScript("OnEvent", handleloot);

local showLootButton = CreateFrame("Button", "Loot Tracker", UIParent, 'UIPanelButtonTemplate')
showLootButton:SetSize(75,25)
showLootButton:SetPoint("BOTTOMLEFT", 25, 300)
showLootButton:SetText('Show Loot')
showLootButton:RegisterForClicks("LeftButtonUp")
showLootButton:SetScript("OnClick", function()
	print("This is your loot")
	-- print('Gold ' .. loot.gold .. ' Silver ' .. loot.silver .. ' Copper ' .. loot.copper)
	for k,v in pairs(loot) do
		print(k, v)
	end
end
)

showLootButton:SetAlpha(1)
showLootButton:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
showLootButton:SetScript("OnLeave", function(self) self:SetAlpha(0.2) end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_MONEY")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function FormatMoney(money)
	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);
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

frame:SetScript("OnEvent", function(self, event, msg,...)
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
end)
