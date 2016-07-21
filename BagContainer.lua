local origContainerFrame_OnShow = ContainerFrame_OnEvent

ContainerFrame_OnEvent = function(self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "BAG_OPEN" ) then
		if ( self:GetID() == arg1 ) then
			self:Show();
		end
	elseif ( event == "BAG_CLOSED" ) then
		if ( self:GetID() == arg1 ) then
			self:Hide();
		end
	elseif ( event == "BAG_UPDATE" ) then
		if ( self:GetID() == arg1 ) then
 			ContainerFrame_Update(self);
		end
	elseif ( event == "ITEM_LOCK_CHANGED" ) then
		local bag, slot = arg1, arg2;
		if ( bag and slot and (bag == self:GetID()) ) then
			ContainerFrame_UpdateLockedItem(self, slot);
		end
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		ContainerFrame_UpdateCooldowns(self);
	elseif ( event == "BAG_NEW_ITEMS_UPDATED") then
		ContainerFrame_Update(self);
	elseif ( event == "QUEST_ACCEPTED" or (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player") ) then
		if (self:IsShown()) then
			ContainerFrame_Update(self);
		end
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		UpdateContainerFrameAnchors();
	elseif ( event == "INVENTORY_SEARCH_UPDATE" ) then
		ContainerFrame_UpdateSearchResults(self);
	elseif ( event == "BAG_SLOT_FLAGS_UPDATED" ) then
		if (self:GetID() == arg1) then
			self.localFlag = nil;
			if (self:IsShown()) then
				ContainerFrame_Update(self);
			end
		end
	elseif ( event == "BANK_BAG_SLOT_FLAGS_UPDATED" ) then
		if (self:GetID() == (arg1 + NUM_BAG_SLOTS)) then
			self.localFlag = nil;
			if (self:IsShown()) then
				ContainerFrame_Update(self);
			end
		end
	elseif ( event == "ACTIONBAR_SHOWGRID") or ( event == "ACTIONBAR_HIDEGRID")  then
		local kind = "Bag"
		if C_GetCursorIndex(kind) == false or C_GetCursorIndex(kind) == nil then
			CCB_SHOWBAGKEYS = false
			ContainerFrame_Update(self)
		else
			CCB_SHOWBAGKEYS = true
			ContainerFrame_Update(self)
		end
	end
end


local origContainerFrame_OnShow = ContainerFrame_OnShow

ContainerFrame_OnShow = function(...)
	local self = ...
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
	self:RegisterEvent("BAG_NEW_ITEMS_UPDATED");
	self:RegisterEvent("BAG_SLOT_FLAGS_UPDATED");
	self:RegisterEvent("ACTIONBAR_SHOWGRID")
	self:RegisterEvent("ACTIONBAR_HIDEGRID")


	self.FilterIcon:Hide();
	if ( self:GetID() == 0 ) then
		local shouldShow = true;
		if (IsCharacterNewlyBoosted() or FRAME_THAT_OPENED_BAGS ~= nil) then
			shouldShow = false;
		else
			for i = BACKPACK_CONTAINER + 1, NUM_BAG_SLOTS, 1 do
				if ( not GetInventoryItemID("player", ContainerIDToInventoryID(i)) ) then
					shouldShow = false;
					break;
				end
			end
		end
		if ( shouldShow and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CLEAN_UP_BAGS) ) then
			BagHelpBox:ClearAllPoints();
			BagHelpBox:SetPoint("RIGHT", BagItemAutoSortButton, "LEFT", -24, 0);
			BagHelpBox.Text:SetText(CLEAN_UP_BAGS_TUTORIAL);
			BagHelpBox.owner = self;
			BagHelpBox.wasShown = true;
			BagHelpBox.bitField = LE_FRAME_TUTORIAL_CLEAN_UP_BAGS;
			BagHelpBox:Show();
		end
		MainMenuBarBackpackButton:SetChecked(true);
	elseif ( self:GetID() > 0) then -- The actual bank has ID -1, backpack has ID 0, we want to make sure we're looking at a regular or bank bag
		local button = _G["ccCharacterBag"..(self:GetID() - 1).."Slot"];
		if ( button ) then
			button:SetChecked(true);
		end
		if (not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(self:GetID()))) then
			for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
				local active = false;
				if ( self:GetID() > NUM_BAG_SLOTS ) then
					active = GetBankBagSlotFlag(self:GetID() - NUM_BAG_SLOTS, i);
				else
					active = GetBagSlotFlag(self:GetID(), i);
				end
				if ( active ) then
					self.FilterIcon.Icon:SetAtlas(BAG_FILTER_ICONS[i], true);
					self.FilterIcon:Show();
					break;
				end
			end
		end
		if ( not ContainerFrame1.allBags ) then
			CheckBagSettingsTutorial();
		end
		if ( self:GetID() > NUM_BAG_SLOTS ) then
			UpdateBagButtonHighlight(self:GetID() - NUM_BAG_SLOTS);
		end
	end
	ContainerFrame1.bags[ContainerFrame1.bagsShown + 1] = self:GetName();
	ContainerFrame1.bagsShown = ContainerFrame1.bagsShown + 1;
	if ( self:GetID() == KEYRING_CONTAINER ) then
		UpdateMicroButtons();
		PlaySound("KeyRingOpen");
	else
		PlaySound("igBackPackOpen");
	end
 	ContainerFrame_Update(self);
 	
 	
 	
 	-- Hide Quick Actions
 	
 	if self:GetID() == 0 then
		local slotbutton = BagContainerSlotButton

		if slotbutton.QuickAction:IsShown() then
			slotbutton.FlyoutBorder:Hide()
			slotbutton.FlyoutBorderShadow:Hide()
			slotbutton.QuickAction.FastExit:Play()
		end
	end

	
	-- If there are tokens watched then decide if we should show the bar
	if ( ManageBackpackTokenFrame ) then
		ManageBackpackTokenFrame();
	end
end




local origContainerFrame_OnHide = ContainerFrame_OnHide; 

ContainerFrame_OnHide = function(...)
	local self = ... 
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("INVENTORY_SEARCH_UPDATE");
	self:UnregisterEvent("BAG_NEW_ITEMS_UPDATED");
	self:UnregisterEvent("BAG_SLOT_FLAGS_UPDATED");
	self:UnregisterEvent("ACTIONBAR_SHOWGRID")
	self:UnregisterEvent("ACTIONBAR_HIDEGRID")


	UpdateNewItemList(self);

	if ( self:GetID() == 0 ) then
		MainMenuBarBackpackButton:SetChecked(false);
	else
		local bagButton = _G["ccCharacterBag"..(self:GetID() - 1).."Slot"];
		if ( bagButton ) then
			bagButton:SetChecked(false);
		else
			-- If its a bank bag then update its highlight
			
			UpdateBagButtonHighlight(self:GetID() - NUM_BAG_SLOTS); 
		end
	end
	ContainerFrame1.bagsShown = ContainerFrame1.bagsShown - 1;
	-- Remove the closed bag from the list and collapse the rest of the entries
	local index = 1;
	while ContainerFrame1.bags[index] do
		if ( ContainerFrame1.bags[index] == self:GetName() ) then
			local tempIndex = index;
			while ContainerFrame1.bags[tempIndex] do
				if ( ContainerFrame1.bags[tempIndex + 1] ) then
					ContainerFrame1.bags[tempIndex] = ContainerFrame1.bags[tempIndex + 1];
				else
					ContainerFrame1.bags[tempIndex] = nil;
				end
				tempIndex = tempIndex + 1;
			end
		end
		index = index + 1;
	end
	UpdateContainerFrameAnchors();

	if ( self:GetID() == KEYRING_CONTAINER ) then
		UpdateMicroButtons();
		PlaySound("KeyRingClose");
	else
		if ( self:GetID() == 0 and BagHelpBox.wasShown ) then
			BagHelpBox.wasShown = nil;
		end
		if ( BagHelpBox:IsShown() and BagHelpBox.owner == self ) then
			BagHelpBox.owner = nil;
			BagHelpBox:Hide();
		end
		PlaySound("igBackPackClose");
	end
	CollectionsContainerSlotCheckState(BagContainerSlotButton)
	
end



-- remove search/sort

local origContainerFrame_Update = ContainerFrame_Update; 

ContainerFrame_Update = function(...)
	local frame = ...
	local id = frame:GetID();
	local name = frame:GetName();
	local itemButton;
	local texture, itemCount, locked, quality, readable, _, isFiltered, noValue;
	local isQuestItem, questId, isActive, questTexture;
	local isNewItem, isBattlePayItem, battlepayItemTexture, newItemTexture, flash, newItemAnim;
	local tooltipOwner = GameTooltip:GetOwner();
	
	frame.FilterIcon:Hide();
	if ( id ~= 0 and not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(id)) ) then
		for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
			local active = false;
			if ( id > NUM_BAG_SLOTS ) then
				active = GetBankBagSlotFlag(id - NUM_BAG_SLOTS, i);
			else
				active = GetBagSlotFlag(id, i);
			end
			if ( active ) then
				frame.FilterIcon.Icon:SetAtlas(BAG_FILTER_ICONS[i], true);
				frame.FilterIcon:Show();
				break;
			end
		end
	end

	--Remove sort/search and add bag buttons
	if ( id == 0 ) then
		BagItemSearchBox:ClearAllPoints();
		BagItemSearchBox:Hide();
		BagItemSearchBox.anchorBag = frame;
		BagItemAutoSortButton:ClearAllPoints();
		BagItemAutoSortButton:Hide();
		

		for i=0, 3, 1 do
			_G["ccCharacterBag"..i.."Slot"]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -13 - i * 28, -34)
			_G["ccCharacterBag"..i.."Slot"]:SetParent(frame) 
			_G["ccCharacterBag"..i.."Slot"]:Show() 
		end

	

	elseif ( BagItemSearchBox.anchorBag == frame ) then
		
		for i=0, 3, 1 do
			_G["ccCharacterBag"..i.."Slot"]:ClearAllPoints()
			_G["ccCharacterBag"..i.."Slot"]:Hide() 
		end

		BagItemSearchBox:ClearAllPoints();
		BagItemSearchBox:Hide();
		BagItemSearchBox.anchorBag = nil;
		BagItemAutoSortButton:ClearAllPoints();
		BagItemAutoSortButton:Hide();
	end


	for i=1, frame.size, 1 do
		itemButton = _G[name.."Item"..i];
		
		texture, itemCount, locked, quality, readable, _, _, isFiltered, noValue = GetContainerItemInfo(id, itemButton:GetID());
		isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, itemButton:GetID());
		
		SetItemButtonTexture(itemButton, texture);
		SetItemButtonCount(itemButton, itemCount);
		SetItemButtonDesaturated(itemButton, locked);
		
		questTexture = _G[name.."Item"..i.."IconQuestTexture"];
		if ( questId and not isActive ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
			questTexture:Show();
		elseif ( questId or isQuestItem ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
			questTexture:Show();		
		else
			questTexture:Hide();
		end
		
		-- Display Hotkey
		
		if id == 0 and itemButton.HotKey == nil then
			itemButton:CreateFontString(itemButton:GetName().."HotKey" , "ARTWORK" , "ccHotKeyTemplate")
		end
		
		if id == 0 and ( texture ~= nil or CCB_SHOWBAGKEYS == true ) then
			local binding = "USEBAG"..itemButton:GetID()
			binding = GetBindingKey(binding)
			itemButton.HotKey:SetText(binding)
			itemButton.HotKey:Show()
		elseif id == 0 and ( texture == nil and CCB_SHOWBAGKEYS == false ) then
			itemButton.HotKey:Hide()
		end
		
		isNewItem = C_NewItems.IsNewItem(id, itemButton:GetID());
		isBattlePayItem = IsBattlePayItem(id, itemButton:GetID());
		battlepayItemTexture = _G[name.."Item"..i].BattlepayItemTexture;
		newItemTexture = _G[name.."Item"..i].NewItemTexture;
		flash = _G[name.."Item"..i].flashAnim;
		newItemAnim = _G[name.."Item"..i].newitemglowAnim;

		if ( isNewItem ) then
			if (isBattlePayItem) then
				newItemTexture:Hide();
				battlepayItemTexture:Show();
			else
				if (quality and NEW_ITEM_ATLAS_BY_QUALITY[quality]) then
					newItemTexture:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[quality]);
				else
					newItemTexture:SetAtlas("bags-glow-white");
				end
				battlepayItemTexture:Hide();
				newItemTexture:Show();
			end
			if (not flash:IsPlaying() and not newItemAnim:IsPlaying()) then
				flash:Play();
				newItemAnim:Play();
			end
		else
			battlepayItemTexture:Hide();
			newItemTexture:Hide();
			if (flash:IsPlaying() or newItemAnim:IsPlaying()) then
				flash:Stop();
				newItemAnim:Stop();
			end
		end
		
		itemButton.JunkIcon:Hide();
		if (quality) then
			if (quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
				itemButton.IconBorder:Show();
				itemButton.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
			else
				itemButton.IconBorder:Hide();
			end

			if (quality == LE_ITEM_QUALITY_POOR and not noValue and MerchantFrame:IsShown()) then
				itemButton.JunkIcon:Show();
			end
		else
			itemButton.IconBorder:Hide();
		end
				
		if ( texture ) then
			ContainerFrame_UpdateCooldown(id, itemButton);
			itemButton.hasItem = 1;
		else
			_G[name.."Item"..i.."Cooldown"]:Hide();
			itemButton.hasItem = nil;
		end
		itemButton.readable = readable;
		
		if ( itemButton == tooltipOwner ) then
			if (GetContainerItemInfo(frame:GetID(), itemButton:GetID())) then
				itemButton.UpdateTooltip(itemButton);
			else
				GameTooltip:Hide();
			end
		end
		
		
		if ( isFiltered ) then
			itemButton.searchOverlay:Show();
		else
			itemButton.searchOverlay:Hide();
		end
	end
end

--bag slot functions

function ccPaperDollItemSlotButton_OnLoad(self)

	local slotName = self:GetName()
	local slotName = strsub(slotName,12)
	local id, textureName, checkRelic = GetInventorySlotInfo(slotName);	
	self:SetID(id);
	local slotName = self:GetName()
	local texture = _G[slotName.."IconTexture"];
	texture:SetTexture(textureName);
	self.backgroundTextureName = textureName;
	self.checkRelic = checkRelic;
	self.UpdateTooltip = PaperDollItemSlotButton_OnEnter;
	local itemSlotButtons = {};
	itemSlotButtons[id] = self;
	self.verticalFlyout = VERTICAL_FLYOUTS[id];
	
	local popoutButton = self.popoutButton;
	if ( popoutButton ) then
		if ( self.verticalFlyout ) then
			popoutButton:SetHeight(16);
			popoutButton:SetWidth(38);
			
			popoutButton:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0.5, 0);
			popoutButton:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 1, 0.5);
			popoutButton:ClearAllPoints();
			popoutButton:SetPoint("TOP", self, "BOTTOM", 0, 4);
		else
			popoutButton:SetHeight(38);
			popoutButton:SetWidth(16);
			
			popoutButton:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0);
			popoutButton:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5);
			popoutButton:ClearAllPoints();
			popoutButton:SetPoint("LEFT", self, "RIGHT", -8, 0);
		end
	end
end

function ccPaperDollItemSlotButton_OnShow (self, isBag)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("MERCHANT_UPDATE");
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("CURSOR_UPDATE");
	self:RegisterEvent("SHOW_COMPARE_TOOLTIP");
	self:RegisterEvent("UPDATE_INVENTORY_ALERTS");
	if ( not isBag ) then
		self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	end
	ccPaperDollItemSlotButton_Update(self);
end

function ccPaperDollItemSlotButton_OnHide (self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("MERCHANT_UPDATE");
	self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("CURSOR_UPDATE");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self:UnregisterEvent("SHOW_COMPARE_TOOLTIP");
	self:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
end

function ccPaperDollItemSlotButton_OnEvent (self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		if ( self:GetID() == arg1 ) then
			ccPaperDollItemSlotButton_Update(self);
		end
	elseif ( event == "ITEM_LOCK_CHANGED" ) then
		if ( not arg2 and arg1 == self:GetID() ) then
			ccPaperDollItemSlotButton_UpdateLock(self);
		end
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		ccPaperDollItemSlotButton_Update(self);
	elseif ( event == "CURSOR_UPDATE" ) then
		if ( CursorCanGoInSlot(self:GetID()) ) then
			self:LockHighlight();
		else
			self:UnlockHighlight();
		end
	elseif ( event == "SHOW_COMPARE_TOOLTIP" ) then
		if ( (arg1 ~= self:GetID()) or (arg2 > NUM_SHOPPING_TOOLTIPS) ) then
			return;
		end

		local tooltip = _G["ShoppingTooltip"..arg2];
		local anchor = "ANCHOR_RIGHT";
		if ( arg2 > 1 ) then
			anchor = "ANCHOR_BOTTOMRIGHT";
		end
		tooltip:SetOwner(self, anchor);
		local hasItem, hasCooldown = tooltip:SetInventoryItem("player", self:GetID());
		if ( not hasItem ) then
			tooltip:Hide();
		end
	elseif ( event == "UPDATE_INVENTORY_ALERTS" ) then
		ccPaperDollItemSlotButton_Update(self);
	elseif ( event == "MODIFIER_STATE_CHANGED" ) then
		if ( IsModifiedClick("SHOWITEMFLYOUT") and self:IsMouseOver() ) then
			ccPaperDollItemSlotButton_OnEnter(self);
		end
	end
end

function ccPaperDollItemSlotButton_Update(self)
	local textureName = GetInventoryItemTexture("player", self:GetID());
	local name = self:GetName()
	local name = strsub(name,3)
	local cooldown = _G[name.."Cooldown"];
	if ( textureName ) then
		SetItemButtonTexture(self, textureName);
		SetItemButtonCount(self, GetInventoryItemCount("player", self:GetID()));
		if ( GetInventoryItemBroken("player", self:GetID()) 
		  or GetInventoryItemEquippedUnusable("player", self:GetID()) ) then
			SetItemButtonTextureVertexColor(self, 0.9, 0, 0);
			SetItemButtonNormalTextureVertexColor(self, 0.9, 0, 0);
		else
			SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
			SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
		end
		if ( cooldown ) then
			local start, duration, enable = GetInventoryItemCooldown("player", self:GetID());
			CooldownFrame_Set(cooldown, start, duration, enable);
		end
		self.hasItem = 1;
	else
		local textureName = self.backgroundTextureName;
		if ( self.checkRelic and UnitHasRelicSlot("player") ) then
			textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
		end
		SetItemButtonTexture(self, textureName);
		SetItemButtonCount(self, 0);
		SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
		SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
		if ( cooldown ) then
			cooldown:Hide();
		end
		self.hasItem = nil;
	end
	
	local quality = GetInventoryItemQuality("player", self:GetID());
	if (quality and quality > LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
		self.IconBorder:Show();
		self.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
	else
		self.IconBorder:Hide();
	end
	
	if (not PaperDollEquipmentManagerPane:IsShown()) then
		self.ignored = nil;
	end
	
	if ( self.ignored and self.ignoreTexture ) then
		self.ignoreTexture:Show();
	elseif ( self.ignoreTexture ) then
		self.ignoreTexture:Hide();
	end

	ccPaperDollItemSlotButton_UpdateLock(self);

	-- Update repair all button status
	MerchantFrame_UpdateGuildBankRepair();
	MerchantFrame_UpdateCanRepairAll();
end

function ccPaperDollItemSlotButton_UpdateLock (self)
	if ( IsInventoryItemLocked(self:GetID()) ) then
		--this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		SetItemButtonDesaturated(self, true);
	else 
		--this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
		SetItemButtonDesaturated(self, false);
	end
end









function ccBagSlotButton_UpdateChecked(self)
	local translatedID = self:GetID() - ccCharacterBag0Slot:GetID() + 1;
	local isVisible = false;
	local frame;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		frame = _G["ContainerFrame"..i];
		if ( (frame:GetID() == translatedID) and frame:IsShown() ) then
			isVisible = true;
			break;
		end
	end
	self:SetChecked(isVisible);
end

function ccBagSlotButton_OnClick(self)
	local id = self:GetID();
	local translatedID = id - ccCharacterBag0Slot:GetID() + 1;
	local hadItem = PutItemInBag(id);
	if ( not hadItem ) then
		ToggleBag(translatedID);
	end
	ccBagSlotButton_UpdateChecked(self);
end

function ccBagSlotButton_OnModifiedClick(self)
	if ( IsModifiedClick("OPENALLBAGS") ) then
		--[[Set Bag As permanent if it's currently blue
		if ( GetInventoryItemTexture("player", self:GetID()) ) then
			ToggleAllBags();
		end]]
	end
	ccBagSlotButton_UpdateChecked(self);
end

function ccBagSlotButton_OnDrag(self)
	PickupBagFromSlot(self:GetID());
	ccBagSlotButton_UpdateChecked(self);
end


function ccItemAnim_OnLoad(self)
	self:RegisterEvent("ITEM_PUSH");
end

function ccItemAnim_OnEvent(self, event, ...)
	if ( event == "ITEM_PUSH" ) then
		local arg1, arg2 = ...;
		local id = self:GetID();
		if ( id == arg1 ) then
			self.animIcon:SetTexture(arg2);
			self.flyin:Play(true);
		end
	end
end

function ccBagSlotButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if ( GameTooltip:SetInventoryItem("player", self:GetID()) ) then
		local bagID = (self:GetID() - ccCharacterBag0Slot:GetID()) + 1;
		if (not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(bagID))) then
			for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
				if ( GetBagSlotFlag(bagID, i) ) then
					GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[i]));
					break;
				end
			end
		end
		GameTooltip:Show();
	else
		GameTooltip:SetText(EQUIP_CONTAINER, 1.0, 1.0, 1.0);
	end
end

function ccItemAnim_OnAnimFinished(self)
	self:Hide();
end






-- Filter Functions


function ccContainerFrameFilterDropDown_OnLoad()

	for i = 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS + 1 do
		UIDropDownMenu_Initialize(_G["ContainerFrame"..i.."FilterDropDown"], ccContainerFrameFilterDropDown_Initialize, "MENU");
	end
end


function ccContainerFrameFilterDropDown_Initialize(self, level)
	local frame = self:GetParent();
	local id = frame:GetID();
	
	if (id > NUM_BAG_SLOTS + NUM_BANKBAGSLOTS) then
		return;
	end

	local info = UIDropDownMenu_CreateInfo();	

	if (id > 0 and not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(id))) then -- The actual bank has ID -1, backpack has ID 0, we want to make sure we're looking at a regular or bank bag
		info.text = BAG_FILTER_ASSIGN_TO;
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);

		info.isTitle = nil;
		info.notCheckable = nil;
		info.tooltipWhileDisabled = 1;
		info.tooltipOnButton = 1;

		for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
			if ( i ~= LE_BAG_FILTER_FLAG_JUNK ) then
				info.text = BAG_FILTER_LABELS[i];
				info.func = function(_, _, _, value)
					value = not value;
					if (id > NUM_BAG_SLOTS) then
						SetBankBagSlotFlag(id - NUM_BAG_SLOTS, i, value);
					else
						SetBagSlotFlag(id, i, value);
					end
					if (value) then
						frame.localFlag = i;
						frame.FilterIcon.Icon:SetAtlas(BAG_FILTER_ICONS[i]);
						frame.FilterIcon:Show();
					else
						frame.FilterIcon:Hide();
						frame.localFlag = -1;						
					end
				end;
				if (frame.localFlag) then
					info.checked = frame.localFlag == i;
				else
					if (id > NUM_BAG_SLOTS) then
						info.checked = GetBankBagSlotFlag(id - NUM_BAG_SLOTS, i);
					else
						info.checked = GetBagSlotFlag(id, i);
					end
				end
				info.disabled = nil;
				info.tooltipTitle = nil;
				UIDropDownMenu_AddButton(info);
			end
		end
	end

	info.text = BAG_FILTER_CLEANUP;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.isTitle = nil;
	info.notCheckable = nil;
	info.isNotRadio = true;
	info.disabled = nil;

	info.text = BAG_FILTER_IGNORE;
	info.func = function(_, _, _, value)
		if (id == -1) then
			SetBankAutosortDisabled(not value);
		elseif (id == 0) then
			SetBackpackAutosortDisabled(not value);
		elseif (id > NUM_BAG_SLOTS) then
			SetBankBagSlotFlag(id - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not value);
		else
			SetBagSlotFlag(id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not value);
		end
	end;
	if (id == -1) then
		info.checked = GetBankAutosortDisabled();
	elseif (id == 0) then
		info.checked = GetBackpackAutosortDisabled();
	elseif (id > NUM_BAG_SLOTS) then
		info.checked = GetBankBagSlotFlag(id - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP);
	else
		info.checked = GetBagSlotFlag(id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP);
	end
	UIDropDownMenu_AddButton(info);

	--start
	info.checked = nil;
	info.isTitle = nil;
	info.notCheckable = 1;
	info.isNotRadio = true;
	info.disabled = nil;

	info.text = "Sort Now";
	info.func = ccSortBagsOnClick
	UIDropDownMenu_AddButton(info);
	--stop
end

function ccSortBagsOnClick()
SortBags()
end
