function QuickActionsButton_PreClick(self, button, down, secure)

	local tag = self.tag
	local slotnumber = self.slot
	local frame = _G[tag.."ContainerSlotButton"]
	local ShowFlyout = not(frame.check:IsShown())
	
	local slot
	local index
	
	if tag ~= "Bag" then
		slot = _G[tag.."ContainerFrameItem"..slotnumber]
		index = CCB_CHAR_SAVE[tag.."ContainerFrameItem"..slotnumber]
	else
		index = slotnumber
		local number = 17-slotnumber
		slot = _G["ContainerFrame1Item"..number]
	end
	
	local iconpath = C_GetItemIconByIndex(tag, index)	

	if down == true then

		if frame.buttonsdown == nil then
			frame.buttonsdown = 1
		else
			frame.buttonsdown = frame.buttonsdown + 1
		end

		if ShowFlyout then
	
			frame.FlyoutBorder:Show()
			frame.FlyoutBorderShadow:Show()

			frame.QuickAction.Exit:Stop()
			QuickActionIcon_Refresh(frame,tag,index)
			frame.QuickAction:SetScript("OnUpdate",QuickActionIcon_OnUpdate)
			frame.QuickAction:Show()
			frame.QuickAction:SetAlpha(1)
	
			frame.QuickAction.FlyoutArrow:Show()
			frame.QuickAction.FlyoutArrow.Click:Stop()
			frame.QuickAction.FlyoutArrow:SetAlpha(1)
			
		elseif ShowFlyout == false and iconpath ~= nil then
			slot:SetButtonState("PUSHED")
		end

	elseif down == false then
	
		frame.buttonsdown = frame.buttonsdown - 1
	
		if ShowFlyout == false then
			slot:SetButtonState("NORMAL")
		else
			if frame.buttonsdown < 2 then
				frame.FlyoutBorder:Hide()
				frame.FlyoutBorderShadow:Hide()
				frame.QuickAction.Exit:Play()
			end
		end
	end
    
    if GetCVarBool("ActionButtonUseKeyDown") == true and down == true then
		frame.QuickAction.FlyoutArrow.Click:Play()
		if secure == false then 
			C_UseItemByIndex(tag, index)
		end
    elseif GetCVarBool("ActionButtonUseKeyDown") ~= true and down == false then
		frame.QuickAction.FlyoutArrow.Click:Play()
		if secure == false then
			C_UseItemByIndex(tag, index)
		end
    end

end

function QuickActionIcon_Refresh(frame,tag,index)

	local iconpath = C_GetItemIconByIndex(tag, index)	
	local quality = C_GetItemQualityByIndex(tag, index)


	if iconpath == nil then
		frame.QuickAction.Icon:SetTexCoord(0,0.609375,0,0.609375)
		iconpath = "Interface\\AddOns\\ccBags\\Textures\\BlankQuickAction"
	else
		frame.QuickAction.Icon:SetTexCoord(0,1,0,1)
	end
	
	frame.QuickAction.Icon:SetTexture(iconpath)

	if quality ~= nil then 
		frame.QuickAction.Border:Hide()
		frame.QuickAction.Quality:SetVertexColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b)
		frame.QuickAction.Quality:Show()
	else
		frame.QuickAction.Border:Show()
		frame.QuickAction.Quality:Hide()
	end

	local quality = C_GetItemQualityByIndex(tag, index)

	frame.QuickAction.tag = tag
	frame.QuickAction.index = index
	
end

function QuickActionIcon_OnUpdate(self,elapsed)


	local tag = self.tag
	local index = self.index

	local active = C_CheckActiveByIndex(tag, index)

	if active then
		self.check:Show()
	else
		self.check:Hide()
	end


	local startTime, duration, enable = C_GetCooldownByIndex(tag, index)

	if (startTime) and duration > 1.5 then
		CooldownFrame_Set(self.Cooldown, startTime, duration, enable);
	else
		self.Cooldown:Hide()
	end
	
	
	local isUsable = C_GetIsUsableByIndex(kind, index)

	
	if ( not isUsable and not startTime and self.Icon:GetTexture() ~= "Interface\\AddOns\\ccBags\\Textures\\BlankQuickAction") then
		self.Icon:SetVertexColor(0.4, 0.4, 0.4);
	else
		self.Icon:SetVertexColor(1.0, 1.0, 1.0);
	end

end