MainMenuBarBackpackButton:Disable()
SetDesaturation(MainMenuBarBackpackButtonIconTexture, true);
CharacterBag0Slot:Disable();
SetDesaturation(CharacterBag0SlotIconTexture, true);
CharacterBag1Slot:Disable();
SetDesaturation(CharacterBag1SlotIconTexture, true);
CharacterBag2Slot:Disable();
SetDesaturation(CharacterBag2SlotIconTexture, true);
CharacterBag3Slot:Disable();
SetDesaturation(CharacterBag3SlotIconTexture, true);



Disable_BagButtons = function()
	BagContainerSlotButton:Disable();
	SetDesaturation(BagContainerSlotButtonIconTexture, true);
	SetDesaturation(BagContainerSlotButtonBadge.Texture, true);

	MountContainerSlotButton:Disable();
	SetDesaturation(MountContainerSlotButtonIconTexture, true);
	SetDesaturation(MountContainerSlotButtonBadge.Texture, true);

	PetContainerSlotButton:Disable();
	SetDesaturation(PetContainerSlotButtonIconTexture, true);
	SetDesaturation(PetContainerSlotButtonBadge.Texture, true);

	SetContainerSlotButton:Disable();
	--SetDesaturation(SetContainerSlotButtonIconTexture, true);
	--SetDesaturation(SetContainerSlotButtonBadge.Texture, true);

	ToyContainerSlotButton:Disable();
	SetDesaturation(ToyContainerSlotButtonIconTexture, true);
	SetDesaturation(ToyContainerSlotButtonBadge.Texture, true);
end

Enable_BagButtons = function()
	BagContainerSlotButton:Enable();
	SetDesaturation(BagContainerSlotButtonIconTexture, false);
	SetDesaturation(BagContainerSlotButtonBadge.Texture, false);
	MountContainerSlotButton:Enable();
	SetDesaturation(MountContainerSlotButtonIconTexture, false);
	SetDesaturation(MountContainerSlotButtonBadge.Texture, false);
	PetContainerSlotButton:Enable();
	SetDesaturation(PetContainerSlotButtonIconTexture, false);
	SetDesaturation(PetContainerSlotButtonBadge.Texture, false);
	SetContainerSlotButton:Enable();
	--SetDesaturation(SetContainerSlotButtonIconTexture, false);
	--SetDesaturation(SetContainerSlotButtonBadge.Texture, false);
	ToyContainerSlotButton:Enable();
	SetDesaturation(ToyContainerSlotButtonIconTexture, false);
	SetDesaturation(ToyContainerSlotButtonBadge.Texture, false);
end


ToggleBackpack = function(...)

	if ( not UIParent:IsShown() ) then
		return;
	end
	
	if ( IsOptionFrameOpen() ) then
		return;
	end

	local bagsOpen = 0;
	local totalBags = 1;
	if ( IsBagOpen(0) ) then
		bagsOpen = bagsOpen +1;
		CloseBackpack()
	end

	for i=1, NUM_BAG_FRAMES, 1 do
		if ( GetContainerNumSlots(i) > 0 ) then		
			totalBags = totalBags +1;
		end
		if ( IsBagOpen(i) ) then
			CloseBag(i);
			bagsOpen = bagsOpen +1;
		end
	end
	if (bagsOpen < totalBags) then
		ContainerFrame1.allBags = true;
		OpenBag(0);
		for i=1, NUM_BAG_FRAMES, 1 do
			OpenBag(i);
		end
		ContainerFrame1.allBags = false;
		CheckBagSettingsTutorial();
	elseif( BankFrame:IsShown() ) then
		bagsOpen = 0;
		totalBags = 0;
		for i=NUM_BAG_FRAMES+1, NUM_CONTAINER_FRAMES, 1 do
			if ( GetContainerNumSlots(i) > 0 ) then		
				totalBags = totalBags +1;
			end
			if ( IsBagOpen(i) ) then
				CloseBag(i);
				bagsOpen = bagsOpen +1;
			end
		end
		if (bagsOpen < totalBags) then
			ContainerFrame1.allBags = true;
			OpenBag(0);
			for i=1, NUM_CONTAINER_FRAMES, 1 do
				OpenBag(i);
			end
			ContainerFrame1.allBags = false;
			CheckBagSettingsTutorial();
		end
	end
end


function BackpackSlotButton_OnClick(self, button)

	if not IsBagOpen(0) and not(InCombatLockdown()) then
		PetContainerFrame:Hide()
		MountContainerFrame:Hide()
		ToyContainerFrame:Hide()
		SetContainerFrame:Hide()
	end

	if ( IsModifiedClick("OPENALLBAGS") ) then		
		if ( not CharacterFrame:IsShown() and not IsBagOpen(0) ) then
			ToggleCharacter("PaperDollFrame");
			ToggleBackpack()
		elseif ( CharacterFrame:IsShown() and PaperDollFrame:IsShown() and IsBagOpen(0) ) then
			HideUIPanel(CharacterFrame);	
			ToggleBackpack()
		elseif IsBagOpen(0) then
			ToggleCharacter("PaperDollFrame");
		elseif CharacterFrame:IsShown() then
			ToggleBackpack()
		end
	else
		ToggleBackpack()
		if ( CharacterFrame:IsShown() and PaperDollFrame:IsShown() and not IsBagOpen(0) ) then
			HideUIPanel(CharacterFrame);	
		end
	end
	
end


MainMenuBarBackpackButton:SetScript("OnClick", BackpackSlotButton_OnClick)


function CollectionsContainerSlotButton_UpdateBindings(self)
	
	local binding = GetBindingKey(self.binding);
	local name = self:GetName();
	
	if binding and name then
	SetOverrideBindingClick(self, true, binding, name, "RightButton");
	end
	
	
end



--[[ToggleAllBags = function()

	if ( not UIParent:IsShown() ) then
		return;
	end

	local bagsOpen = 0;
	local totalBags = 1;
	if ( IsBagOpen(0) ) then
		bagsOpen = bagsOpen +1;
		CloseBackpack()
	end
	
	totalBags = totalBags +1
	if ( MountContainerFrame:IsShown() ) then
		bagsOpen = bagsOpen +1;
		MountContainerFrame:Hide()
	end
	
	totalBags = totalBags +1
	if ( PetContainerFrame:IsShown() ) then
		bagsOpen = bagsOpen +1;
		PetContainerFrame:Hide()
	end
	totalBags = totalBags +1
	if ( SetContainerFrame:IsShown() ) then
		bagsOpen = bagsOpen +1;
		SetContainerFrame:Hide()
	end

	totalBags = totalBags +1
	if ( ToyContainerFrame:IsShown() ) then
		bagsOpen = bagsOpen +1;
		ToyContainerFrame:Hide()
	end

	for i=1, NUM_BAG_FRAMES, 1 do
		if ( GetContainerNumSlots(i) > 0 ) then		
			totalBags = totalBags +1;
		end
		if ( IsBagOpen(i) ) then
			CloseBag(i);
			bagsOpen = bagsOpen +1;
		end
	end
	if (bagsOpen < totalBags) then
		ContainerFrame1.allBags = true;
		OpenBackpack();
		MountContainerFrame:Show()
		PetContainerFrame:Show()
		SetContainerFrame:Show()
		ToyContainerFrame:Show()
		
		for i=1, NUM_BAG_FRAMES, 1 do
			OpenBag(i);
		end
		ContainerFrame1.allBags = false;
		CheckBagSettingsTutorial();
	elseif( BankFrame:IsShown() ) then
		bagsOpen = 0;
		totalBags = 0;
		for i=NUM_BAG_FRAMES+1, NUM_CONTAINER_FRAMES, 1 do
			if ( GetContainerNumSlots(i) > 0 ) then		
				totalBags = totalBags +1;
			end
			if ( IsBagOpen(i) ) then
				CloseBag(i);
				bagsOpen = bagsOpen +1;
			end
		end
		if (bagsOpen < totalBags) then
			ContainerFrame1.allBags = true;
			OpenBackpack();
			for i=1, NUM_CONTAINER_FRAMES, 1 do
				OpenBag(i);
			end
			ContainerFrame1.allBags = false;
			CheckBagSettingsTutorial();
		end
	end
	
	CollectionsContainerSlotCheckState(MountContainerFrame)
	CollectionsContainerSlotCheckState(PetContainerFrame)
	CollectionsContainerSlotCheckState(SetContainerFrame)
	CollectionsContainerSlotCheckState(ToyContainerFrame)
end
]]




function CollectionsContainerFrameToggle(self)

	if ( not CollectionsJournal ) then
		CollectionsJournal_LoadUI();
	end
	
	local index = 0
	
	if self.tag == "Mount" then 
		index = 1
	elseif self.tag == "Pet" then 
		index = 2
	elseif self.tag == "Toy" then
		index = 3
	elseif self.tag == "Set" then
		index = nil
	end
		
	local frame = _G[self.tag.."ContainerFrame"]
	if frame:IsShown() then
		if ( CollectionsJournal:IsShown() and PanelTemplates_GetSelectedTab(CollectionsJournal) == index) then
			HideUIPanel(CollectionsJournal);
		end
	frame:Hide()
	else
	frame:Show()
	end
	
end


function CollectionsContainerSlotCheckState(self)
	local tag = self.tag
	local frame
	
	if tag == "Bag" then
		frame = ContainerFrame1
	else
		frame = _G[tag.."ContainerFrame"]
	end
	
	local slot = _G[tag.."ContainerSlotButton"]
	if frame:IsShown() then
		slot.check:Show()
	else
		slot.check:Hide()
	end
end


function CollectionsContainerFrameModifiedToggle(self, index)

	local frame = _G[self.tag.."ContainerFrame"]
	
	local index = 0
	
	if self.tag == "Mount" then 
		index = 1
	elseif self.tag == "Pet" then 
		index = 2
	elseif self.tag == "Set" then
		index = 4
	elseif self.tag == "Toy" then
		index = 3
	end

	if ( IsModifiedClick("OPENALLBAGS") ) then
	
		if ( not CollectionsJournal ) then
			CollectionsJournal_LoadUI();
		end		
		
		if ( CollectionsJournal:IsShown() and PanelTemplates_GetSelectedTab(CollectionsJournal) == index and frame:IsShown() ) then
			HideUIPanel(CollectionsJournal);
			frame:Hide()
		else
			ShowUIPanel(CollectionsJournal);
			CollectionsJournal_SetTab(CollectionsJournal, index);
			frame:Show()
		end
						
	end
	CollectionsContainerSlotCheckState(frame)
end



function BagContainerSlotButton_UpdateFreeSlots()
	
	local self = BagContainerSlotButton
	local numofSlots, totalSlots, totalFree, freeSlots, bagFamily = 0;
	totalFree = 0
	totalSlots = 0
	
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		freeSlots, bagFamily = GetContainerNumFreeSlots(i);
		if ( bagFamily == 0 ) then
			numofSlots = GetContainerNumSlots(i);
			totalSlots = totalSlots + numofSlots;
			totalFree = totalFree + freeSlots;
		end
	end

	local threshold = math.floor(totalSlots * 0.15)
	if threshold < 3 then
		threshold = 3
	elseif threshold > 9 then
		threshold = 9
	end
		
	if ( totalFree < threshold) then
		self.Badge.String:SetText(totalFree)
		ContainerSlotButtonBadge_AnimationController(self.Badge,1)
	else
		ContainerSlotButtonBadge_AnimationController(self.Badge,0)
	end

	
end



function ContainerSlotButtonBadge_AnimationController(self,state)

	if state == 1 then
		if not self:IsShown() then
			self.Enter:Play()
		end
	elseif state == 0 then
		if self:IsShown() then
			self.Exit:Play()
		end
	end

end


