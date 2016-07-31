function CloseCollectionContainers()

		MountContainerFrame:Hide()
		
	if not InCombatLockdown() then
		PetContainerFrame:Hide()
		ToyContainerFrame:Hide()
	end

end

hooksecurefunc("CloseAllWindows", CloseCollectionContainers)



function CollectionsContainerFrame_SecureHide(self, ischild)

	if InCombatLockdown() and self:GetParent().secure == true then
		UIErrorsFrame:AddMessage("Cannot access this container in combat", 1.0, 0.1, 0.1, 1.0);
	else
		if ischild ~= nil then
			self = self:GetParent()
		end
		self:Hide()
	end

end


function CollectionsContainerFrame_OnHide(self)
	
	self:UnregisterEvent("BAG_OPEN");
	self:UnregisterEvent("BAG_CLOSED");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("CURSOR_UPDATE");	
	self:UnregisterEvent("PLAYER_REGEN_DISABLED");
	self:UnregisterEvent("PLAYER_REGEN_ENABLED");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	
	if self.tag == "Mount" then
		self:UnregisterEvent("SPELLS_CHANGED");
	elseif self.tag == "Pet" then
		self:UnregisterEvent("PET_JOURNAL_LIST_UPDATE");
		self:UnregisterEvent("PET_JOURNAL_PET_DELETED");
	end
	
	CollectionsContainerSlotCheckState(self)
	
	self.DelayedQuickCast = nil

	if not InCombatLockdown() then
		CollectionsContainerFrame_RemoveQuickCast(self)
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self.DelayedQuickCast = true
	end

	if self.tag ~= "Mount" then
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
	end

end


function CollectionsContainerFrame_OnShow(self)

	if not self.loaded then

		local kind = self.tag
		local name = self.tag.."s"
		local x, y = self:GetSize()
		_G[self:GetName().."Name"]:SetSize(x,12)
		_G[self:GetName().."Name"]:SetText(name)
		self.ClickableTitleFrame:SetSize(x-30,16)
	
		local texturepath = "Interface\\AddOns\\ccBags\\Textures\\"..kind.."_Container_Icon"
		self.Portrait:SetTexture(texturepath)
		self.Portrait:SetTexCoord(0, 0.875, 0, 0.875)
		texturepath = "Interface\\AddOns\\ccBags\\Textures\\"..kind.."_Container_Frame"
		self.Background:SetTexture(texturepath)
		
		self.loaded = true
	end

	self:RegisterEvent("BAG_OPEN");
	self:RegisterEvent("BAG_CLOSED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("CURSOR_UPDATE");	
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");


	if self.tag == "Mount" then
		self:RegisterEvent("SPELLS_CHANGED");
		MountContainerFrame_UnlockCheck(self)
	elseif self.tag == "Pet" then
		self:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
		self:RegisterEvent("PET_JOURNAL_PET_DELETED");
	end
 	
 	for i = 1, NUM_CCB_SETTINGS do
 		local active = GetCollectionsBagSlotFlag(self, i);
		if active then
			self.SettingsIcon.Icon:SetTexture(CCB_SETTINGS_ICONS[i]);
			self.SettingsIcon:Show();
		end
	end
	
	local slotbutton = _G[self.tag.."ContainerSlotButton"]

	if slotbutton.QuickAction:IsShown() then
		slotbutton.FlyoutBorder:Hide()
		slotbutton.FlyoutBorderShadow:Hide()
		slotbutton.QuickAction.FastExit:Play()
	end

 	
 	PlaySound("igBackPackOpen");
 	
 	if self.tag ~= "Mount" then
 		ContainerFrame1.bags[ContainerFrame1.bagsShown + 1] = self:GetName();
		ContainerFrame1.bagsShown = ContainerFrame1.bagsShown + 1;
	end
	
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = _G["ContainerFrame"..i];
		if ( containerFrame:IsShown() ) then
			containerFrame:Hide();
		end
	end 	
	
	UpdateContainerFrameAnchors()
end


function CollectionsContainerFrame_OnEvent(self, event)

	if event == "CURSOR_UPDATE" and CCB_TEMPORARY_PICKUP ~= nil then
		local type, data, subType, subData = GetCursorInfo()
		if (CCB_TEMPORARY_PICKUP:GetParent() == self and type == nil ) then
		local tempname = CCB_TEMPORARY_PICKUP:GetName()
		CCB_CHAR_SAVE[tempname] = nil
		CCB_TEMPORARY_PICKUP:SetScript("OnUpdate",CollectionsContainerButton_DelayAnimation)
		CCB_TEMPORARY_PICKUP = nil
			if self.tag == "Toy" then
				ToyContainerFrameDiceButton_SetCooldown(ToyContainerFrameDiceButton)
			end
		end
	end
	
	if event == "SPELLS_CHANGED" and self.tag == "Mount" then
		MountContainerFrame_UnlockCheck(self)
	end
	
	if event == "PLAYER_REGEN_DISABLED"  then
		if self.secure == true and not self.disabled then
			self.disabled = true
			self.CloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Disabled")
			self.CloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Disabled")
			self.CloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Disabled")
		end
	end

	if event == "PLAYER_REGEN_ENABLED"  then
		if self.secure == true and self.disabled then
			self.disabled = nil
			self.CloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
			self.CloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
			self.CloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
		end
		if self.DelayedQuickCast then
			if self:IsShown() then
				CollectionsContainerFrame_InitializeQuickCast(self)
			else
				self:UnregisterEvent("PLAYER_REGEN_ENABLED");
				CollectionsContainerFrame_RemoveQuickCast(self)
			end
			self.DelayedQuickCast = nil
		end
	end
	
	if ( event == "DISPLAY_SIZE_CHANGED" ) then
		UpdateContainerFrameAnchors();
	end
	
	if event == "PET_JOURNAL_PET_DELETED" then
	-- delete from pet bag
	end

	-- UpdateContainerFrameAnchors();
end


function CollectionsContainerFrame_GetQuickCastIndex(self)
	
	local name = self:GetName()

	for i = 1, NUM_CCB_SETTINGS do
		if CCB_ACCOUNT_SAVE[i] == name then
			return i
		end
	end

end





function CollectionsContainerFrame_OnKeyUp(self, binding)
	
	if binding == GetBindingKey("TOGGLEGAMEMENU") then
		CollectionsContainerFrame_SecureHide(self)
		return
	end
	
	if self.bound then
		local index = CollectionsContainerFrame_GetQuickCastIndex(self)
		for i = 1, self.size do
			local slot = _G[self:GetName().."Item"..i]
			if not slot.icon:IsDesaturated() == 1 then
				if binding == _G["CCB_TEMPKEYSET_"..index][i] then
					CollectionsContainerFrame_SecureHide(self)
				end
			end
		end
	end
		
end


function CollectionsContainerFrame_InitializeQuickCast(self)

	local index = CollectionsContainerFrame_GetQuickCastIndex(self)
	
	if index == nil then 
		return
	end
	
	local name = self:GetName()
	local barname = CCB_SETTINGS_BARNAME[index];

	local ActionButton = {};
	local ActionButtonKeybind = {};
	local ActionButtonHotkey = {}
	
	for i = 1, self.size do
		ActionButton[i] = _G[barname.."Button"..i];
		ActionButtonKeybind[i] = GetBindingKey(CCB_SETTINGS_COMMAND[index]..i)
		ActionButtonHotkey[i] = _G[barname.."Button"..i.."HotKey"]:GetText();

		SetOverrideBindingClick(self,1,ActionButtonKeybind[i], name.."Item"..i, "RightButton")
		_G[name.."Item"..tostring(i).."HotKey"]:SetText(ActionButtonHotkey[i])
		_G[barname.."Button"..i.."HotKey"]:SetText(nil);
	end
	self.bound = true

end


function CollectionsContainerFrame_RemoveQuickCast(self)

	if self.bound then
	
		local index = CollectionsContainerFrame_GetQuickCastIndex(self)

		local name = self:GetName()
		local barname = CCB_SETTINGS_BARNAME[index];
		local ActionButton = {};
		local ActionButtonKeybind = {};
		local ActionButtonHotkey = {}
	
		for i = 1, self.size do
			ActionButton[i] = _G[barname.."Button"..i];
			ActionButtonHotkey[i] = _G[name.."Item"..tostring(i).."HotKey"]:GetText()
			_G[name.."Item"..tostring(i).."HotKey"]:SetText(nil)
			_G[barname.."Button"..i.."HotKey"]:SetText(ActionButtonHotkey[i]);
		end
		
		ClearOverrideBindings(self)
		self.bound = nil
	end

end


	

NUM_CCB_SETTINGS = 3

CCB_SETTINGS_BARNAME = {
	[1] = "Action",
	[2] = "MultiBarBottomLeft",
	[3] = "MultiBarBottomRight",
};

CCB_SETTINGS_COMMAND = {
	[1] = "ACTIONBUTTON",
	[2] = "MULTIACTIONBAR1BUTTON",
	[3] = "MULTIACTIONBAR2BUTTON",
};

CCB_SETTINGS_LABELS = {
	[1] = "Bottom",
	[2] = "Left",
	[3] = "Right",
};

CCB_SETTINGS_ICONS = {
	[1] = "Interface\\AddOns\\ccBags\\Textures\\SettingsIcon_B",
	[2] = "Interface\\AddOns\\ccBags\\Textures\\SettingsIcon_L",
	[3] = "Interface\\AddOns\\ccBags\\Textures\\SettingsIcon_R",
};



function SetCollectionsBagSlotFlag(self, index, value)
	
	local name = self:GetName()

	if index == 0 then -- Set Close on Quick Cast
	
		if value then
			CCB_ACCOUNT_SAVE[name] = true
		else
			CCB_ACCOUNT_SAVE[name] = nil
		end
	else
		if value then -- Sets a specific actionbar button to a bag
		
		
			-- Clear any duplicate assignments
			if CCB_ACCOUNT_SAVE[index] ~= nil then
				local frame = _G[CCB_ACCOUNT_SAVE[index]]
				if frame:IsShown() then
					CollectionsContainerFrame_RemoveQuickCast(frame)
				end
				frame.SettingsIcon:Hide()
			end
			
			-- Clear any previous assignments
			for i = 1, NUM_CCB_SETTINGS do
				if i ~= index and CCB_ACCOUNT_SAVE[i] == name then
					if self:IsShown() then
						CollectionsContainerFrame_RemoveQuickCast(self)
					end
					CCB_ACCOUNT_SAVE[i] = nil
				end
			end
			
			-- assign new setting
			CCB_ACCOUNT_SAVE[index] = name
			if self:IsShown() then
				CollectionsContainerFrame_InitializeQuickCast(self)
			end
			
		else -- remove setting
			if self:IsShown() then
				CollectionsContainerFrame_RemoveQuickCast(self)
			end
			CCB_ACCOUNT_SAVE[index] = nil
		end
	end
	
	
end

function GetCollectionsBagSlotFlag(self, index)

	local name = self:GetName()

	if index == 0 then
		if CCB_ACCOUNT_SAVE[name] == true then
			return true
		else
			return false
		end
	else
		if CCB_ACCOUNT_SAVE[index] == name then
			return true
		else
			return false
		end
	end

end



function CollectionsContainerFrameDropDown_OnLoad(self)

		UIDropDownMenu_Initialize(_G[self:GetParent():GetName().."DropDown"], CollectionsContainerFrameDropDown_Initialize, "MENU");
end

function CollectionsContainerFrameDropDown_Initialize(self, level)

	local frame = self:GetParent();
	local info = UIDropDownMenu_CreateInfo();	


	info.text = "Assign to Action Bar:";
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);
		
	info.notCheckable = nil;
	info.isTitle = nil;
	for i = 1, NUM_CCB_SETTINGS do
		info.text = CCB_SETTINGS_LABELS[i];
		info.func = function(_, _, _, value)
			value = not value;
				SetCollectionsBagSlotFlag(frame, i, value);
			if (value) then
				frame.SettingsIcon.Icon:SetTexture(CCB_SETTINGS_ICONS[i]);
				frame.SettingsIcon:Show();
			else
				frame.SettingsIcon:Hide();
			end
		end;
		info.checked = GetCollectionsBagSlotFlag(frame, i);
		info.disabled = nil;
		info.tooltipTitle = nil;
		UIDropDownMenu_AddButton(info);
	end
	
	--[[ Not implemented
	
	info.text = "Quick Cast";
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);
	
	info.isTitle = nil;
	info.notCheckable = nil;
	info.isNotRadio = true;
	info.disabled = nil;

	info.text = "Close on cast ";
	info.func = function(_, _, _, value)
		SetCollectionsBagSlotFlag(frame, 0, not value);
	end;
	info.checked = GetCollectionsBagSlotFlag(frame, 0);
	UIDropDownMenu_AddButton(info);
	
	--]]
	
	--stop
	info.text = "";
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	--stop
	info.text = "ccBags.0.0.1";
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

end


-- anchor functions

NUM_CONTAINER_FRAMES = 13;
NUM_BAG_FRAMES = 4;
MAX_CONTAINER_ITEMS = 36;
NUM_CONTAINER_COLUMNS = 4;
ROWS_IN_BG_TEXTURE = 6;
MAX_BG_TEXTURES = 2;
BG_TEXTURE_HEIGHT = 512;
CONTAINER_WIDTH = 192;
CONTAINER_SPACING = 0;
VISIBLE_CONTAINER_SPACING = 3;
CONTAINER_OFFSET_Y = 70;
CONTAINER_OFFSET_X = 0;
CONTAINER_SCALE = 0.75;
BACKPACK_HEIGHT = 255;

UpdateContainerFrameAnchors = function(...)
	local frame, xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column;
	local screenWidth = GetScreenWidth();
	local containerScale = 1;
	local leftLimit = 0;
	if ( BankFrame:IsShown() ) then
		leftLimit = BankFrame:GetRight() - 25;
	end
	
	
	while ( containerScale > CONTAINER_SCALE ) do
		screenHeight = GetScreenHeight() / containerScale;
		-- Adjust the start anchor for bags depending on the multibars and mount bag
		xOffset = CONTAINER_OFFSET_X / containerScale; 
		
		if MountContainerFrame:IsShown() then
			local MountHeight = MountContainerFrame:GetHeight()
			yOffset = (CONTAINER_OFFSET_Y + MountHeight) / containerScale;
			MountyOffset = CONTAINER_OFFSET_Y / containerScale; 
		else
			yOffset = CONTAINER_OFFSET_Y / containerScale; 
		end

		-- freeScreenHeight determines when to start a new column of bags
		freeScreenHeight = screenHeight - yOffset;
		leftMostPoint = screenWidth - xOffset;
		column = 1;
		local frameHeight;
		for index, frameName in ipairs(ContainerFrame1.bags) do
			frameHeight = _G[frameName]:GetHeight();
			if ( freeScreenHeight < frameHeight ) then
				-- Start a new column
				column = column + 1;
				leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * containerScale ) - xOffset;
				freeScreenHeight = screenHeight - yOffset;
			end
			freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING;
		end
	
		if ( leftMostPoint < leftLimit ) then
			containerScale = containerScale - 0.01;
		else
			break;
		end
	end
	
	if ( containerScale < CONTAINER_SCALE ) then
		containerScale = CONTAINER_SCALE;
	end
	
	screenHeight = GetScreenHeight() / containerScale;
	-- Adjust the start anchor for bags depending on the multibars
		xOffset = CONTAINER_OFFSET_X / containerScale; 
		
		if MountContainerFrame:IsShown() then
			local MountHeight = MountContainerFrame:GetHeight()
			yOffset = (CONTAINER_OFFSET_Y + MountHeight) / containerScale;
			MountyOffset = CONTAINER_OFFSET_Y / containerScale; 
		else
			yOffset = CONTAINER_OFFSET_Y / containerScale; 
		end
		
	-- freeScreenHeight determines when to start a new column of bags
	freeScreenHeight = screenHeight - yOffset;
	column = 0;
	
	if MountContainerFrame:IsShown() then
		frame = MountContainerFrame;
		frame:SetScale(containerScale);
		frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, MountyOffset);
	end
		
	for index, frameName in ipairs(ContainerFrame1.bags) do
		frame = _G[frameName];
		frame:SetScale(containerScale);
		if ( index == 1 ) then
			-- First bag
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, yOffset );
		elseif ( freeScreenHeight < frame:GetHeight() ) then
			-- Start a new column
			column = column + 1;
			freeScreenHeight = screenHeight - yOffset;
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -(column * CONTAINER_WIDTH) - xOffset, yOffset );
		else
			-- Anchor to the previous bag
			frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING);	
		end
		freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING;
	end
end



