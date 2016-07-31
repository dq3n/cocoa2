-- Initialize Saving

if not CCB_CHAR_SAVE then
	CCB_CHAR_SAVE = {}
end

if not CCB_ACCOUNT_SAVE then 
	CCB_ACCOUNT_SAVE = {}
end


-- API Functions

function C_GetCursorIndex(kind)

	local type, data, subType, subData = GetCursorInfo()
	
	if type == nil then 
		return nil
	end
	
	if kind == "Pet" and type == "battlepet" then
		return data
	elseif kind == "Mount" and type == "mount" and subType == 0 then
		return false
	elseif kind == "Mount" and type == "mount" then
		return data
	elseif kind == "Toy" and type == "item" and PlayerHasToy(data) then
		return data
	elseif kind == "Bag" and type == "item" then
		return data
	else
		return false
	end
	
end
	
	
function C_PickupItem(kind, index)

	if kind == "Pet" then
		C_PetJournal.PickupPet(index)
	elseif kind == "Mount" then
		
		local orig_collected = C_MountJournal.GetCollectedFilterSetting(1)
		local orig_not_collected = C_MountJournal.GetCollectedFilterSetting(2)
		
		C_MountJournal.SetCollectedFilterSetting(1,true)
		C_MountJournal.SetCollectedFilterSetting(2,false)

		for i = 1, C_MountJournal.GetNumDisplayedMounts() do
			
			local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetDisplayedMountInfo(i)
			if mountID == index then 
				C_MountJournal.Pickup(i)
			end
		end
		
		C_MountJournal.SetCollectedFilterSetting(1,orig_collected)
		C_MountJournal.SetCollectedFilterSetting(2,orig_not_collected)

	elseif kind == "Toy" then
		C_ToyBox.PickupToyBoxItem(index)
	end
	
end


function C_UseItemByIndex(kind, index, securebutton)
	
	if index == nil then
		return 
	end

	if kind == "Pet" then
		C_PetJournal.SummonPetByGUID(index)
	elseif kind == "Mount" then
		C_MountJournal.SummonByID(index)
	elseif kind == "Toy" then
		itemID, toyName, toyIcon = C_ToyBox.GetToyInfo(index); 
		securebutton:SetAttribute("toy", itemID)
	elseif kind == "Bag" then
		UseContainerItem(0, index)
	end

end

function C_GetIsUsableByIndex(kind, index)

	if index == nil then
		return nil
	end

	if kind == "Pet" and C_PetJournal.PetIsSummonable(index) then
		return true
	elseif kind == "Mount" then
		local creatureName, spellID, icon, active, isUsable = C_MountJournal.GetMountInfoByID(index);
		if isUsable == true then
			return true
		end
	elseif kind == "Toy" then
		itemID, toyName, toyIcon = C_ToyBox.GetToyInfo(index); 
		local isUsable = IsUsableItem(itemID);
		if isUsable == true then
			return true
		end
	elseif kind == "Bag" then
		local texture, count, locked, quality, readable, lootable, link, isFiltered, hasNoValue, itemID = GetContainerItemInfo(0, index)
		local isUsable = IsUsableItem(itemID);
		if isUsable == true then
			return true
		end
	else
		return false
	end

end


function C_GetItemIconByIndex(kind, index)

	if index == nil then
		return nil
	end

	if kind == "Pet" then
		local speciesID, customName, level, xp, maxXp, displayID, isFavorite, petName, petIcon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = C_PetJournal.GetPetInfoByPetID(index)
		return petIcon
	elseif kind == "Mount" then
		local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(index);
		return icon
	elseif kind == "Toy" then
		local itemID, toyName, toyIcon = C_ToyBox.GetToyInfo(index)
		return toyIcon
	elseif kind == "Bag" then
		local texture, count, locked, quality, readable, lootable, link, isFiltered, hasNoValue, itemID = GetContainerItemInfo(0, index)
		return texture
	else
		return nil
	end

end


function C_GetItemQualityByIndex(kind, index)

	if index == nil then
		return nil
	end

	if kind == "Pet" then
		local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(index)
		if rarity then
			rarity = rarity - 1
		end
		return rarity
	elseif kind == "Mount" then
		return nil
	elseif kind == "Toy" then
		local itemID, toyName, toyIcon = C_ToyBox.GetToyInfo(index)
		name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemID)
		return quality
	elseif kind == "Bag" then
		local texture, count, locked, quality, readable, lootable, link, isFiltered, hasNoValue, itemID = GetContainerItemInfo(0, index)
		return quality
	else
		return nil
	end

end


function C_GetChatLinkByIndex(kind, index)

	if kind == "Pet" then
		local link = C_PetJournal.GetBattlePetLink(index);
		return link
	elseif kind == "Mount" then
		local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(index);
		local link = GetSpellLink(spellID)
 		return link
 	elseif kind == "Toy" then
 		local link = C_ToyBox.GetToyLink(index);
		return link
 	end

end


function C_GetChatNameByIndex(kind, index)

	if kind == "Pet" then
		local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, petIcon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = C_PetJournal.GetPetInfoByPetID(ID);
		return name
	elseif kind == "Mount" then
		local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(index);
		local name = GetSpellInfo(spellID)
 		return name
 	elseif kind == "Toy" then
		local itemID, toyName, toyIcon = C_ToyBox.GetToyInfo(index);
		local name = GetItemInfo(itemID);
		return name
 	end

end


function C_GetCooldownByIndex(kind, index)

	if index == nil then
		return nil
	end
	
	if kind == "Pet" then
		startTime, duration, enable = C_PetJournal.GetPetCooldownByGUID(index)
		return startTime, duration, enable
	elseif kind == "Mount" then
		local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(index);
		local startTime, duration, enable = GetSpellCooldown(spellID)
		return startTime, duration, enable
	elseif kind == "Toy" then
		local startTime, duration, enable = GetItemCooldown(index);
		return startTime, duration, enable
	elseif kind == "Bag" then
		local texture, count, locked, quality, readable, lootable, link, isFiltered, hasNoValue, itemID = GetContainerItemInfo(0, index)
		if itemID == nil then
			return nil
		end
		local startTime, duration, enable = GetItemCooldown(itemID)
		return startTime, duration, enable
	else
		return nil
	end

end


function C_CheckActiveByIndex(kind, index)

	if index == nil then
		return nil
	end
		
	if kind == "Pet" then
		local summonedPetID = C_PetJournal.GetSummonedPetGUID();
		if (summonedPetID ~= nil and index == summonedPetID) then		
			return true
		end
	elseif kind == "Mount" then
		local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(index)
		if active then
			return true
		end
	elseif kind == "Toy" then
		return false
	else
		return false
	end
	
	return false

end

-- Click Function

function CollectionsContainerButton_PreClick(self, button, down)

	local parent = self:GetParent()
	local kind = parent.tag
	local name = self:GetName()
	local olditem = CCB_CHAR_SAVE[name];
	local newitem = C_GetCursorIndex(kind)


	if button == "LeftButton" then
	
		if InCombatLockdown() and ( kind == "Toy" ) then
			UIErrorsFrame:AddMessage("Cannot access this container while you are in combat.", 1.0, 0.1, 0.1, 1.0);
		return false
		end

	
		if newitem == false then
		
			local error = "That slot is reserved for "..kind:lower().."s in your collection"
			UIErrorsFrame:AddMessage(error, 1.0, 0.1, 0.1, 1.0);
			return false
	
		elseif ( newitem == nil and olditem == nil ) then

			return false

		elseif ( newitem == nil and olditem ) then

			if ( IsModifiedClick("CHATLINK") and down == false) then
				if ( MacroFrame and MacroFrame:IsShown() ) then
					local name = C_GetChatNameByIndex(kind, olditem);
					ChatEdit_InsertLink(name);
				else
					local link = C_GetChatLinkByIndex(kind, olditem)
					ChatEdit_InsertLink(link);
				end
			else
				C_PickupItem(kind, olditem)
				CCB_TEMPORARY_PICKUP = self
				CCB_TEMPORARY_PICKUP.icon:SetDesaturated(1);
			end

		elseif ( newitem and olditem == nil ) then

			ClearCursor();
			CCB_CHAR_SAVE[name] = newitem
			self:SetScript("OnUpdate",CollectionsContainerButton_DelayAnimation)

				if CCB_TEMPORARY_PICKUP ~= nil then
					local tempname = CCB_TEMPORARY_PICKUP:GetName()
					CCB_TEMPORARY_PICKUP:SetScript("OnUpdate",CollectionsContainerButton_DelayAnimation)
					CCB_CHAR_SAVE[tempname] = nil
					if CCB_TEMPORARY_PICKUP:GetParent() ~= self:GetParent() then
						CollectionsContainerFrame_Update(CCB_TEMPORARY_PICKUP:GetParent())
					end
					
					CCB_TEMPORARY_PICKUP = nil
					
				end
		
		elseif ( newitem and olditem ) then

			CCB_CHAR_SAVE[name] = newitem
			self:SetScript("OnUpdate",CollectionsContainerButton_DelayAnimation);


			if ( CCB_TEMPORARY_PICKUP ~= nil ) then

				local tempname = CCB_TEMPORARY_PICKUP:GetName()				
				CCB_CHAR_SAVE[tempname] = olditem
				CCB_TEMPORARY_PICKUP:SetScript("OnUpdate",CollectionsContainerButton_DelayAnimation)
					
					if CCB_TEMPORARY_PICKUP:GetParent() ~= self:GetParent() then					
						CollectionsContainerButton_RemoveDuplicates(CCB_TEMPORARY_PICKUP)
						CollectionsContainerFrame_Update(CCB_TEMPORARY_PICKUP:GetParent())
					end
					
				CCB_TEMPORARY_PICKUP = nil
				ClearCursor();
			else 
				ClearCursor();
				C_PickupItem(kind, olditem)
			end


		end
		CollectionsContainerButton_RemoveDuplicates(self)
		--CollectionsContainerFrame_Update(self:GetParent())
	
	elseif button == "RightButton" then
		C_UseItemByIndex(kind, olditem, self)
	end
end




-- Update Functions

function CollectionsContainerButton_RemoveDuplicates(self)

	local frame = self:GetParent()
	local kind = frame.tag
	local framename = frame:GetName()
	local size = frame.size
	local name = self:GetName()
	local index = CCB_CHAR_SAVE[name]

	for i=1, size do
		local slot = _G[framename.."Item"..i];
		local slotname = slot:GetName()
		if self:GetName() ~= slot:GetName() and CCB_CHAR_SAVE[slotname] == index then
			slot.state = 0
			slot.timer = 0
			slot:SetScript("OnUpdate", CollectionsContainerButton_DuplicateAnimation)
		end		
	end

end

function CollectionsContainerButton_DuplicateAnimation(self,elapsed)

	self.timer = self.timer + elapsed
	
	if self.timer >= 0.27 and self.state == 0 then
		self.state = 1
		self.check:Hide()
		self.icon:SetDesaturated(1)
	elseif self.timer >= 0.54 and self.state == 1 then
		self:SetScript("OnUpdate", nil)
		self.state = 0
		self.timer = 0
		local slotname = self:GetName()
		CCB_CHAR_SAVE[slotname] = nil;
		CollectionsContainerButton_Update(self)	
	end

end


function CollectionsContainerButton_DelayAnimation(self,elapsed)

	if self.timer == nil then 
		self.timer = 0
	end
	
	if self.state == nil then
		self.state = 0
	end	

	if self.latency == nil then
		bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats();
		local delay = latencyHome/1000
		
		if delay < 0.15 then 
			delay = 0.15
		end
		
		if delay > 0.8 then 
			delay = 0.8
		end
		
		delay = delay + 0.05
		
		self.latency = delay
	end

	self.timer = self.timer + elapsed
	
	if self.timer >= 0.20 and self.state == 0 then
		self.state = 1
		self:Disable()
		self.icon:SetDesaturated(1)
	elseif self.timer >= self.latency and self.state == 1 then
		self:SetScript("OnUpdate", nil)
		self.state = 0
		self.timer = 0
		self.latency = nil
		self:Enable()
		self.icon:SetDesaturated(nil)
		CollectionsContainerButton_Update(self)	
	end

end







function CollectionsContainerButton_Update(self)

	local kind = self:GetParent().tag
	local name = self:GetName()
	local secure = self:GetParent().secure
	
	if secure and InCombatLockdown()then
		return false
	end
	
	if kind == "Pet" then
		ContainerMicroButton_OnShow(PetContainerFrameTreatButton)
	end
	
	if kind == "Toy" then
		ContainerMicroButton_OnShow(ToyContainerFrameDiceButton)
		ContainerMicroButton_OnShow(ToyContainerFrameCardButton)
		ContainerMicroButton_OnShow(ToyContainerFrameBoardButton)
	end 
		
	if CCB_CHAR_SAVE[name] then
		local index = CCB_CHAR_SAVE[name]
		local icon = self.icon;
		
		local icontexture = C_GetItemIconByIndex(kind, index)
		local startTime, duration, enable = C_GetCooldownByIndex(kind, index)
		local isUsable = C_GetIsUsableByIndex(kind, index)
		local active = C_CheckActiveByIndex(kind, index)
		
		icon:SetTexture(icontexture)

		if (startTime) then
			CooldownFrame_Set(self.Cooldown, startTime, duration, enable);
		else
			self.Cooldown:Hide()
		end

		if ( not isUsable and not self.Cooldown:IsShown() and kind ~= "Toy" ) then
			icon:SetVertexColor(0.4, 0.4, 0.4);
		else
			icon:SetVertexColor(1.0, 1.0, 1.0);
		end

		if active == true then
			self.check:Show()
		else
			self.check:Hide()
		end
		
	else
		if not self.locked then
			self.icon:SetTexture(nil)
		end
		self.check:Hide()
		self.Cooldown:Hide()
		if kind == "Toy" then
			self:SetAttribute("toy",nil)
		end
	end 
	
	CollectionsContainerButton_BindingUpdate(self)

end


function CollectionsContainerButton_BindingUpdate(self)

	local kind = self:GetParent().tag
	local name = self:GetName()

	if CCB_CHAR_SAVE[name] then
		local binding = "USE"..kind:upper()..self.slot
		binding = GetBindingKey(binding)
		self.HotKey:SetText(binding)
		self.HotKey:Show()
	else
		if self.showkey ~= true then
			self.HotKey:Hide()
		end
	end

end

function CollectionsContainerFrame_Update(self)
	
	for i = 1, self.size do
		local button = _G[self:GetName().."Item"..i]
		CollectionsContainerButton_Update(button)
	end
		
end




-- Micro Button Functions 

function ContainerMicroButton_ToggleCheck(self)

	if self.check:IsShown() then
		self:SetScript("OnUpdate", ContainerMicroButton_SlotUnCheck)
	else
		self:SetScript("OnUpdate", ContainerMicroButton_SlotCheck)
	end
	
end


function ContainerMicroButton_SlotCheck(self, elapsed)

	self.timer = self.timer + elapsed

	if self.timer >= 0.27 and self.state == 0 then
		self.state = 1
		
		self.check:Show()
		self.check:SetDesaturated(1)
		self.check:SetAlpha(1) 

	elseif self.timer >= 0.54 and self.state == 1 then
		self.state = 0
		self:SetScript("OnUpdate", nil)
		self.timer = 0
		
		self.check:SetDesaturated(nil)
		self.check:SetAlpha(1) 
	end

end

function ContainerMicroButton_SlotUnCheck(self, elapsed)

	self.timer = self.timer + elapsed

	if self.timer >= 0.14 and self.state == 0 then
		self.state = 1
	
		self.check:SetAlpha(0.5) 
	
	elseif self.timer >= 0.28 and self.state == 1 then
		self:SetScript("OnUpdate", nil)
		self.state = 0
		self.timer = 0

		self.check:Hide()
		self.check:SetAlpha(1) 

	end

end

function ContainerMicroButton_OnEvent(self, event, ...)

	if event == "SPELL_UPDATE_COOLDOWN" and self.spellID then
		ContainerMicroButton_OnShow(self)
	end
	
	if event == "PLAYER_REGEN_DISABLED" or "PLAYER_REGEN_ENABLED" then
		ContainerMicroButton_OnShow(self)
	end
	
	if event == "TOYS_UPDATED" or "COMPANION_UPDATE" then
		_G[self:GetName().."_UpdateDisabled"](self)
	end
	
end

function ContainerMicroButton_OnShow(self)

	_G[self:GetName().."_UpdateDisabled"](self)
	
	if self:GetName() == "PetContainerFrameTreatButton" and CCB_CHAR_SAVE["TreatTimer"] then
		local startTime = CCB_CHAR_SAVE["TreatTimer"] 
		if GetTime() - startTime > CCB_TREAT_CD then
			CCB_CHAR_SAVE["TreatTimer"] = nil
		else
			CooldownFrame_Set(PetContainerFrameTreatButton.Cooldown,startTime,CCB_TREAT_CD,1)
		end
	end

	if self:GetAttribute("Spell") ~= nil then
		local spellID = self:GetAttribute("Spell")
		local startTime, duration, enable = GetSpellCooldown(spellID)
		CooldownFrame_Set(self.Cooldown, startTime, duration, enable)
	end

	if self.disabled == true then
		self.icon:SetDesaturated(true)
		return
	end

	if InCombatLockdown() and self.secure == true then
		self.icon:SetDesaturated(true)
	else
		self.icon:SetDesaturated(nil)
	end

end





	