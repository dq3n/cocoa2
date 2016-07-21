--Button functions

function PetContainerButton_UpdateTooltip(self)

	local name = self:GetName()
	local index = CCB_CHAR_SAVE[name]
	
	if index ~= nil then
	
		local speciesID, customName, level, xp, maxXp, displayID, isFavorite, petName, petIcon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = C_PetJournal.GetPetInfoByPetID(index);
		local summonedPetID = C_PetJournal.GetSummonedPetGUID();
		
		if speciesID == nil then
			return
		end
		
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText(petName, 1, 1, 1);
		GameTooltip:AddLine(description, nil, nil, nil, true);
		
		if ( index == summonedPetID and summonedPetID ~= nil ) then
			GameTooltip:AddLine("Right-click to dismiss.", 0.6, 0.6, 0.6, true);
		else
			GameTooltip:AddLine("Right-click to summon.", 0, 1, 0, true);
		end
							
		self.showingTooltip = true;
		GameTooltip:Show();
	end
end


function PetContainerFrameTreatButton_UpdateDisabled(self)
	
	local counter = 0
	
	for i = 1, 3 do
		local frame = _G["PetContainerFrameItem"..i]
		local name = frame:GetName()
		if CCB_CHAR_SAVE[name] == nil then
		counter = counter + 1
		end
	end
	
	if counter == 3 then
		self.disabled = true
	else
		self.disabled = nil
	end
	
end

function PetContainerFrameBattleButton_UpdateDisabled(self)
	
	local petID, ability1ID, ability2ID, ability3ID, locked = C_PetJournal.GetPetLoadOutInfo(3);
	
	if petID == nil then
		self.disabled = true
	else
		self.disabled = false
	end
	
end

function PetContainerFrameReviveButton_UpdateDisabled(self)
	
	self.disabled = false
	
end



function PetContainerFrameTreatButton_UpdateTooltip(self)

	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText("Treat Pet", 1, 1, 1);
	local petID = C_PetJournal.GetSummonedPetGUID()

	
	if self.disabled == true then
		GameTooltip:AddLine("Place a companion from the Pet Journal into this container to get started.", nil, nil, nil, true);
	elseif petID == nil then
		GameTooltip:AddLine("Treat an random pet from this container.", nil, nil, nil, true);
	elseif petID ~= CCB_CHAR_SAVE["PetContainerFrameItem1"] and petID ~= CCB_CHAR_SAVE["PetContainerFrameItem2"] and petID ~= CCB_CHAR_SAVE["PetContainerFrameItem3"] then
		GameTooltip:AddLine("Summon and treat an random pet from this container and give them a treat.", nil, nil, nil, true);
	else
		GameTooltip:AddLine("Give your active companion a little love.", nil, nil, nil, true);
	end
	
	self.showingTooltip = true;
	GameTooltip:Show();
end

function PetContainerFrameReviveButton_UpdateTooltip(self)

	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText("Revive Battle Pets", 1, 1, 1);
	if self.disabled == true then
		GameTooltip:AddLine("Requires 3 active battle pets.", 1, nil, nil, true);
	else
		GameTooltip:AddLine("Heals and resurrects all of your battle pets to 100% health.", nil, nil, nil, true);
	end
	self.showingTooltip = true;
	GameTooltip:Show();
	
end

function PetContainerFrameBattleButton_UpdateTooltip(self)

	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	if CCB_PETCONTAINER_STATE == 0 then
		GameTooltip:SetText("Battle Mode", 1, 1, 1);
		if self.disabled == true then
			GameTooltip:AddLine("Requires 3 equipped battle pets.", 1, nil, nil, true);
		else
			GameTooltip:AddLine("Display your active battle pets.", nil, nil, nil, true);
		end
	elseif CCB_PETCONTAINER_STATE == 1 then
		GameTooltip:SetText("Leave Battle Mode", 1, 1, 1);
		if self.disabled == true then
			GameTooltip:AddLine("Requires 3 active battle pets.", 1, nil, nil, true);
		else
			GameTooltip:AddLine("Display to your your companion pet slots.", nil, nil, nil, true);
		end
	end
	self.showingTooltip = true;
	GameTooltip:Show();
	
end



----------------------------------------------
---------------- Treat Button ----------------
----------------------------------------------

CCB_TREAT_CD = 960


function PetContainerFrameTreatButton_OnUpdate(self,elapsed)

	self.timer = self.timer + elapsed
	local button = PetContainerFrameTreatButton

	if self.state == 0 then
	
		self.state = 1
		local startTime = GetTime()
		CooldownFrame_Set(button.Cooldown,startTime,CCB_TREAT_CD,1)
		CCB_CHAR_SAVE["TreatTimer"] = startTime

	elseif self.state == 1 then
	
		self.state = 2 
		--summon random pet
		local petID = C_PetJournal.GetSummonedPetGUID()
		local summon = false

		if petID == nil then
		summon = true
		elseif petID ~= CCB_CHAR_SAVE["PetContainerFrameItem1"] and petID ~= CCB_CHAR_SAVE["PetContainerFrameItem2"] and petID ~= CCB_CHAR_SAVE["PetContainerFrameItem3"] then
		summon = true
		end
	
		if summon == true then
	
			local pick = 0
			while pick == 0 do
				pick = math.random(1,3)
				if CCB_CHAR_SAVE["PetContainerFrameItem"..pick] == nil then
					pick = 0
				end
			end
	
			local name = "PetContainerFrameItem"..pick
			local index = CCB_CHAR_SAVE[name]
			C_PetJournal.SummonPetByGUID(index)
		else
			self:SetScript("OnUpdate", nil)
			self.timer = 0
			self.state = 0
			PetContainerFrameTreatButton_Roll()
		end 
		
	elseif self.timer > 1 and self.state == 2 then
	
		self:SetScript("OnUpdate", nil)
		PetContainerFrameTreatButton_Roll()
		self.timer = 0
		self.state = 0
	
	end

end


function PetContainerFrameTreatButton_PreClick(self, button)

	PetContainerSlotButton.state = 0
	PetContainerSlotButton.timer = 0
	PetContainerSlotButton:SetScript("OnUpdate", PetContainerFrameTreatButton_OnUpdate)

end



function PetContainerFrameTreatButton_Roll()

	--locate pet
	local petID = C_PetJournal.GetSummonedPetGUID();
	local petFrame
	
	for i = 1,3 do 
		local name = "PetContainerFrameItem"..i
		if CCB_CHAR_SAVE[name] == petID then
			petFrame = _G[name]
		end
	end
	
	if petFrame == nil then
		CooldownFrame_Set(PetContainerFrameTreatButton.Cooldown,GetTime(),6,1)
		CCB_CHAR_SAVE["TreatTimer"] = GetTime()
		return
	end
	
	--create distribution
	local petpersonality
	
	if CCB_ACCOUNT_SAVE[petID] == nil then
		local a = math.random(0,9)
		local b = math.random(0,9)
		
		if CCB_ACCOUNT_SAVE["digita"] == nil then
			CCB_ACCOUNT_SAVE["digita"] = 10
		end
		
		if CCB_ACCOUNT_SAVE["digita"] == nil then
			CCB_ACCOUNT_SAVE["digita"] = 10
		end

		if CCB_ACCOUNT_SAVE["digitaa"] == nil then
			CCB_ACCOUNT_SAVE["digitaa"] = 10
		end

		if CCB_ACCOUNT_SAVE["digitbb"] == nil then
			CCB_ACCOUNT_SAVE["digitbb"] = 10
		end

		while CCB_ACCOUNT_SAVE["digita"] == a or CCB_ACCOUNT_SAVE["digitb"] == a or CCB_ACCOUNT_SAVE["digitaa"] == a do
			a = math.random(0,9)
		end
		
		while CCB_ACCOUNT_SAVE["digita"] == b or CCB_ACCOUNT_SAVE["digitb"] == b or CCB_ACCOUNT_SAVE["digitbb"] == b do
			b = math.random(0,9)
		end
				
		petpersonality = a..b
		CCB_ACCOUNT_SAVE[petID] = petpersonality
		CCB_ACCOUNT_SAVE["digitaa"] = CCB_ACCOUNT_SAVE["digita"]
		CCB_ACCOUNT_SAVE["digitbb"] = CCB_ACCOUNT_SAVE["digitb"] 
		CCB_ACCOUNT_SAVE["digita"] = a
		CCB_ACCOUNT_SAVE["digitb"] = b
	else
		petpersonality = CCB_ACCOUNT_SAVE[petID]
	end
	
	if CCB_CHAR_SAVE[petID] == nil then
		CCB_CHAR_SAVE[petID] = 0
	end
	
	local digita = tonumber(petpersonality:sub(1,1)) 
	local digitb = tonumber(petpersonality:sub(2,2))
	local petpersonality = tonumber(petpersonality)
	local trait
	
	local dominantroll = math.random(1,5)
	
	if dominantroll == 1 then
		if digitb < 2 then
			trait = "a"
		elseif digitb < 5 then
			trait = "b"
		elseif digitb < 8 then
			trait = "c"
		else
			trait = "d"
		end
	else
		if petpersonality < 25 then
			trait = "a"
		elseif petpersonality < 50 then
			trait = "b"
		elseif petpersonality < 75 then
			trait = "c"
		else
			trait = "d"
		end
	end
	
	local speciesID, customName, level, xp, maxXp, displayID, isFavorite, petName, petIcon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = C_PetJournal.GetPetInfoByPetID(petID)
	
	if canBattle == false then 
		trait = "c"
	end

	
	if CCB_ACCOUNT_SAVE["JACKPOT_METER"] == nil then
		CCB_ACCOUNT_SAVE["JACKPOT_METER"] = 5
	end
	
	if CCB_ACCOUNT_SAVE["SAD_METER"] == nil then
		CCB_ACCOUNT_SAVE["SAD_METER"] = 0
	end

	
	CCB_ACCOUNT_SAVE["JACKPOT_METER"] = CCB_ACCOUNT_SAVE["JACKPOT_METER"] + 1

	
	if CCB_ACCOUNT_SAVE["TRAIT_METER"] == nil then
		CCB_ACCOUNT_SAVE["TRAIT_METER"] = 0
	end
	
	CCB_ACCOUNT_SAVE["TRAIT_METER"] = CCB_ACCOUNT_SAVE["TRAIT_METER"] + 1


	local rolls = CCB_CHAR_SAVE[petID]
	
	local bonusjackpot
	
	if rolls >= 1020 then 
		bonusjackpot = 0.5
	elseif rolls >= 1080 then
		bonusjackpot = 1
	elseif rolls >= 1100 then
		bonusjackpot = 2
	else
		bonusjackpot = 0
	end
	
	local jackpotmax = 5 + (digita * (1 + bonusjackpot))
	local maxroll = PetContainerFrameTreatButton_GetMaxRoll()
	local baseunhappy
	
	if rolls > 500 then
		baseunhappy = 2
	elseif rolls < 20 then
		baseunhappy = (20 * math.abs(1 - (rolls/20)))
	end
	
	local decreasemax = math.floor(baseunhappy + (digitb * 3) + 0.5) + jackpotmax
	local freeroll = decreasemax + 25
	
	--generate outcome
	local outcome = math.random(1,100)
	
	if rolls < -500 then
	
		local pass = math.random(1 + CCB_ACCOUNT_SAVE["JACKPOT_METER"],25 + CCB_ACCOUNT_SAVE["JACKPOT_METER"])
		if pass < 26 then
			PetContainerFrameTreatButton_PlayEmote(petID,"blackheart_not_passed",0,digita,digitb)
			PetContainerFrameTreatButton_SetRoll(petFrame,-1)
		else
			PetContainerFrameTreatButton_PlayEmote(petID,"blackheart_passed",1,digita,digitb)
			CCB_CHAR_SAVE[petID] = 0
			PetContainerFrameTreatButton_SetRoll(petFrame, 0)
		end
		
	elseif rolls > 2 and CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"] == 6 then
		CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"] = 7
		PetContainerFrameTreatButton_PlayEmote(petID,"blackheart",0,digita,digitb)
		PetContainerFrameTreatButton_SetRoll(petFrame,-10000)	
		
	elseif outcome <= jackpotmax then 
	
		if CCB_ACCOUNT_SAVE["JACKPOT_METER"] <= 4 and math.random(1,CCB_ACCOUNT_SAVE["JACKPOT_METER"]) == 1 then
			PetContainerFrameTreatButton_SetRoll(petFrame,1)
			PetContainerFrameTreatButton_PlayEmote(petID,"jackpotfail",0,digita,digitb)
			CCB_ACCOUNT_SAVE["JACKPOT_METER"] = CCB_ACCOUNT_SAVE["JACKPOT_METER"] + 2
		elseif trait == "d" then
			--Share Jackpot
			PetContainerFrameTreatButton_PlayEmote(petID,"share",1,digita,digitb)
			PetContainerFrameTreatButton_SetRoll(PetContainerFrameItem1,1)
			PetContainerFrameTreatButton_SetRoll(PetContainerFrameItem2,1)
			PetContainerFrameTreatButton_SetRoll(PetContainerFrameItem3,1)
			CCB_ACCOUNT_SAVE["JACKPOT_METER"] = 2
			CCB_ACCOUNT_SAVE["TRAIT_METER"] = 0
		elseif trait == "a" and CCB_ACCOUNT_SAVE["TRAIT_METER"] > 1 then
			--Big Jackpot
			PetContainerFrameTreatButton_PlayEmote(petID,"bigjackpot",1,digita,digitb)
			PetContainerFrameTreatButton_SetRoll(petFrame,10)
			CCB_ACCOUNT_SAVE["JACKPOT_METER"] = 1
			CCB_ACCOUNT_SAVE["TRAIT_METER"] = 0
		else
			--Jackpot
			PetContainerFrameTreatButton_PlayEmote(petID,"jackpot",1,digita,digitb)
			PetContainerFrameTreatButton_SetRoll(petFrame,3)
			CCB_ACCOUNT_SAVE["JACKPOT_METER"] = 1
		end
		
	elseif outcome <= decreasemax then
	
		if CCB_ACCOUNT_SAVE["SAD_METER"] > 4 and math.random(1,25) == 13 then
			--blackheart
			PetContainerFrameTreatButton_PlayEmote(petID,"blackheart",0,digita,digitb)
			PetContainerFrameTreatButton_SetRoll(petFrame,-10000)
			CCB_ACCOUNT_SAVE["SAD_METER"] = CCB_ACCOUNT_SAVE["SAD_METER"] + 1
		elseif CCB_ACCOUNT_SAVE["SAD_METER"] > 2 and math.random(1,2) == 1 then
			--Apathy
			PetContainerFrameTreatButton_PlayEmote(petID,"overwrite_sad",1,digita,digitb)
			PetContainerFrameTreatButton_SetRoll(petFrame,0)
			CCB_ACCOUNT_SAVE["SAD_METER"] = 0
		elseif trait == "c" then
			--Apathy
			PetContainerFrameTreatButton_PlayEmote(petID,"apathy",0,digita,digitb)
			PetContainerFrameTreatButton_SetRoll(petFrame,0)
			CCB_ACCOUNT_SAVE["TRAIT_METER"] = 0
			CCB_ACCOUNT_SAVE["SAD_METER"] = 0
		else
			--Sad
			PetContainerFrameTreatButton_PlayEmote(petID,"sad",0,digita,digitb)
			PetContainerFrameTreatButton_SetRoll(petFrame,-1)
			CCB_ACCOUNT_SAVE["SAD_METER"] = CCB_ACCOUNT_SAVE["SAD_METER"] + 1
		end
		
	elseif outcome <= freeroll and trait == "b" then
		--Free Roll
		local failroll = math.random(1, (1 + CCB_ACCOUNT_SAVE["TRAIT_METER"]))

		if failroll == 1 then
			--Sad
			PetContainerFrameTreatButton_PlayEmote(petID,"freeroll_sad",0,digita,digitb)
			PetContainerFrameTreatButton_SetRoll(petFrame,-1)
			CCB_ACCOUNT_SAVE["SAD_METER"] = CCB_ACCOUNT_SAVE["SAD_METER"] + 1
			CCB_ACCOUNT_SAVE["TRAIT_METER"] = 0
		else
			PetContainerFrameTreatButton_PlayEmote(petID,"freeroll",1,digita,digitb)
			CooldownFrame_Set(PetContainerFrameTreatButton.Cooldown,GetTime(),3.4,1)
			PetContainerFrameTreatButton_SetRoll(petFrame,1)
			CCB_CHAR_SAVE["TreatTimer"] = GetTime()
			CCB_ACCOUNT_SAVE["TRAIT_METER"] = 0
		end
	else
		--Happy
		local upgrade = math.random(1, 1 + math.ceil(9/(1+CCB_ACCOUNT_SAVE["JACKPOT_METER"])))
		if upgrade == 1 and CCB_ACCOUNT_SAVE["JACKPOT_METER"] > 2 then
			PetContainerFrameTreatButton_SetRoll(petFrame,3)
			CCB_ACCOUNT_SAVE["JACKPOT_METER"] = 0
			PetContainerFrameTreatButton_PlayEmote(petID,"happy_upgrade",1,digita,digitb)
		else
			PetContainerFrameTreatButton_SetRoll(petFrame,1)
			PetContainerFrameTreatButton_PlayEmote(petID,"happy",1,digita,digitb)
		end
	end

end 


CCB_EMOTE_QUEUED = "blank"

function PetContainerFrameTreatButton_PlayEmote(petID,outcome,outcometype,digita,digitb)

	local emote
	digitb = tonumber(digitb)
	digita = tonumber(digita)
	local roll = CCB_CHAR_SAVE[petID]

-- chance of digita being swapped with digitb	

	local familiarity = 0

	if roll > 1200 then
		familiarity = 9
	elseif roll > 1100 then 
		familiarity = 7
	elseif roll > 1050 then
		familiarity = 5
	elseif roll > 1020 then
		familiarity = 3
	elseif roll > 1000 then
		familiarity = 1
	end

	local outcomeswitch = math.random(10-familiarity,20)

	if outcomeswitch <= 10 and roll > 5 then 
		if outcometype == 1 then
			outcometype = 0
		elseif outcometype == 0 then
			outcometype = 1
		end
	end
	
-- chance of outcome being switched	

	local consistency = math.abs(digita - digitb)*2
	local digitswitch = math.random(1,25-consistency)
	
	if digitswitch == 1 and roll > 10 then 
		local digit = digita
		digita = digitb
		digitb = temp
	end

-- define personality based on outcometype and digit

	if outcometype == 1 then
		if digita == 0 then
			personality = "a"
		elseif digita == 1 then
			personality = "b"
		elseif digita == 2 then
			personality = "c"
		elseif digita == 3 then
			personality = "d"
		elseif digita == 4 then
			personality = "e"
		elseif digita == 5 then
			personality = "f"
		elseif digita == 6 then
			personality = "g"
		elseif digita == 7 then
			personality = "h"
		elseif digita == 8 then
			personality = "i"
		elseif digita == 9 then
			personality = "j"
		end
	elseif outcometype == 0 then
		if digitb == 0 then
			personality = "a"
		elseif digitb == 1 then
			personality = "b"
		elseif digitb == 2 then
			personality = "c"
		elseif digitb == 3 then
			personality = "d"
		elseif digitb == 4 then
			personality = "e"
		elseif digitb == 5 then
			personality = "f"
		elseif digitb == 6 then
			personality = "g"
		elseif digitb == 7 then
			personality = "h"
		elseif digitb == 8 then
			personality = "i"
		elseif digitb == 9 then
			personality = "j"
		end
	end
	
-- define non-battle pet personalities
	
	local speciesID, customName, level, xp, maxXp, displayID, isFavorite, petName, petIcon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = C_PetJournal.GetPetInfoByPetID(petID)

	
	local forthwall = math.random(1,4)
	
	if canBattle == false and forthwall == 1 and CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"] > 2 then 
		personality = "y"
	elseif canBattle == false then
		personality = "z"
	end


-- define prefix & name string

	local sexID = UnitSex("Player")
	local Sex
	local sex
	local name

	if sexID == 2 then
		sex = "his"
	elseif sexID == 3 then
		sex = "her"
	end

	if sexID == 2 then
		Sex = "His"
	elseif sexID == 3 then
		Sex = "Her"
	end

	local prefix = math.random(1,5)

	if prefix == 1 then
		prefix = "tosses a treat in the air."
	elseif prefix == 2 then
		prefix = "dangles a treat with "..sex.." hand."
	elseif prefix == 3 then
		prefix = "starts to unwrap a treat."
	elseif prefix == 4 then
		prefix = "puts a treat in the palm of "..sex.." hand."
	elseif prefix == 5 then
		prefix = "drops a treat on the ground."
	end

	if customName == nil then
		name = " "..Sex.." "..petName
	else
		name = " "..customName.." the "..petName
	end

-- define action based on personality and outcome

	local action	

	if personality == "a" then -- Strong\Aggressive
		if outcome == "happy" then
			action = " chomps down."
		elseif outcome == "happy_upgrade" then
			action = " gnaws the air in anticipation."
		elseif outcome == "freeroll" then
			action = " fetches it back."
		elseif outcome == "freeroll_sad" then
			action = " chokes on the wrapper."
		elseif outcome == "overwrite_sad" then
			action = " stares it down."
		elseif outcome == "sad" then
			action = " crushes it."
		elseif outcome == "apathy" then
			action = " gives it a sniff."
		elseif outcome == "jackpot" then
			action = " pounds in anticipation."
		elseif outcome == "bigjackpot" then
			action = " unleashes a mighty roar."
		elseif outcome == "share" then
			action = " tosses it around."
		elseif outcome == "jackpotfail" then
			action = " leaps up."
		elseif outcome == "blackheart" then
			action = " kicks it "..math.random(30,100).." yards away"
		elseif outcome == "blackheart_passed" then
			action = " is perfectly still."
		elseif outcome == "blackheart_not_passed" then
			action = " swipes at it."
		end
	elseif personality == "b" then -- Funny/Silly
		if outcome == "happy" then
			action = " scrambles over."
		elseif outcome == "happy_upgrade" then
			action = " makes airplane noises."
		elseif outcome == "freeroll" then
			action = " returns it intact."
		elseif outcome == "freeroll_sad" then
			action = " is tired."
		elseif outcome == "overwrite_sad" then
			action = " squeezes it."
		elseif outcome == "sad" then
			action = " jumps on it."
		elseif outcome == "apathy" then
			action = " snickers, heh-he."
		elseif outcome == "jackpot" then
			action = " jumps up and down."
		elseif outcome == "bigjackpot" then
			action = " sets it on fire."
		elseif outcome == "share" then
			action = " eats just the wrapper."
		elseif outcome == "jackpotfail" then
			action = " is confused."
		elseif outcome == "blackheart" then
			action = " drops everything."
		elseif outcome == "blackheart_passed" then
			action = " blinks twice."
		elseif outcome == "blackheart_not_passed" then
			action = " makes no sound."
		end
	elseif personality == "c" then -- Sarcastic/drunk
		if outcome == "happy" then
			action = " is SO happy."
		elseif outcome == "happy_upgrade" then
			action = " was a little hungry."
		elseif outcome == "freeroll" then
			action = " puts it back in the wrapper."
		elseif outcome == "freeroll_sad" then
			action = " smiles."
		elseif outcome == "overwrite_sad" then
			action = " wonders if it's ethically sourced."
		elseif outcome == "sad" then
			action = " is hungry for apples."
		elseif outcome == "apathy" then
			action = " finds the pet-treat dynamic oppressive."
		elseif outcome == "jackpot" then
			action = " trades it in for two treats later."
		elseif outcome == "bigjackpot" then
			action = " trades it in for a drink."
		elseif outcome == "share" then
			action = " divides it into three even pieces."
		elseif outcome == "jackpotfail" then
			action = " trades it for a drink."
		elseif outcome == "blackheart" then
			action = " gets all existential."
		elseif outcome == "blackheart_passed" then
			action = " understands the gesture."
		elseif outcome == "blackheart_not_passed" then
			action = " doesn't see the point."
		end
	elseif personality == "d" then -- Cheerful/Loud
		if outcome == "happy" then
			action = " hops to it."
		elseif outcome == "happy_upgrade" then
			action = " goes nuts."
		elseif outcome == "freeroll" then
			action = " only eats the name brand."
		elseif outcome == "freeroll_sad" then
			action = " is over it."
		elseif outcome == "overwrite_sad" then
			action = " is on a diet."
		elseif outcome == "sad" then
			action = " is over it."
		elseif outcome == "apathy" then
			action = " is on a diet"
		elseif outcome == "jackpot" then
			action = " goes crazy."
		elseif outcome == "bigjackpot" then
			action = " blows a kiss."
		elseif outcome == "share" then
			action = " calls over other pets."
		elseif outcome == "jackpotfail" then
			action = " is up to party"
		elseif outcome == "blackheart" then
			action = " is burnt out."
		elseif outcome == "blackheart_passed" then
			action = " smiles."
		elseif outcome == "blackheart_not_passed" then
			action = " is not hungry."
		end
	elseif personality == "e" then -- Graceful/rich
		if outcome == "happy" then
			action = " takes a few bites."
		elseif outcome == "happy_upgrade" then
			action = " hands over a piece of foil."
		elseif outcome == "freeroll" then
			action = " doesn't eat."
		elseif outcome == "freeroll_sad" then
			action = " cannot find appropriate cutlery."
		elseif outcome == "overwrite_sad" then
			action = " takes a bite."
		elseif outcome == "sad" then
			action = " gracefully declines the offer."
		elseif outcome == "apathy" then
			action = " discards it."
		elseif outcome == "jackpot" then
			action = " gives up a penny."
		elseif outcome == "bigjackpot" then
			action = " hands over a shiny pebble."
		elseif outcome == "share" then
			action = " donates to less fortunate pets."
		elseif outcome == "jackpotfail" then
			action = " chews thoroughly."
		elseif outcome == "blackheart" then
			action = " is out of foil and pebbles."
		elseif outcome == "blackheart_passed" then
			action = " is still."
		elseif outcome == "blackheart_not_passed" then
			action = " is busy."
		end
	elseif personality == "f" then -- Lazy/Cuddly
		if outcome == "happy" then
			action = " jiggles over."
		elseif outcome == "happy_upgrade" then
			action = " swallows it whole."
		elseif outcome == "freeroll" then
			action = " appears to be sleeping."
		elseif outcome == "freeroll_sad" then
			action = " has a tummy-ache."
		elseif outcome == "overwrite_sad" then
			action = " gives a few licks."
		elseif outcome == "sad" then
			action = " yawns."
		elseif outcome == "apathy" then
			action = " nudges it a little."
		elseif outcome == "jackpot" then
			action = " swallows it whole."
		elseif outcome == "bigjackpot" then
			action = " just wants to cuddle."
		elseif outcome == "share" then
			action = " dosen't take first dibs."
		elseif outcome == "jackpotfail" then
			action = " pounces, face first."
		elseif outcome == "blackheart" then
			action = " is fed up."
		elseif outcome == "blackheart_passed" then
			action = " flips over."
		elseif outcome == "blackheart_not_passed" then
			action = " refuses to budge."
		end
	elseif personality == "g" then -- Polite/Reserved
		if outcome == "happy" then
			action = " gives it a nibble."
		elseif outcome == "happy_upgrade" then
			action = " appreciates the gesture."
		elseif outcome == "freeroll" then
			action = " returns it untouched."
		elseif outcome == "freeroll_sad" then
			action = " has already eaten, sorry."
		elseif outcome == "overwrite_sad" then
			action = " is okay, thanks."
		elseif outcome == "sad" then
			action = " apologizes profusely."
		elseif outcome == "apathy" then
			action = " looks around."
		elseif outcome == "jackpot" then
			action = " is thankful."
		elseif outcome == "bigjackpot" then
			action = " gives a blessing."
		elseif outcome == "share" then
			action = " passes to others."
		elseif outcome == "jackpotfail" then
			action = " requests a napkin."
		elseif outcome == "blackheart" then
			action = " emits a strange smell."
		elseif outcome == "blackheart_passed" then
			action = " giggles."
		elseif outcome == "blackheart_not_passed" then
			action = " shies away."
		end
	elseif personality == "h" then -- Fearful
		if outcome == "happy" then
			action = " skitters away with it"
		elseif outcome == "happy_upgrade" then
			action = " picks it up for later."
		elseif outcome == "freeroll" then
			action = " runs away."
		elseif outcome == "freeroll_sad" then
			action = " jumps up, startled."
		elseif outcome == "overwrite_sad" then
			action = " looks around."
		elseif outcome == "sad" then
			action = " is startled."
		elseif outcome == "apathy" then
			action = " is cautious to approach."
		elseif outcome == "jackpot" then
			action = " holds onto it tightly."
		elseif outcome == "bigjackpot" then
			action = " has found the one."
		elseif outcome == "share" then
			action = " takes just a nibble."
		elseif outcome == "jackpotfail" then
			action = " scurries away with it."
		elseif outcome == "blackheart" then
			action = " has had enough."
		elseif outcome == "blackheart_passed" then
			action = " considers it."
		elseif outcome == "blackheart_not_passed" then
			action = " is hiding away."
		end
	elseif personality == "i" then -- wicked/rogue
		if outcome == "happy" then
			action = " snatches and runs."
		elseif outcome == "happy_upgrade" then
			action = " rips it to pieces."
		elseif outcome == "freeroll" then
			action = " is already holding another treat."
		elseif outcome == "freeroll_sad" then
			action = " curses."
		elseif outcome == "overwrite_sad" then
			action = " throws it away."
		elseif outcome == "sad" then
			action = " ."
		elseif outcome == "apathy" then
			action = " is nowhere to be seen."
		elseif outcome == "jackpot" then
			action = " taunts nearby pets."
		elseif outcome == "bigjackpot" then
			action = " does an evil laugh."
		elseif outcome == "share" then
			action = " swindles a couple more."
		elseif outcome == "jackpotfail" then
			action = " eagerly awaits."
		elseif outcome == "blackheart" then
			action = " falls ill."
		elseif outcome == "blackheart_passed" then
			action = " has learned nothing."
		elseif outcome == "blackheart_not_passed" then
			action = " cannot eat."
		end
	elseif personality == "j" then -- Strange
		if outcome == "happy" then
			action = " mumbles inaudibly."
		elseif outcome == "happy_upgrade" then
			action = " burries it into the ground."
		elseif outcome == "freeroll" then
			action = " takes it and hands it back."
		elseif outcome == "freeroll_sad" then
			action = " stares at it."
		elseif outcome == "overwrite_sad" then
			action = " thinks about it."
		elseif outcome == "sad" then
			action = " is nowhere to be seen."
		elseif outcome == "apathy" then
			action = " spaces out."
		elseif outcome == "jackpot" then
			action = " snickers, heh-he."
		elseif outcome == "bigjackpot" then
			action = " gets all emotional."
		elseif outcome == "share" then
			action = " takes a bite and passes it along."
		elseif outcome == "jackpotfail" then
			action = " mumbles inaudibily."
		elseif outcome == "blackheart" then
			action = " moves away."
		elseif outcome == "blackheart_passed" then
			action = " comes closer."
		elseif outcome == "blackheart_not_passed" then
			action = " slips away again."
		end
	elseif personality == "y" then -- Neutral/Default
		if outcome == "happy" then -- baseline
			action = " shifts from side to side."
		elseif outcome == "happy_upgrade" then -- amplified baseline
			action = " appears satisfied."
		elseif outcome == "freeroll" then -- Flair Sad
			action = " eats nothing."
		elseif outcome == "freeroll_sad" then -- Precursor reworded
			action = " doesn't seem to notice."
		elseif outcome == "overwrite_sad" then -- Flair neutral
			action = " is inanimate."
		elseif outcome == "sad" then -- Narrative Precursor
			action = " remains inanimate!"
		elseif outcome == "apathy" then -- Flair Neutral Amplified
			action = " is inanimate..."
		elseif outcome == "jackpot" then -- Amplified Baseline reworded
			action = " seems satisfied."
		elseif outcome == "bigjackpot" then -- Flair jackpot
			action = " is clearly in love."
		elseif outcome == "share" then -- Unique Flair
			action = " leaves it for nearby pets."
		elseif outcome == "jackpotfail" then -- baseline variation
			action = " shifts up and down."
		elseif outcome == "blackheart" then -- Narrative 1
			action = " gives up."
		elseif outcome == "blackheart_passed" then -- Narrative 2
			action = " remains inanimate."
		elseif outcome == "blackheart_not_passed" then -- Narrative 3
			action = " is unresponsive."
		end
    elseif personality == "z" then -- Forthwall
		if outcome == "happy" then
				action = " is +1 happiness."
		elseif outcome == "happy_upgrade" then
				action = " gains 3x the usual happiness."
		elseif outcome == "freeroll" then
				action = " gets +1 and another roll!"
		elseif outcome == "freeroll_sad" then
				action = " loses 1 happiness."
		elseif outcome == "overwrite_sad" then
				action = " is neither happy nor unhappy."
		elseif outcome == "sad" then
				action = " loses 1 happiness."
		elseif outcome == "apathy" then
				action = " is neither happy nor unhappy."
		elseif outcome == "jackpot" then
				action = " gains 3x the usual happiness."
		elseif outcome == "bigjackpot" then
				action = " gains 10x the usual happiness!"
		elseif outcome == "share" then
				action = " spreads +1 happiness all pets in the container!"
		elseif outcome == "jackpotfail" then
				action = " is neither happy nor unhappy."
		elseif outcome == "blackheart" then
				action = " becomes immune to treats."
		elseif outcome == "blackheart_passed" then
				action = " resets to 0 happiness."
		elseif outcome == "blackheart_not_passed" then
				action = " is still immune to treats. Please try again."
		end
    end

	CCB_EMOTE_QUEUED = prefix..name..action
	PetContainerSlotButton.timer = 0
	PetContainerSlotButton.state = 0
	PetContainerSlotButton:SetScript("OnUpdate",PetContainerFrameTreatButton_DelayMessage)

end



function PetContainerFrameTreatButton_DelayMessage(self,elapsed)

	self.timer = self.timer + elapsed
		
	if self.timer > 4.2 then

		self:SetScript("OnUpdate", nil)
		SendChatMessage(CCB_EMOTE_QUEUED , "EMOTE")
		self.timer = 0
		self.state = 0
	
	end

end



function PetContainerFrameTreatButton_SetRoll(slot,change)

	local name = slot:GetName()
	local petID = CCB_CHAR_SAVE[name]
	local maxroll = PetContainerFrameTreatButton_GetMaxRoll()
	local direction
	
	if petID == nil then
		return
	end
	
	CCB_CHAR_SAVE[petID] = CCB_CHAR_SAVE[petID] + change
	
	if change > 0 then
		direction = "+"
	elseif change < 0 then 
		direction = "-"
	else 
		direction = "0"
	end
	
	if CCB_CHAR_SAVE[petID] < 1 and maxroll == 5 then -- ensure that first roll is always positive
		CCB_CHAR_SAVE[petID] = 1
	elseif CCB_CHAR_SAVE[petID] < -5 then
		CCB_CHAR_SAVE[petID] = -1000
		slot.status:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_0")
	elseif CCB_CHAR_SAVE[petID] > 500 then
		PetContainerFrameTreatButton_SetFlair(slot,CCB_CHAR_SAVE[petID])
		if direction == "+" then
			slot.status:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_green")
		elseif direction == "-" then
			slot.status:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_red")
		else
			slot.status:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_yellow")
		end
	elseif CCB_CHAR_SAVE[petID] >= maxroll then	
		CCB_CHAR_SAVE[petID] = 1000
		CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"] = CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"] + 1
		PetContainerFrameTreatButton_SetFlair(slot,CCB_CHAR_SAVE[petID])
		slot.status:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_green")
	elseif change == 1 then
		slot.status:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_3")
	elseif change == 0 then
		slot.status:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_2")
	elseif change == -1 then
		slot.status:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_1")
	elseif change > 2 then
		slot.status:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_4")
	end	
	
	slot.status.Pulse:Play()
	
end

function PetContainerFrameTreatButton_SetFlair(slot,roll,outcome)

	local t1 = 1000
	local t2 = 1020
	local t3 = 1080
	local t4 = 1200
	
	if roll < t2 then
		slot.flair:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_5")
	elseif roll < t3 then 
		slot.flair:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_6")
	elseif roll < t4 then
		slot.flair:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_7")
	else
		slot.flair:SetTexture("Interface\\AddOns\\ccBags\\Textures\\emotion_8")
	end

	slot.flair.Pulse:Play()

end

function PetContainerFrameTreatButton_GetMaxRoll()

	if CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"] == nil then
		CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"] = 0
		return 7
	elseif CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"] <= 5 then
		return CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"] + 7
	elseif CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"] <= 20 then
		return math.floor((CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"]*0.5) + 10)
	elseif CCB_ACCOUNT_SAVE["NUM_OF_HEARTS"] > 20 then
		return 20
	end	
	
end
	
-- Revive
function PetContainerFrameReviveButton_PostClick(self, button)
	local startTime, duration, enable = GetSpellCooldown(125439)
	CooldownFrame_Set(self.Cooldown, startTime, duration, enable)
end

function PetContainerFrameReviveButton_PreClick(self, button)
end



--battlemode functions


function PetContainerFrameBattleButton_PreClick(self, button)
	
	ContainerMicroButton_ToggleCheck(self)
	
--[[
	0 = neutral
	-1 = neutral /w encounter
	
	1 = free battle
	2 = unfinished encounter
	3 = reward
]]

	local button = PetContainerFrameBattleButton
	local frame = PetContainerFrame
	
	
	if CCB_PETCONTAINER_STATE == 0 then
	
		frame:SetScript("OnUpdate", PetContainerFrame_LoadBattleMode)
		CCB_PETCONTAINER_STATE = 1
	
	elseif CCB_PETCONTAINER_STATE == 1 then
		
		frame:SetScript("OnUpdate", PetContainerFrame_LoadNormalMode)
		CCB_PETCONTAINER_STATE = 0
	end
	
	
	
	CooldownFrame_Set(button.Cooldown,GetTime(),1.5,1)
end




function PetContainerFrame_TakeBattlepetLoadout()


	for i=1,3 do
		local loadoutPlate = PetJournal.Loadout["Pet"..i];
		local containerPlate = _G["PetContainerFrameBattleItem"..i]
		local name = containerPlate:GetName()
		local petID, ability1ID, ability2ID, ability3ID, locked = C_PetJournal.GetPetLoadOutInfo(i);
		
		if CCB_CHAR_SAVE[name] ~= petID then
			if containerPlate:IsShown() and containerPlate:GetScript("OnUpdate") == nil and PetContainerFrame:IsShown() then
				containerPlate:SetScript("OnUpdate", PetContainerFrame_TakeBattlepetLoadoutAnimation)
			elseif ( containerPlate:IsShown() == false or PetContainerFrame:IsShown() == false ) and PetContainerFrameBattleButton.disabled == false then
				CCB_CHAR_SAVE[name] = petID
				PetContainerBattleSlot_UpdateStatus(containerPlate)
				CollectionsContainerButton_Update(containerPlate)
			end
		end
	end

end


function PetContainerFrame_TakeBattlepetLoadoutAnimation(self,elapsed)

	if self.timer == nil then
		self.timer = 0
	end

	if self.state == nil then
		self.state = 0
	end
	
	self.timer = self.timer + elapsed
	
	if self.timer >= 0.15 and self.state == 0 then
		self.state = 1
		self.icon:SetDesaturated(1)
		self.level:SetTextColor(1, 0.82, 0)
		self.qualityBorder:SetAlpha(0.1)
		self:SetHighlightTexture(nil)
		ccBattlePetTooltip:Hide();
	elseif self.timer > 0.23 and self.timer < 0.59 and self.state == 1 then
		local coefficent = (self.timer - 0.23) / 0.32		
		local a = (1/2)+(1/2*coefficent)
		local slotname = self:GetName()
		local index = slotname:reverse():sub(1,1)
		local petID = C_PetJournal.GetPetLoadOutInfo(index);
		local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID)
		local r = ITEM_QUALITY_COLORS[rarity-1].r*(0.79+0.42*coefficent)
		local g = ITEM_QUALITY_COLORS[rarity-1].g*(0.79+0.42*coefficent)
		local b = ITEM_QUALITY_COLORS[rarity-1].b*(0.79+0.42*coefficent)
		self.qualityBorder:SetVertexColor(r,g,b)
		self.qualityBorder:SetAlpha(a)
		a = 1-(coefficent*(1/3))
		self.level:SetTextColor(1, 0.82, 0, a)
	elseif self.timer >= 0.63 and self.state == 1 then
		self.state = 2
		local slotname = self:GetName()
		local index = slotname:reverse():sub(1,1)
		local petID = C_PetJournal.GetPetLoadOutInfo(index);
		CCB_CHAR_SAVE[slotname] = petID
		self.icon:SetDesaturated(nil)
		self.level:SetTextColor(1, 0.82, 0, 1.0)
		PetContainerBattleSlot_UpdateStatus(self)
		CollectionsContainerButton_Update(self)	
		self.qualityBorder:SetAlpha(1)
	elseif self.timer >= 0.8 and self.state == 2 then
		self:SetScript("OnUpdate", nil)
		self.state = 0
		self.timer = 0
		self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD")
		if self:IsMouseOver() then
			ccBattlePetTooltip_Attach(ccBattlePetTooltip, "BOTTOMRIGHT", self, "TOPLEFT", 10, 5);
			ccBattlePetUnitTooltip_UpdateForUnit(ccBattlePetTooltip,self.slot);
			ccBattlePetTooltip:Show();
		end
		
	end

end


function PetContainerFrame_SetBattlepetLoadout()

	for i=1,3 do
        local containerPlate = _G["PetContainerFrameBattleItem"..i]
        local name = containerPlate:GetName()
        local petID = CCB_CHAR_SAVE[name]
        local oldPetID = C_PetJournal.GetPetLoadOutInfo(i);
		
		if petID ~= oldPetID then
		
			C_PetJournal.SetPetLoadOutInfo(i, petID)
			
			if containerPlate:IsShown() and containerPlate:GetScript("OnUpdate") == nil then
				containerPlate:SetScript("OnUpdate", PetContainerFrame_TakeBattlepetLoadoutAnimation)
			
			end
		end
   	end
   	
   	PetJournal_UpdatePetLoadOut()

end

function PetContainerFrame_LoadBattleMode(self,elapsed)

	 self.timer = self.timer + elapsed

	if self.timer >= 0.27 and self.state == 0 then
		self.state = 1
		
		PetContainerFrame_TakeBattlepetLoadout()
		for i=1,3 do
			local slot = _G["PetContainerFrameItem"..i]
			slot.icon:SetDesaturated(1)
 		end
 				
 		PetContainerFrameTreatButton.icon:SetDesaturated(true)

	
	elseif self.timer >= 0.54 and self.state == 1 then
		self:SetScript("OnUpdate", nil)
		self.state = 0
		self.timer = 0
		
		for i=1,3 do
			local slot = _G["PetContainerFrameBattleItem"..i]
			PetContainerBattleSlot_UpdateStatus(slot)
			slot.icon:SetDesaturated(nil)
			slot:Show()
		end
		
		for i=1,3 do
			local slot = _G["PetContainerFrameItem"..i]
			slot:Hide()
 		end
 		
 		PetContainerFrameReviveButton.icon:SetDesaturated(nil)
		PetContainerFrameReviveButton:Show()
		PetContainerFrameTreatButton:Hide()
		
	end

end


function PetContainerFrame_LoadNormalMode(self,elapsed)

	self.timer = self.timer + elapsed
	if self.timer >= 0.27 and self.state == 0 then
		self.state = 1

		for i=1,3 do
			local slot = _G["PetContainerFrameBattleItem"..i]
			slot.icon:SetDesaturated(1)
			slot.level:SetTextColor(0.5, 0.5, 0.5)
			slot.qualityBorder:SetVertexColor(1/3,1/3,1/3)
			slot.levelBG:SetDesaturated(1)
		end
		PetContainerFrameReviveButton.icon:SetDesaturated(true)

	elseif self.timer >= 0.54 and self.state == 1 then
		self:SetScript("OnUpdate", nil)
		self.state = 0
		self.timer = 0

		for i=1,3 do
			local slot = _G["PetContainerFrameBattleItem"..i]
			slot.icon:SetDesaturated(nil)
			slot.level:SetTextColor(1, 0.82, 0, 1.0)
			slot.levelBG:SetDesaturated(nil)
			slot:Hide()
		end
		
		for i=1,3 do
			local slot = _G["PetContainerFrameItem"..i]
			slot.icon:SetDesaturated(nil)
			slot:Show()
		end
		
		
		PetContainerFrameTreatButton.icon:SetDesaturated(nil)
		PetContainerFrameTreatButton:Show()
		PetContainerFrameReviveButton:Hide()
		CollectionsContainerFrame_Update(self)
	end

end

function PetContainerBattleSlot_UpdateStatus(slot)
	
	local name = slot:GetName()
	local index = CCB_CHAR_SAVE[name]
	local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(index)
	local speciesID, customName, level, xp, maxXp, displayID, isFavorite, petName, petIcon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = C_PetJournal.GetPetInfoByPetID(index);
	slot.qualityBorder:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b)
	slot.icon:SetTexture(petIcon)
	slot.level:SetText(level)

	if health == 0 then
		slot.isDead:Show()
	else
		slot.isDead:Hide()
	end
	
end


function PetContainerBattleButton_PreClick(self, button)

	local parent = self:GetParent()
	local kind = parent.tag
	local name = self:GetName()

	if InCombatLockdown() then
		UIErrorsFrame:AddMessage("Cannot access this container while you are in combat.", 1.0, 0.1, 0.1, 1.0);
		return false
	end

	local olditem = CCB_CHAR_SAVE[name];
	local newitem = C_GetCursorIndex(kind)
	
	if self:GetScript("OnUpdate") ~= nil then
		return
	end

	if button == "LeftButton" then
	
		if newitem == false then
			local error = "That slot is reserved for Battle Pets in your collection"
			UIErrorsFrame:AddMessage(error, 1.0, 0.1, 0.1, 1.0);
			return false
		end
		
		if newitem then
			local speciesID, customName, level, xp, maxXp, displayID, isFavorite, petName, petIcon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = C_PetJournal.GetPetInfoByPetID(newitem)
			if canBattle ~= true then
				newitem = false
			end
		end

		if newitem == false then
			local error = "That slot is reserved for Battle Pets"
			UIErrorsFrame:AddMessage(error, 1.0, 0.1, 0.1, 1.0);
			return false
	
		elseif ( newitem == nil and olditem == nil ) then

			return false

		elseif ( newitem == nil and olditem ) then

			if ( IsModifiedClick("CHATLINK") ) then
				if ( MacroFrame and MacroFrame:IsShown() ) then
					local name = C_GetChatNameByIndex(kind, olditem);
					ChatEdit_InsertLink(name);
				else
					local link = C_GetChatLinkByIndex(kind, olditem)
					ChatEdit_InsertLink(link);
				end
			else
				C_PickupItem(kind, olditem)
				CCB_BP_TEMPORARY_PICKUP = self
				self.icon:SetDesaturated(0.5)
				self.level:SetTextColor(1, 1, 1, 0.75)
			end

		elseif ( newitem and olditem == nil ) then
			--battle pet slot shouldn't ever be empty
			return false
					
		elseif ( newitem and olditem ) then

			--duplicate check			
			for i=1,3 do
       			local slot = _G["PetContainerFrameBattleItem"..i]
       			local slotname = slot:GetName()
       			local petID = CCB_CHAR_SAVE[slotname]
       			
       			if name ~= slotname and slot ~= CCB_BP_TEMPORARY_PICKUP then
       				if newitem == petID then
       					CCB_BP_TEMPORARY_PICKUP = slot
       				end
       			end
   			end
			
			CCB_CHAR_SAVE[name] = newitem
			local newicon = C_GetItemIconByIndex(kind, newitem)
			self.icon:SetDesaturated(nil);

			if ( CCB_BP_TEMPORARY_PICKUP ~= nil ) then

				local oldicon = C_GetItemIconByIndex(kind, olditem)
				local tempname = CCB_BP_TEMPORARY_PICKUP:GetName()
				
				CCB_CHAR_SAVE[tempname] = olditem
				CCB_BP_TEMPORARY_PICKUP.icon:SetDesaturated(nil)	
				CCB_BP_TEMPORARY_PICKUP.level:SetTextColor(1, 0.82, 0, 1)
				CCB_BP_TEMPORARY_PICKUP = nil
				ClearCursor();
			else 
				ClearCursor();
				C_PickupItem(kind, olditem)
			end


		end
		--CollectionsContainerFrame_Update(self:GetParent())
		PetContainerFrame_SetBattlepetLoadout()
	
	elseif button == "RightButton" then
		--do nothing for now
		return
	end
end



--------------------------------------------
------------ Battle Pet Tooltips -----------
--------------------------------------------

local MAX_PET_LEVEL = 25

function ccBattlePetTooltip_OnLoad(self)
	self.healthBarWidth = 215;
	self.xpBarWidth = 215;
	self.healthTextFormat = PET_BATTLE_HEALTH_VERBOSE;
	self.xpTextFormat = PET_BATTLE_CURRENT_XP_FORMAT_VERBOSE;
	PetBattleUnitFrame_OnLoad(self);

	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

function ccBattlePetUnitTooltip_UpdateForUnit(self, loadoutIndex)

	local petID, abilityloadout1, abilityloadout2, abilityloadout3, locked = C_PetJournal.GetPetLoadOutInfo(loadoutIndex);
	self.ability = {}
	self.ability[1] = abilityloadout1 
	self.ability[2] = abilityloadout2
	self.ability[3] = abilityloadout3
	local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID,loadoutIndex)
	local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique = C_PetJournal.GetPetInfoByPetID(petID);

	local height = 152;
	
	self.AttackAmount:SetText(attack);
	self.SpeedAmount:SetText(speed);
		
	self.Name:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);

	self.HealthText:SetFormattedText(self.healthTextFormat or PET_BATTLE_CURRENT_HEALTH_FORMAT, health, maxHealth);
	if ( health == 0 ) then
		self.ActualHealthBar:Hide();
	else
		self.ActualHealthBar:Show();
	end
	self.ActualHealthBar:SetWidth((health / max(maxHealth,1)) * self.healthBarWidth);
	self.PetType.Icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType]);

	self.Name:SetText(name);
	if string.len(name) > 18 then
		self.Name:SetPoint("TOP",self.PetType,"TOP",102,0)
	else
		self.Name:SetPoint("TOP",self.PetType,"TOP",102,-7)
	end
	
	if ( level < MAX_PET_LEVEL ) then
		--Add the XP bar
		self.XPBar:Show();
		self.XPBG:Show();
		self.XPBorder:Show();
		self.XPText:Show();
		self.XPBar:SetWidth(max((xp / max(maxXp,1)) * self.xpBarWidth, 1));
		self.XPText:SetFormattedText(self.xpTextFormat or PET_BATTLE_CURRENT_XP_FORMAT, xp, maxXp);
		height = height + 18;
	else
		--Remove the XP bar
		self.XPBar:Hide();
		self.XPBG:Hide();
		self.XPBorder:Hide();
		self.XPText:Hide();
	end


	--Show and update abilities
	self.AbilitiesLabel:Show();
	self.abilityLevels = {}
	self.abilities = {}
	
	C_PetJournal.GetPetAbilityList(speciesID, self.abilities, self.abilityLevels)

	local numUsableAbilities = 0;
	
	for j=1, #self.abilityLevels do
		if ( self.abilityLevels[j] and level >= self.abilityLevels[j] ) then
			numUsableAbilities = numUsableAbilities + 1;
		end
	end
	
	if numUsableAbilities > 3 then
		numUsableAbilities = 3
	end
	
	if numUsableAbilities == 3 then
		height = height + 31
	end


	for i=1, 3 do
		local id = self.ability[i]
		
		local id, name, icon, petType, nostrongweakhint = C_PetBattles.GetAbilityInfoByID(id)
		local abilityIcon = self["AbilityIcon"..i];
		local abilityName = self["AbilityName"..i];
		if ( i <= numUsableAbilities ) then
			abilityName:SetText(name);
			abilityIcon:SetTexture(icon)
			abilityIcon:Show();
			abilityName:Show();
		else
			abilityName:SetText("");
			abilityIcon:SetTexture(nil)
			abilityIcon:Hide();
			abilityName:Hide();
		end
	end
	
	self:SetHeight(height);
end

function ccBattlePetTooltip_Attach(self, point, frame, relativePoint, xOffset, yOffset)
	self:SetParent(frame);
	self:SetFrameStrata("TOOLTIP");
	self:ClearAllPoints();
	self:SetPoint(point, frame, relativePoint, xOffset, yOffset);
end