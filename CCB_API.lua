function CCB_AssignTag(self)

	local tag = string.sub(self:GetName(),1,1)
	
	if tag == "M" then
		self.tag = "Mount"
	elseif tag == "P" then
		self.tag = "Pet"
	elseif tag == "T" then
		self.tag = "Toy"
	elseif tag == "S" then
		self.tag = "Set"
	elseif tag == "B" then
		self.tag = "Bag"
	end

end


function CCB_AssignOwner(self)

	local tag = self.tag
	
	if tag == "Mount" then
		self.owner = _G["MountContainerFrame"]
	elseif tag == "Pet" then
		self.owner = _G["PetContainerFrame"]
	elseif tag == "Toy" then
		local prefixlength = strfind(self:GetName(), "Frame")
		if prefixlength == 13 then
			self.owner = _G["ToyContainerFrame"]
		elseif prefixlength == 17 then
			self.owner = _G["ToyContainerCardFrame"]
		elseif prefixlength == 18 then
			self.owner = _G["ToyContainerBoardFrame"]
		end
	elseif tag == "Set" then
		self.owner = _G["SetContainerFrame"]
	elseif tag == "Bag" then
		self.owner = "Bag"
	end

end

