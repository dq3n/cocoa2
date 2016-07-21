--Button functions

function ToyContainerButton_OnLoad(self)

	SetItemButtonNormalTextureVertexColor(self, 0.85, 0.85, 0.85)
	_G[self:GetName().."NormalTexture"]:SetAlpha(0.85)

    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    self:RegisterForDrag("LeftButton");
	self.Cooldown:SetDrawEdge(false)

end



function ToyContainerCardItem_PreClick(self, button, down)

	if InCombatLockdown() then
		UIErrorsFrame:AddMessage("Cannot access Toy Box while you are in combat", 1.0, 0.1, 0.1, 1.0);
		return
	end

	if button == "LeftButton" then
		local name = self:GetName()
		local toyID = CCB_CHAR_SAVE[name]
		local type, data, subType, subData = GetCursorInfo();

		if type == "item" and PlayerHasToy(data) then 
			self.holdingtoy = true;
		else 
			self.holdingtoy = nil;
		end
		
		local holdingtoy = self.holdingtoy

			if holdingtoy then

				UIErrorsFrame:AddMessage("Items cannot be placed into this container.", 1.0, 0.1, 0.1, 1.0);
				return false
	
			elseif ( type == nil and toyID == nil ) then

				return false
	
			elseif ( type == nil and toyID ) then

				if ( IsModifiedClick("CHATLINK") ) then
					local id = self.toyID;
					if ( MacroFrame and MacroFrame:IsShown() ) then
						local spellName = GetSpellInfo(id);
						ChatEdit_InsertLink(spellName);
					else
						local spellLink = GetSpellLink(id)
						ChatEdit_InsertLink(spellLink);
					end
				else
					C_ToyBox.PickupToyBoxItem(toyID)
					CCB_CHAR_SAVE[name] = nil
				end
	
			elseif ( holdingtoy ) then

				UIErrorsFrame:AddMessage("Items cannot be placed into this container.", 1.0, 0.1, 0.1, 1.0);
			
			end

			CollectionsContainerFrame_Update(self:GetParent())
	end
end


function ToyContainerButton_UpdateTooltip(self)

	local name = self:GetName()
	local index = CCB_CHAR_SAVE[name]
	
	if index ~= nil then
		local itemID, toyName, texture = C_ToyBox.GetToyInfo(index);
				
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetToyByItemID(itemID)									
		self.showingTooltip = true;
		GameTooltip:Show();
	end
end

-- feature functions

function ToyContainerFrameDiceButton_UpdateTooltip(self)

	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if self.disabled == true then
		GameTooltip:SetText("Roll", 1, 1, 1);
		GameTooltip:AddLine("Place 6 toys from your Toy Box into this container to unlock.", nil, nil, nil, true);
	else
		GameTooltip:SetText("Roll", 1, 1, 1);
		GameTooltip:AddLine("Use a random toy from this container.", nil, nil, nil, true);
	end
	self.showingTooltip = true;
	GameTooltip:Show();
	
end


function ToyContainerFrameCardButton_UpdateTooltip(self)

	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if self.disabled == true then
		GameTooltip:SetText("Draw", 1, 1, 1);
		GameTooltip:AddLine("Place 15 different toys into this container to unlock.", nil, nil, nil, true);
	else
		GameTooltip:SetText("Deal", 1, 1, 1);
		GameTooltip:AddLine("Draw 2 toys from your collection.", nil, nil, nil, true);
	end
	self.showingTooltip = true;
	GameTooltip:Show();
	
end




function ToyContainerFrameBoardButton_UpdateTooltip(self)

	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if self.disabled == true then
		GameTooltip:SetText("Set", 1, 1, 1);
		GameTooltip:AddLine("Place 40 different toys into this container to unlock.", nil, nil, nil, true);
	else
		GameTooltip:SetText("Set", 1, 1, 1);
		GameTooltip:AddLine("Open a 9 slot toy container.", nil, nil, nil, true);
	end
	self.showingTooltip = true;
	GameTooltip:Show();
	
end


function ToyContainerFrame_UpdateToysAdded()

	if CCB_CHAR_SAVE["NUM_TOYS_ADDED"] == nil then
		CCB_CHAR_SAVE["NUM_TOYS_ADDED"] = 0
	end


	for i = 1,6 do
		local index = CCB_CHAR_SAVE["ToyContainerFrameItem"..i]
		if index ~= nil then
			if CCB_CHAR_SAVE[index] ~= true then
				CCB_CHAR_SAVE[index] = true 
				CCB_CHAR_SAVE["NUM_TOYS_ADDED"] = CCB_CHAR_SAVE["NUM_TOYS_ADDED"] + 1
			end
		end
	end

end


function ToyContainerFrameDiceButton_UpdateDisabled(self)
	
	self.disabled = true
	ToyContainerFrame_UpdateToysAdded()
	
	if CCB_CHAR_SAVE["NUM_TOYS_ADDED"] >= 6 then
		self.disabled = false
	end
	
	--[[ old code that checks how many toys are in the collection
	
	C_ToyBox.FilterToys();

	--store the current filters so we can restore the ToyBox to the user's preferences after this operation
	local filterCollected = C_ToyBox.GetFilterCollected();
	local filterUncollected = C_ToyBox.GetFilterUncollected();

	C_ToyBox.SetFilterCollected(true);
	C_ToyBox.SetFilterUncollected(false);

	local numToys = C_ToyBox.GetNumFilteredToys()
	
	if numToys > 9 then
		self.disabled = false
	else
		self.disabled = true
	end
	
	C_ToyBox.SetFilterCollected(filterCollected);
	C_ToyBox.SetFilterUncollected(filterUncollected);
	
	ToyContainerFrameDiceButton_SetCooldown(self)]]
	
end


function ToyContainerFrameCardButton_UpdateDisabled(self)

	self.disabled = true
	ToyContainerFrame_UpdateToysAdded()
	
	if CCB_CHAR_SAVE["NUM_TOYS_ADDED"] >= 15 then
		self.disabled = false
	end
	
end


function ToyContainerFrameBoardButton_UpdateDisabled(self)

	self.disabled = true
	ToyContainerFrame_UpdateToysAdded()
	
	if CCB_CHAR_SAVE["NUM_TOYS_ADDED"] >= 40 then
		self.disabled = false
	end

	
end



function ToyContainerFrameDiceButton_PreClick(self, button, down)

	local framename = "ToyContainerFrame";

	local toyTable = {};

	for i = 1, 6 do
		local slot = _G[framename.."Item"..i];
		local name = slot:GetName()
		local index = CCB_CHAR_SAVE[name]
		
		if index then
			--ignore toys on cooldown
			if GetItemCooldown(index) == 0 then
				table.insert(toyTable, index);
			end
		end
	end

	--The button sets itself with SetAttribute("toy",spellID)
	--Only works if there are at least 2 toys meeting the criteria
	if #toyTable >= 1 then
		local i = math.random(1,#toyTable);
		self:SetAttribute("toy", toyTable[i]);
	end	

	ToyContainerFrameDiceButton_SetCooldown(self)
	
	local duration = self.Cooldown:GetCooldownDuration()
	if duration == 0 then
		CooldownFrame_Set(self.Cooldown,GetTime(),0.33,1)
	end

	
end


function ToyContainerFrameDiceButton_SetCooldown(self)

	local targettoy = nil

	for i = 1, 6 do	
		local slot = _G["ToyContainerFrameItem"..i];
		local name = slot:GetName()
		local index = CCB_CHAR_SAVE[name]

		if index then
			local start, duration = GetItemCooldown(index)
			local remaining = duration - (GetTime()-start)
			if targettoy == nil then
				targettoy = remaining
			elseif targettoy > remaining then
				targettoy = remaining
			end
		end
	end
	
	if targettoy == nil then
		targettoy = 0
	end
	
	if targettoy > 0 then
		CooldownFrame_Set(self.Cooldown,GetTime(),targettoy,1)
	else
		CooldownFrame_Set(self.Cooldown,GetTime(),targettoy,0)
	end
end


function ToyContainerFrameCardButton_PreClick(self, button, down)

	local frame = ToyContainerCardFrame

	if frame:IsShown() then
		frame:Hide()
		self.check:Hide()
	else
		ToyContainerFrameCardButton_Shuffle()
		frame:Show()
		self.check:Show()
	end

end

function ToyContainerFrameBoardButton_PreClick(self, button, down)

	local frame = ToyContainerBoardFrame
	
	
	if frame:IsShown() then
		frame:Hide()
		self.check:Hide()
	else
		frame:Show()
		self.check:Show()
	end
end


function ToyContainerFrameCardButton_Shuffle()


	--store the current filters so we can restore the ToyBox to the user's preferences after this operation
	local filterCollected = C_ToyBox.GetFilterCollected();
	local filterUncollected = C_ToyBox.GetFilterUncollected();

	local toyTable = {}
	CCB_CHAR_SAVE["ToyContainerCardFrameItem1"] = nil
	CCB_CHAR_SAVE["ToyContainerCardFrameItem2"] = nil

	--set the filters we need to grab the full list of collected toys
	C_ToyBox.SetFilterCollected(true);
	C_ToyBox.SetFilterUncollected(false);

	local numToys = C_ToyBox.GetNumFilteredToys();
	if numToys > 1 then
		for i = 1, numToys do
			local found = false;
			for j = 1, 6 do
				local name = "ToyContainerFrameItem"..j
				if CCB_CHAR_SAVE[name] == C_ToyBox.GetToyFromIndex(i) then found = true end
			end
			for k = 1, 9 do
				local name = "ToyContainerBoardFrameItem"..k
				if CCB_CHAR_SAVE[name] == C_ToyBox.GetToyFromIndex(i) then found = true end
			end
			if (not found) and GetItemCooldown(C_ToyBox.GetToyFromIndex(i)) == 0 then
				table.insert(toyTable, C_ToyBox.GetToyFromIndex(i));
			end
		end
	end
	
	--in case too many toys are on cooldown
	if #toyTable <= 2 then 
		for i = 1, numToys do
			local found = false;
			for j = 1, 6 do
				local name = "ToyContainerFrameItem"..j
				if CCB_CHAR_SAVE[name] == C_ToyBox.GetToyFromIndex(i) then found = true end
			end
			for k = 1, 9 do
				local name = "ToyContainerBoardFrameItem"..k
				if CCB_CHAR_SAVE[name] == C_ToyBox.GetToyFromIndex(i) then found = true end
			end
			if (not found) then
				table.insert(toyTable, C_ToyBox.GetToyFromIndex(i));
			end
		end
	end

	--since there are only two slots, it's not worth putting in a loop
	if #toyTable >= 2 then
		local n = math.random(1, #toyTable)
		local n2 = 0
		repeat
			n2 = math.random(1, #toyTable)
		until n2 ~= n

		local itemID, toyName, toyIcon = C_ToyBox.GetToyInfo(toyTable[n]);
		local button = _G["ToyContainerCardFrameItem1"]
		local name = button:GetName()
		CCB_CHAR_SAVE[name] = itemID
		
		button.icon:SetTexture(toyIcon);
		button.icon:SetDesaturated(nil);
		button:SetAttribute("toy", itemID);

		itemID, toyName, toyIcon = C_ToyBox.GetToyInfo(toyTable[n2]);
		button = _G["ToyContainerCardFrameItem2"]
		local name = button:GetName()
		CCB_CHAR_SAVE[name] = itemID
		
		
		button.icon:SetTexture(toyIcon);
		button.icon:SetDesaturated(nil);
		button:SetAttribute("toy", itemID);
	end
	
	--reset the filters
	C_ToyBox.SetFilterCollected(filterCollected);
	C_ToyBox.SetFilterUncollected(filterUncollected);
		
end