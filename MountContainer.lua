--Button functions

function MountContainerButton_UpdateTooltip(self)

		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		local name = self:GetName()
		local index = CCB_CHAR_SAVE[name]
		local creatureName, spellID, icon, active = C_MountJournal.GetMountInfoByID(index);
		if (spellID) then
			GameTooltip:SetMountBySpellID(spellID);
			self.showingTooltip = true;
			GameTooltip:Show();
		
		elseif self.locked == true then
			if self:GetName() == "MountContainerFrameItem5" then
				GameTooltip:SetText("Extra Slot 1", 1, 1, 1);
				GameTooltip:AddLine("Unlocked with Artisan Riding.", nil, nil, nil, true);		
			elseif self:GetName() == "MountContainerFrameItem6" then
				GameTooltip:SetText("Extra Slot 2", 1, 1, 1);
				GameTooltip:AddLine("Unlocked with Master Riding.", nil, nil, nil, true);		
			end 
			self.showingTooltip = true;
			GameTooltip:Show();
		end
end


function MountContainerFrame_UnlockCheck(self)

	local data = {33388,33391,34090,34091,90265}
	local skill = 0
	local button5 = _G[self:GetName().."Item5"]
	local button6 = _G[self:GetName().."Item6"]

	for i=#data,1,-1 do
		if IsSpellKnown(data[i]) then
			skill = 75*i
			break
		end
	end

	if skill == 375 then
		MountContainerFrame.size = 6
		CollectionsContainer_LockButton(button5, false)
		CollectionsContainer_LockButton(button6, false)

	elseif skill == 300 then
		MountContainerFrame.size = 5
		CollectionsContainer_LockButton(button5, false)
		CollectionsContainer_LockButton(button6, true)
	else
		MountContainerFrame.size = 4
		CollectionsContainer_LockButton(button5, true)
		CollectionsContainer_LockButton(button6, true)
	end

end


function CollectionsContainer_LockButton(button, locked)

	local name = button:GetName()

	if locked == true then
		if button.locked ~= true then
			button.locked = true
			button:SetScript("PreClick", nil)
			local point, relativeTo, relativePoint, xOffset, yOffset = button:GetPoint(button)
			button:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset-1)
			button.icon:SetTexture("Interface\\AddOns\\ccBags\\Textures\\buttonlock")
			button.icon:SetTexCoord(0, 0.547, 0, 0.547)
			SetItemButtonNormalTextureVertexColor(button, 1, 1, 1)
			_G[button:GetName().."NormalTexture"]:SetAlpha(0.5)
			CCB_CHAR_SAVE[name] = nil
		end
	else
		if button.locked == true then
			button.locked = nil
			button:SetScript("PreClick", CollectionsContainerButton_PreClick)
			local point, relativeTo, relativePoint, xOffset, yOffset = button:GetPoint(button)
			button:SetPoint(point, relativeTo, relativePoint, xOffset, 0)
			button.icon:SetTexture(nil)
			SetItemButtonNormalTextureVertexColor(button, 0.85, 0.85, 0.85)
			_G[button:GetName().."NormalTexture"]:SetAlpha(0.85)
		end
	end
end