PrioritiesDB = {}
local function classPriorities()
	local self = {}
	local f, e = CreateFrame("Frame"), {}
	local vars = {}
	local timer = 0
	local CYCLE_TIME = .05
	vars.spellQueue = .2
	vars.friendlyRangeCheck = "Flash of Light"
	vars.spellCasting = ""
	vars.spellTarget = ""
	vars.timeSnap = 0
	vars.jumping = vars.timeSnap
	vars.priority = {}
	vars.priority.spell = "Holy Shock"
	vars.priority.unit = "player"
	vars.priority.raidFrame = ""
	vars.aoeCount1 = 0
	vars.cds = {}
	
	vars.buildLines = function(args)
		args.var = args.frame:CreateFontString(nil, "TOOLTIP", "GameTooltipText")
		args.var:SetText(args.text)
		args.var:SetPoint("TOPLEFT", args.left,args.top)
		args.var:SetTextColor(1.0,1.0,1.0,0.8)
		args.var:SetFont("Fonts\\FRIZQT__.TTF", 12, "THICKOUTLINE")
	end
	
	vars.buildFrames = function(args)
		args.var.frame = CreateFrame("Frame", tostring(args.var)..".frame", UIParent)
		args.var.frame:SetFrameStrata("HIGH")
		args.var.frame:SetWidth(args.width)
		args.var.frame:SetHeight(args.height)
		args.var.texture = args.var.frame:CreateTexture(nil,"OVERLAY ")
		args.var.texture:SetAllPoints(args.var.frame)	
		args.var.frame.texture = args.var.texture
		args.var.frame:SetPoint("CENTER", 0, 100)
		args.var.frame:Hide()
		args.var.frame:SetFrameLevel(7)
		args.var.texture:SetColorTexture(0,0,0,1)		
		
		args.var.closeButton = CreateFrame("Button", nil, args.var.frame, "UIPanelButtonTemplate")
		args.var.closeButton.parent = args.var.frame
		args.var.closeButton:SetPoint("TOPLEFT", 980, 0)
		args.var.closeButton:SetWidth(20)
		args.var.closeButton:SetHeight(20) 
		args.var.closeButton:SetText("X")
		args.var.closeButton:SetScript("OnClick", function(self, button, down)
			self.parent:Hide()
		end)
	end	
	vars.buildFields = function(args)
		-- create args.var outside and pass it to the function to make it referenceable later
		args.var:SetPoint("TOPLEFT", args.left, args.top)
		args.var:SetWidth(args.width) 
		args.var:SetHeight(13) 
		args.var:SetAlpha(1.0)
		args.var:SetNumber(args.defaultval)
		args.var:EnableKeyboard(false)
		args.var.step = args.step
		args.var.minval = args.minval
		args.var.maxval = args.maxval
		args.var:SetScript("OnMouseWheel", function(self, delta)
			self:SetText(math.floor(self:GetNumber()+delta*self.step))
			if self:GetNumber() > self.maxval then
				self:SetText(self.maxval)
			elseif self:GetNumber() < self.minval then
				self:SetText(self.minval)
			end
		end)
	end
	vars.prioritySpellIcon = {}
	vars.prioritySpellIcon.frame = CreateFrame("Frame", "vars.prioritySpellIcon", UIParent)
	vars.prioritySpellIcon.frame:SetFrameStrata("HIGH")
	vars.prioritySpellIcon.frame:SetWidth(24)
	vars.prioritySpellIcon.frame:SetHeight(24)
	vars.prioritySpellIcon.texture = vars.prioritySpellIcon.frame:CreateTexture(nil,"OVERLAY ")
	vars.prioritySpellIcon.texture:SetAllPoints(vars.prioritySpellIcon.frame)	
	vars.prioritySpellIcon.frame.texture = vars.prioritySpellIcon.texture
	vars.prioritySpellIcon.frame:SetPoint("BOTTOMLEFT", 0, 0)
	vars.prioritySpellIcon.frame:Show()
	vars.prioritySpellIcon.frame:SetFrameLevel(7)
	vars.prioritySpellIcon.texture:SetTexture(GetSpellTexture(spellID))
		
	vars.options = {}
	
	--monk options
	vars.options.Monk = {}
	--monk mistweaver options
	vars.options.Monk[2] = {}
	vars.buildFrames({var = vars.options.Monk[2], width = 1000, height = 500})
	
	vars.options.Monk[2].lines = {}
	-- Cocoon
	vars.options.Monk[2].lines[1] = {}
	vars.buildLines({var = vars.options.Monk[2].lines[1].text1, frame = vars.options.Monk[2].frame, text = "Life Cocoon if priority unit's health is below", left = 10, top = -30})
	
	vars.options.Monk[2].lines[1].healthPerc = CreateFrame("EditBox", "vars.options.Monk[2].lines[1].healthPerc", vars.options.Monk[2].frame, "InputBoxTemplate")
	vars.buildFields({var = vars.options.Monk[2].lines[1].healthPerc, frame = vars.options.Monk[2].frame, width = 30, step = 5, minval = 0, maxval = 100,defaultval = 25, top = -30, left = 350})
	
	vars.buildLines({var = vars.options.Monk[2].lines[1].text2, frame = vars.options.Monk[2].frame, text = "%.", left = 380, top = -30})
	--essence font
	vars.options.Monk[2].lines[2] = {}
	vars.buildLines({var = vars.options.Monk[2].lines[2].text1, frame = vars.options.Monk[2].frame, text = "Essence Font if at least", left = 10, top = -50})	
	
	vars.options.Monk[2].lines[2].aoeCount = CreateFrame("EditBox", "vars.options.Monk[2].lines[2].aoeCount", vars.options.Monk[2].frame, "InputBoxTemplate")
	vars.buildFields({var = vars.options.Monk[2].lines[2].aoeCount, frame = vars.options.Monk[2].frame, width = 20, step = 1, minval = 0, maxval = 40,defaultval = 5, top = -50, left = 190})
	
	vars.buildLines({var = vars.options.Monk[2].lines[2].text2, frame = vars.options.Monk[2].frame, text = "raid members are within range and below", left = 215, top = -50})
		
	vars.options.Monk[2].lines[2].aoePercent = CreateFrame("EditBox", "vars.options.Monk[2].lines[2].aoePercent", vars.options.Monk[2].frame, "InputBoxTemplate")
	vars.buildFields({var = vars.options.Monk[2].lines[2].aoePercent, frame = vars.options.Monk[2].frame, width = 30, step = 5, minval = 0, maxval = 100,defaultval = 90, top = -50, left = 525})
	
	vars.buildLines({var = vars.options.Monk[2].lines[2].text3, frame = vars.options.Monk[2].frame, text = "% health and no more than", left = 560, top = -50})	
	
	vars.options.Monk[2].lines[2].buffCount = CreateFrame("EditBox", "vars.options.Monk[2].lines[2].buffCount", vars.options.Monk[2].frame, "InputBoxTemplate")
	vars.buildFields({var = vars.options.Monk[2].lines[2].buffCount, frame = vars.options.Monk[2].frame, width = 20, step = 1, minval = 0, maxval = 40,defaultval = 2, top = -50, left = 770})
	
	vars.buildLines({var = vars.options.Monk[2].lines[2].text4, frame = vars.options.Monk[2].frame, text = "raid members", left = 800, top = -70})
	
	vars.buildLines({var = vars.options.Monk[2].lines[2].text4, frame = vars.options.Monk[2].frame, text = "have the Essence font buff and I'm not moving.", left = 560, top = -70})
	
	--renewing mist
	vars.options.Monk[2].lines[3] = {}
	vars.buildLines({var = vars.options.Monk[2].lines[3].text1, frame = vars.options.Monk[2].frame, text = "Renewing Mist if priority unit doesn't have the renewing mist buff and their health is below", left = 10, top = -90})
	
	vars.options.Monk[2].lines[3].healthPerc = CreateFrame("EditBox", "vars.options.Monk[2].lines[3].healthPerc", vars.options.Monk[2].frame, "InputBoxTemplate")
	vars.buildFields({var = vars.options.Monk[2].lines[3].healthPerc, frame = vars.options.Monk[2].frame, width = 30, step = 5, minval = 0, maxval = 100,defaultval = 90, top = -90, left = 700})
	
	vars.buildLines({var = vars.options.Monk[2].lines[3].text2, frame = vars.options.Monk[2].frame, text = "%.", left = 735, top = -90})
	--Enveloping Mist
	vars.options.Monk[2].lines[4] = {}
	vars.buildLines({var = vars.options.Monk[2].lines[3].text1, frame = vars.options.Monk[2].frame, text = "Enveloption Mist if priority unit doesn't have the enveloping mist buff and their health is below", left = 10, top = -110})
	
	vars.options.Monk[2].lines[4].healthPerc = CreateFrame("EditBox", "vars.options.Monk[2].lines[4].healthPerc", vars.options.Monk[2].frame, "InputBoxTemplate")
	vars.buildFields({var = vars.options.Monk[2].lines[4].healthPerc, frame = vars.options.Monk[2].frame, width = 30, step = 5, minval = 0, maxval = 100,defaultval = 90, top = -110, left = 730})
	
	vars.buildLines({var = vars.options.Monk[2].lines[4].text2, frame = vars.options.Monk[2].frame, text = "% and you are not moving or", left = 765, top = -110})
	
	vars.buildLines({var = vars.options.Monk[2].lines[4].text3, frame = vars.options.Monk[2].frame, text = "you have the thunder focus tea buff.", left = 560, top = -130})
	
	--vivify
	vars.options.Monk[2].lines[5] = {}
	vars.buildLines({var = vars.options.Monk[2].lines[5].text1, frame = vars.options.Monk[2].frame, text = "Vivify if priority unit's health is below", left = 10, top = -150})
	
	vars.options.Monk[2].lines[5].healthPerc = CreateFrame("EditBox", "vars.options.Monk[2].lines[5].healthPerc", vars.options.Monk[2].frame, "InputBoxTemplate")
	vars.buildFields({var = vars.options.Monk[2].lines[5].healthPerc, frame = vars.options.Monk[2].frame, width = 30, step = 5, minval = 0, maxval = 100,defaultval = 70, top = -150, left = 300})
	
	vars.buildLines({var = vars.options.Monk[2].lines[5].text2, frame = vars.options.Monk[2].frame, text = "% and you are not moving and there are at least ", left = 335, top = -150})
	
	vars.options.Monk[2].lines[5].aoeCount = CreateFrame("EditBox", "vars.options.Monk[2].lines[5].healthPerc", vars.options.Monk[2].frame, "InputBoxTemplate")
	vars.buildFields({var = vars.options.Monk[2].lines[5].aoeCount, frame = vars.options.Monk[2].frame, width = 20, step = 1, minval = 0, maxval = 40,defaultval = 2, top = -150, left = 700})
	
	vars.buildLines({var = vars.options.Monk[2].lines[5].text3, frame = vars.options.Monk[2].frame, text = "other raid member below ", left = 725, top = -150})
	
	vars.options.Monk[2].lines[5].aoePercent = CreateFrame("EditBox", "vars.options.Monk[2].lines[5].aoePercent", vars.options.Monk[2].frame, "InputBoxTemplate")
	vars.buildFields({var = vars.options.Monk[2].lines[5].aoePercent, frame = vars.options.Monk[2].frame, width = 30, step = 5, minval = 0, maxval = 100,defaultval = 90, top = -150, left = 915})
	
	vars.buildLines({var = vars.options.Monk[2].lines[5].text4, frame = vars.options.Monk[2].frame, text = "%", left = 950, top = -150})
	
	vars.buildLines({var = vars.options.Monk[2].lines[5].text5, frame = vars.options.Monk[2].frame, text = "health or I have the uplifting trance buff.", left = 560, top = -170})
	
	--Effuse	
		-- elseif spellCD("Effuse") <= vars.timeToAct and vars.priority.healthPercentInc < vars.options.Monk[2].lines[6].healthPerc:GetNumber()/100 and not vars.isMoving("player") then
	vars.options.Monk[2].lines[6] = {}
	vars.buildLines({var = vars.options.Monk[2].lines[6].text1, frame = vars.options.Monk[2].frame, text = "Effuse if priority unit's health is below", left = 10, top = -190})
	
	vars.options.Monk[2].lines[6].healthPerc = CreateFrame("EditBox", "vars.options.Monk[2].lines[6].healthPerc", vars.options.Monk[2].frame, "InputBoxTemplate")
	vars.buildFields({var = vars.options.Monk[2].lines[6].healthPerc, frame = vars.options.Monk[2].frame, width = 30, step = 5, minval = 0, maxval = 100,defaultval = 90, top = -190, left = 310})
	
	vars.buildLines({var = vars.options.Monk[2].lines[6].text2, frame = vars.options.Monk[2].frame, text = "%.", left = 345, top = -190})	
	
	vars.options.Monk[2].lines[7] = {}
	vars.buildLines({var = vars.options.Monk[2].lines[7].text1, frame = vars.options.Monk[2].frame, text = "When in melee range Tiger Palm until you have three stacks of Teachings of the Monastery.", left = 10, top = -210})	
	
	vars.options.Monk[2].lines[8] = {}
	vars.buildLines({var = vars.options.Monk[2].lines[8].text1, frame = vars.options.Monk[2].frame, text = "When in melee range of your target Rising Sun Kick.", left = 10, top = -230})	
	
	vars.options.Monk[2].lines[9] = {}
	vars.buildLines({var = vars.options.Monk[2].lines[9].text1, frame = vars.options.Monk[2].frame, text = "When in melee range of your target Blackout Kick.", left = 10, top = -250})
	
	vars.options.Monk[2].lines[9] = {}
	vars.buildLines({var = vars.options.Monk[2].lines[9].text1, frame = vars.options.Monk[2].frame, text = "When in range of your target Crackling Jade Lightning.", left = 10, top = -270})
	
	vars.options.Monk[2].lines[10] = {}
	vars.buildLines({var = vars.options.Monk[2].lines[9].text1, frame = vars.options.Monk[2].frame, text = "Sheilun's Gift when it has at least 4 stacks and a non crit wont have any overhealing.", left = 10, top = -10})
	local function distanceBetweenUs(unit1, unit2)
		local result = 999
		local y1, x1, _, instance1 = UnitPosition(unit1)
		local y2, x2, _, instance2 = UnitPosition(unit2)
		--x1 = nil
		if x1 ~= nil and x2 ~= nil then
			result = ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
		else
			if unit1 == "player" then
				if IsItemInRange(37727, unit2) then
					result = 5
				elseif IsItemInRange(63427, unit2) then
					result = 6
				elseif IsItemInRange(34368, unit2) then
					result = 8
				elseif IsItemInRange(32321, unit2) then
					result = 10
				elseif IsItemInRange(1251, unit2) or IsItemInRange(33069, unit2) then
					result = 15
				elseif IsItemInRange(21519, unit2) then
					result = 20
				elseif IsItemInRange(31463, unit2) then
					result = 25
				elseif IsItemInRange(34191, unit2) then
					result = 30
				elseif IsItemInRange(18904, unit2) then
					result = 35
				elseif IsItemInRange(34471, unit2) then
					result = 40
				elseif IsItemInRange(32698, unit2) then
					result = 45
				elseif IsItemInRange(116139, unit2) then
					result = 50
				elseif IsItemInRange(32825, unit2) then
					result = 60
				elseif CheckInteractDistance(unit2, 2) then
					result = 8
				elseif CheckInteractDistance(unit2, 4) then
					result = 28
				end				
			end
			--print(result)
		end
		return result
	end
	local isCastableOn = function(unitID, spellName)
		local inRange, checkedRange
		if spell == nil then
			inRange, checkedRange = UnitInRange(unitID)
			if not checkedRange then
				if spellName == nil then
					inRange = IsSpellInRange(vars.friendlyRangeCheck, unitID)
				else
					inRange = IsSpellInRange(spellName, unitID)
				end
			end
		else
			inRange = IsSpellInRange(unitID, spellName)
		end
		if inRange == 1 then
			inRange = true
		elseif inRange ~= true then
			inRange = false
		end
		return inRange
	end
	local function getActionUnitID(gtype,nbr)
		local result
		if gtype == "raid" then
			result = gtype .. nbr
		else
			if nbr == 1 then
				result = "player"
			else
				result = gtype .. (nbr-1)
			end
		end
		return result
	end
	local castTimeLeft = function()	
		local result
		spellname, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("player")			
		if spellname ~= nil then
			result = (endTime - vars.timeSnap*1000)/1000
		else
			spellname, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo("player")
			--disabled channeling on soothing mist. gave crazy times.
			if spellname ~= nil and spellname ~= "Soothing Mist" then
				result = (endTime - vars.timeSnap*1000)/1000
			else
				result = 0
			end
		end
		return result
	end
	local GCDtimeLeft = function()
		local result = 999
		local start, durationc, enable = GetSpellCooldown(61304) --apparently works for all classes/levels."Flash of Light"
		-- not valid so give it a crazy cooldown.
		if durationc == nil then
			result = 999
		elseif durationc == 0 then
			result = 0
		else
			result = start + durationc - vars.timeSnap
		end
		--print(durationc,result)
		return result
	end		
	local spellCD = function(spellName)
		local result = 999
		local count = 0 --GetSpellCharges(spellName)
		local start, durationc, enable = GetSpellCooldown(spellName)
		-- not valid so give it a crazy cooldown.
		if durationc == nil then
			result = 999
		-- If the spell is on CD durationc will be the spell's CD.  otherwise it will be a GCD which is never more than 2
		elseif durationc <= 2 or count > 0 then
			result = 0
		-- otherwise return when it will be off its cd
		else
			result = start + durationc - vars.timeSnap
			if result < 0 then
				result = 0
			end
		end
		return result
	end	
	
	local spellCharges = function(spellName)
		local result = 0
		local count = GetSpellCharges(spellName)
		if count == nil then
			count = 0
		end
		result = count
		return result
	end	
	local function auraDuration(unitID, aura, filter)
		local expiresIn
		local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3 = UnitAura(unitID,aura,nil,filter)
		if expires == nil then
			expiresIn = 0 
		--spell with no duration expires = 0
		elseif expires == 0 then
			expiresIn = 999999			
		else
			expiresIn = expires - vars.timeSnap
		end
		result = expiresIn	
		return result
	end
	
	local buffCount = function(unitName,aura)
		--print(unitName,aura)
		local result = false
		local expiresIn = 0
		local f = fluff
		if f == nil then
			f = 2
		end
		--UnitAura doesnt work.
		local name, rank, icon, count, dispelType, duration, expires, caster, isStealable = UnitBuff(unitName, aura)
		if expires == nil then
			expiresIn = -1
		elseif expires == 0 then
			expiresIn = 999999
		else
			expiresIn = expires - vars.timeSnap
		end
		--print(expiresIn)
		if expiresIn <=f then	
			result = 0
		else
			result = count
		end
		--print(result)
		return result
	end
	vars.talentChosen = function(row,col,unit)
		local result = false
		local talentID, name, texture, selected, available = GetTalentInfo(row, col, 1, false, unit)
		result = selected
		return selected
	end	
	vars.isMoving = function(unitName)
		local speed = GetUnitSpeed(unitName)
		-- disabled casting while moving effects.  need to fix.
		-- if hasBuff(unitName,"Ice Floes",0) then
			-- return false
		-- else
		if speed > 0 then
			return true
		elseif (vars.timeSnap - vars.jumping) < .5 then
			return true
		else
			return false
		end		
	end
	function memberToHeal()	
		local groupCount, groupType, testUnitID, priorityHealth, priorityMaxHealth, priorityHealthDeficit, health, maxHealth, healthPercentInc, tmpInc, missingHealthInc
		groupCount = GetNumGroupMembers()
		if groupCount == 0 then
			groupCount = 1
		end
		if groupCount > 40 then
			groupCount = 40
		end
		if IsInRaid() then
			groupType = "raid"
		else
			groupType = "party"
		end
		vars.priority.healthPercentInc = 2
		vars.priority.spell = ""
		vars.priority.unit = ""
		vars.priority.raidFrame = nil
		vars.aoeCount1 = 0
		vars.aoeCount2 = 0
		vars.aoeCount3 = 0
		for i = 1, groupCount do
			testUnitID = getActionUnitID(groupType, i)
			if not UnitIsDeadOrGhost(testUnitID) and isCastableOn(testUnitID) then -- and isCastableOn(testUnitID)			
				health = UnitHealth(testUnitID)
				maxHealth = UnitHealthMax(testUnitID)
				tmpInc = UnitGetIncomingHeals(testUnitID)
				if tmpInc == nil then
					tmpInc = 0
				end
				healthInc = health + tmpInc
				if healthInc > maxHealth then
					healthInc = maxHealth
				end
				healthPercentInc = healthInc/maxHealth
				missingHealthInc = maxHealth - healthInc
				if missingHealthInc < 0 then
					missingHealthInc = 0
				end				
				-- class specific stuff
				if UnitClass("player") == "Monk" and distanceBetweenUs("player", testUnitID) <= 25 then
					if healthPercentInc < vars.options.Monk[2].lines[2].aoePercent:GetNumber()/100 then
						vars.aoeCount1 = vars.aoeCount1 + 1
					end
					if auraDuration(testUnitID,"Essence Font","HELPFUL|PLAYER") >= vars.timeToAct then
						vars.aoeCount2 = vars.aoeCount2 + 1
					end
					if healthPercentInc < vars.options.Monk[2].lines[5].aoePercent:GetNumber()/100 then
						vars.aoeCount3 = vars.aoeCount3 + 1
					end					
				elseif UnitClass("player") == "Paladin" and distanceBetweenUs("player", testUnitID) <= 15 then
					if healthPercentInc < .9 then
						vars.aoeCount1 = vars.aoeCount1 + 1
					end
				end
				
				if healthPercentInc < vars.priority.healthPercentInc then
					vars.priority.health = health
					vars.priority.maxHealth = maxHealth
					vars.priority.healthInc = healthInc
					vars.priority.healthPercentInc = healthPercentInc
					vars.priority.unitID = testUnitID
				end
				--
			end
		end
		if vars.priority.healthPercentInc == 2 then
			testUnitID = getActionUnitID(groupType, 1)
			health = UnitHealth(testUnitID)
			maxHealth = UnitHealthMax(testUnitID)
			healthInc = health + UnitGetIncomingHeals(testUnitID)
			if healthInc > maxHealth then
				healthInc = maxHealth
			end
			healthPercentInc = healthInc/maxHealth
			vars.priority.health = health
			vars.priority.maxHealth = maxHealth
			vars.priority.healthInc = healthInc
			vars.priority.healthPercentInc = healthPercentInc
			vars.priority.missingHealthInc = missingHealthInc
			vars.priority.unitID = testUnitID
		end
		if groupType == "party" then
			-- if groupCount == 1 then
				-- vars.priority.raidFrame = vars.cds[1].frame
			-- else
			if CompactUnitFrameProfilesGeneralOptionsFrameKeepGroupsTogether:GetChecked() then
				--In party keep groups together is CompactPartyFrameMemberM pets are CompactRaidFrameX
				for i = 1, 5 do
					if _G["CompactPartyFrameMember"..i] ~= nil and _G["CompactPartyFrameMember"..i].unit == vars.priority.unitID and _G["CompactPartyFrameMember"..i]:IsVisible() then
						vars.priority.raidFrame = _G["CompactPartyFrameMember"..i]
					end
				end
			else
				--In party no groups together is CompactRaidFrameX pets the same
				for i = 1, 10 do
					if _G["CompactRaidFrame"..i] ~= nil and _G["CompactRaidFrame"..i].unit == vars.priority.unitID and _G["CompactRaidFrame"..i]:IsVisible() then
						vars.priority.raidFrame = _G["CompactRaidFrame"..i]
					end
				end
			end
		else --raid
			if CompactUnitFrameProfilesGeneralOptionsFrameKeepGroupsTogether:GetChecked() then
				--In raids keep groups together is CompactRaidGroupGMemberM pets are CompactRaidFrameX
				for p = 1, 8 do
					for m = 1, 5 do
						if _G["CompactRaidGroup"..p.."Member"..m] ~= nil and _G["CompactRaidGroup"..p.."Member"..m].unit == vars.priority.unitID and _G["CompactRaidGroup"..p.."Member"..m]:IsVisible() then
							vars.priority.raidFrame = _G["CompactRaidGroup"..p.."Member"..m]
						end
					end
				end
			else
				--In raids no groups together is CompactRaidFrameX pets the same
				for m = 1, 50 do
					if _G["CompactRaidFrame"..m] ~= nil and _G["CompactRaidFrame"..m].unit == vars.priority.unitID and _G["CompactRaidFrame"..m]:IsVisible() then
						vars.priority.raidFrame = _G["CompactRaidFrame"..m]
					end
				end
			end
		end
	end
	function monkHealToUse()
		--shellun's gift
		--print(math.floor(vars.priority.healthPercent*100))
		--life cocoon
		--essence font 5 or more at 80% health or below and not thunder focus tea buff
		--renewing mist at 90% and not has renewing mist buff
		--enveloping mist at 90% if doesnt have enveloping mist buff without moving or moving with thunder focus tea
		--vivify with proc called "Uplifting Trance" 1 target without buff 3 targets 90%
		--effuse at 90%
		-- dps spells
		--melee
		--tiger palm Teachings of the Monastery x3
		--rising sun kick
		--black out kick
		--range
		--crackling jade lightning
		if spellCD("Sheilun's Gift") <= vars.timeToAct and spellCharges("Sheilun's Gift") > 3 and spellCharges("Sheilun's Gift")*100000 < vars.priority.missingHealthInc then
			vars.priority.spell = "Sheilun's Gift"
		elseif spellCD("Life Cocoon") <= vars.timeToAct and vars.priority.healthPercentInc < vars.options.Monk[2].lines[1].healthPerc:GetNumber()/100 then
			vars.priority.spell = "Life Cocoon"
		elseif spellCD("Essence Font") <= vars.timeToAct and vars.aoeCount1 >= vars.options.Monk[2].lines[2].aoeCount:GetNumber() and not vars.isMoving("player") and auraDuration("player","Thunder Focus Tea","HELPFUL") == 0 and vars.aoeCount2 <= vars.options.Monk[2].lines[2].buffCount:GetNumber() then
			vars.priority.spell = "Essence Font"
		elseif spellCD("Renewing Mist") <= vars.timeToAct and vars.spellCasting ~= "Renewing Mist" and auraDuration(vars.priority.unitID,"Renewing Mist","HELPFUL") <= vars.timeToAct and vars.priority.healthPercentInc < vars.options.Monk[2].lines[3].healthPerc:GetNumber()/100 then
			vars.priority.spell = "Renewing Mist"
		elseif spellCD("Enveloping Mist") <= vars.timeToAct and vars.spellCasting ~= "Enveloping Mist" and auraDuration(vars.priority.unitID,"Enveloping Mist","HELPFUL") <= vars.timeToAct and vars.priority.healthPercentInc < vars.options.Monk[2].lines[4].healthPerc:GetNumber()/100 and (not vars.isMoving("player") or auraDuration("player","Thunder Focus Tea","HELPFUL") > 0) then
			vars.priority.spell = "Enveloping Mist"
		elseif spellCD("Vivify") <= vars.timeToAct and vars.priority.healthPercentInc < vars.options.Monk[2].lines[5].healthPerc:GetNumber()/100 and not vars.isMoving("player") and (vars.aoeCount3 >= vars.options.Monk[2].lines[5].aoeCount:GetNumber() or (auraDuration("player","Uplifting Trance","HELPFUL") >= vars.timeToAct and vars.spellCasting ~= "Vivify")) then
			vars.priority.spell = "Vivify"
		elseif spellCD("Effuse") <= vars.timeToAct and vars.priority.healthPercentInc < vars.options.Monk[2].lines[6].healthPerc:GetNumber()/100 and not vars.isMoving("player") then
			vars.priority.spell = "Effuse"
		elseif spellCD("Tiger Palm") <= vars.timeToAct and IsSpellInRange("Tiger Palm", "target") == 1 and buffCount("player", "Teachings of the Monastery") < 3 then
			vars.priority.spell = "Tiger Palm"
		elseif spellCD("Rising Sun Kick") <= vars.timeToAct and IsSpellInRange("Rising Sun Kick", "target") == 1 then
			vars.priority.spell = "Rising Sun Kick"
		elseif spellCD("Blackout Kick") <= vars.timeToAct and IsSpellInRange("Blackout Kick", "target") == 1 then
			vars.priority.spell = "Blackout Kick"
		elseif spellCD("Crackling Jade Lightning") <= vars.timeToAct and IsSpellInRange("Crackling Jade Lightning", "target") == 1 then
			vars.priority.spell = "Crackling Jade Lightning"
		else
			vars.priority.spell = ""
		end	
	end
	function paladinHealToUse()		
		if spellCD("Light of Dawn") <= vars.timeToAct and vars.aoeCount1 >= 2 then
			vars.priority.spell = "Light of Dawn"
		elseif vars.priority.healthPercentInc == 0 then
			vars.priority.spell = ""
		elseif spellCD("Holy Shock") <= vars.timeToAct and IsSpellInRange("Holy Shock", vars.priority.unitID) == 1 and vars.priority.healthPercentInc < .9 then
			vars.priority.spell = "Holy Shock"
		elseif spellCD("Flash of Light") <= vars.timeToAct and vars.priority.healthPercentInc < .9 and not vars.isMoving("player") then
			vars.priority.spell = "Flash of Light"
		elseif spellCD("Judgment") <= vars.timeToAct and IsSpellInRange("Judgment", "target") == 1 then
			vars.priority.spell = "Judgment"
		elseif spellCD("Holy Shock") <= vars.timeToAct and IsSpellInRange("Holy Shock", "target") == 1 then
			vars.priority.spell = "Holy Shock"
		elseif spellCD("Crusader Strike") <= vars.timeToAct and IsSpellInRange("Crusader Strike", "target") == 1 then
			vars.priority.spell = "Crusader Strike"
		else
			vars.priority.spell = ""
		end
	end
	function healToUse()		
		if UnitClass("player") == "Monk" then
			if GetSpecialization() == 2 then
				vars.friendlyRangeCheck = "Vivify"
				monkHealToUse()
			end
		elseif UnitClass("player") == "Paladin" then
			if GetSpecialization() == 1 then
				vars.friendlyRangeCheck = "Flash of Light"
				paladinHealToUse()
			end
		end
	end
	function main()
		-- vars.raidframes are unitframes
		-- vars.raidframes.unit is the raidID
		if castTimeLeft() > GCDtimeLeft() then
			vars.timeToAct = castTimeLeft()
		else
			vars.timeToAct = GCDtimeLeft()
		end
		
		memberToHeal()	
		
		healToUse()
		if vars.priority.raidFrame ~= nil then
			--print(vars.priority.raidFrame:GetName())
			local left, bottom, width, height = vars.priority.raidFrame:GetRect()
			local ih = height*.6
			-- if vars.priority.raidFrame == vars.cds[1].frame then
				-- ih = 50
				-- vars.prioritySpellIcon.frame:SetWidth(ih)
				-- vars.prioritySpellIcon.frame:SetHeight(ih)
				-- vars.prioritySpellIcon.frame:SetPoint("BOTTOMLEFT", left-ih*2, bottom)
			-- else
				vars.prioritySpellIcon.frame:SetWidth(ih)
				vars.prioritySpellIcon.frame:SetHeight(ih)
				vars.prioritySpellIcon.frame:SetPoint("BOTTOMLEFT", left + width/2 - ih/2, bottom + height*.2)
			--end
		else
			--print(vars.priority.raidFrame)
		end
		local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(vars.priority.spell)
		vars.prioritySpellIcon.texture:SetTexture(GetSpellTexture(spellID))
		vars.renderCDs()
	end
	vars.renderCDs = function()		
		local left, bottom, width, height = CompactRaidFrameContainer:GetRect()
		local ih = vars.prioritySpellIcon.frame:GetWidth()
		for i = 1,#vars.cds do
			if vars.cds[i].spellName ~= "" then
				local cd = spellCD(vars.cds[i].spellName)
				local charges = spellCharges(vars.cds[i].spellName)
				local float = 0
				if cd <= 20 then
					float = (width-50)*(1-cd/20)
				end
				cd = math.ceil(cd)
				if cd > 60 then
					cd = math.ceil(cd/60)
				end
				vars.cds[i].cd:SetFont("Fonts\\FRIZQT__.TTF", math.floor(ih*.6), "THICKOUTLINE")
				if cd == 0 then				
					vars.cds[i].cd:SetText("")
				else
					vars.cds[i].cd:SetText(cd)
				end
				if charges < 2 then				
					vars.cds[i].charges:SetText("")
				else
					vars.cds[i].charges:SetText(charges)
				end
				vars.cds[i].frame:SetWidth(ih)
				vars.cds[i].frame:SetHeight(ih)
				local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(vars.cds[i].spellName)
				vars.cds[i].texture:SetTexture(GetSpellTexture(spellID))
				vars.cds[i].frame:SetPoint("BOTTOMLEFT", left + width - float, bottom + height)
				vars.cds[i].frame:Show()
				--if cd == 0 then
					left = left + ih
					width = width - ih
				--elseif cd > 20 then
					width = width - ih
				--end
			else
				vars.cds[i].frame:Hide()
			end
		end
	end
	function parseSpellCDs(cds)
		local name, rank, icon, castingTime, minRange, maxRange, spellID
		for i = 1, #cds do			
			if string.sub(cds[i], 1, 11) == "Talent Row " then
				local row = string.sub(cds[i], 12, 12)
				for h = 1,3 do
					local talentID, name, texture, selected, available, spellID, tier, row, column = GetTalentInfo(row, h, 1)
					if selected then
						if GetSpellInfo(name) == nil then
							cds[i] = ""
						else
							cds[i] = name
						end
					end
				end
			end
			if vars.cds[i] == nil then
				vars.cds[i] = {}
				vars.cds[i].frame = CreateFrame("Frame", "vars.cds["..i.."]", UIParent)
				vars.cds[i].frame:SetFrameStrata("HIGH")
				vars.cds[i].frame:SetWidth(24)
				vars.cds[i].frame:SetHeight(24)
				vars.cds[i].texture = vars.cds[i].frame:CreateTexture(nil,"OVERLAY ")
				vars.cds[i].texture:SetAllPoints(vars.cds[i].frame)	
				vars.cds[i].frame.texture = vars.cds[i].texture
				vars.cds[i].frame:SetPoint("BOTTOMLEFT", 0, 0)
				vars.cds[i].frame:Hide()
				vars.cds[i].frame:SetFrameLevel(30-i)
				vars.cds[i].texture:SetTexture(GetSpellTexture(spellID))
				vars.cds[i].cd = vars.cds[i].frame:CreateFontString(nil, "TOOLTIP", "GameTooltipText")
				vars.cds[i].cd:SetText("")
				vars.cds[i].cd:SetPoint("CENTER", 0,0)
				vars.cds[i].cd:SetTextColor(1.0,1.0,1.0,0.8)
				vars.cds[i].cd:SetFont("Fonts\\FRIZQT__.TTF", 24, "THICKOUTLINE")
				vars.cds[i].charges = vars.cds[i].frame:CreateFontString(nil, "TOOLTIP", "GameTooltipText")
				vars.cds[i].charges:SetText("")
				vars.cds[i].charges:SetPoint("BOTTOMRIGHT", 0,2)
				vars.cds[i].charges:SetTextColor(1.0,1.0,1.0,0.8)
				vars.cds[i].charges:SetFont("Fonts\\FRIZQT__.TTF", 12, "THICKOUTLINE")
				vars.cds[i].frame.spellID = 0
				vars.cds[i].frame:SetScript("OnEnter", function(self, motion)
								GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
								GameTooltip:SetSpellByID(self.spellID)
								GameTooltip:Show()
							end)			
				vars.cds[i].frame:SetScript("OnLeave", function(self, motion)
					GameTooltip:Hide()
				end)			
				vars.cds[i].frame:SetScript("OnLeave", function(self, motion)
					GameTooltip:Hide()
				end)			
				vars.cds[i].frame:SetScript("OnMouseDown", function(self, button)
					if button == "RightButton" then
						local c = UnitClass("player")
						local s = GetSpecialization()
						if vars.options[c] ~= nil then
							if vars.options[c][s] ~= nil then
								if vars.options[c][s].frame:IsShown() then
									vars.options[c][s].frame:Hide()
								else
									vars.options[c][s].frame:Show()
								end
							end
						end
					end
				end)
			end
			vars.cds[i].spellName = cds[i]
			name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(cds[i])
			vars.cds[i].frame.spellID = spellID
		end
	end
	function buildCDs()
		for i = 1,#vars.cds do
			vars.cds[i].spellName = ""
			vars.cds[i].frame.spellID = 0
			vars.cds[i].frame:Hide()
		end
		if UnitClass("player") == "Monk" then
			if GetSpecialization() == 2 then
				parseSpellCDs({"Sheilun's Gift","Renewing Mist","Thunder Focus Tea","Detox","Life Cocoon","Revival","Talent Row 7","Talent Row 6","Talent Row 5","Talent Row 4","Talent Row 1"}) --
			end
		elseif UnitClass("player") == "Paladin" then
			if GetSpecialization() == 1 then
				parseSpellCDs({"Holy Shock","Light of Dawn","Judgment","Crusader Strike","Cleanse"})--,"Judgment","Consecration","Cleanse","Divine Protection","Hammer of Justice","Avenging Wrath","Every Man for Himself","Divine Shield","Aura Mastery","Blessing of Freedom", "Blessing of Sacrifice", "Blessing of Protection","Divine Steed","Lay on Hands","Talent Row 1","Talent Row 2","Talent Row 3","Talent Row 5","Talent Row 7"})
			end
		end
	end
	function e:UNIT_SPELLCAST_SUCCEEDED(...)
		local unitID, spellName, rank, lineID, spellID = ...
	end
	function e:UNIT_SPELLCAST_START(...)
		local unitID, spellName, rank, lineID, spellID = ...
		if UnitIsUnit(unitID,"player") then
			vars.spellCasting = spellName
			vars.spellTarget = vars.priority.unitID
		end
	end	
	function e:UNIT_SPELLCAST_STOP(...)
		local unitID, spellName, rank, lineID, spellID = ...
		if UnitIsUnit(unitID,"player") then
			vars.spellCasting = ""
			vars.spellTarget = ""
		end
	end	
	function e:PLAYER_TALENT_UPDATE(...)
	    buildCDs()
	end
	function e:PLAYER_LOGIN(...)
		buildCDs()
		f:SetScript("OnUpdate", function(self, elapsed)
		  timer = timer + elapsed
		  if timer >= CYCLE_TIME then
			vars.timeSnap = GetTime()
			timer = 0
			main()
		  end
		end)
	end
	f:SetScript("OnEvent", function(self, event, ...)
		e[event](self, ...) -- call one of the functions above
	end)

	for k, v in pairs(e) do
	   f:RegisterEvent(k) -- Register all events for which handlers have been defined
	end
	local function hook_JumpOrAscendStart(...)
	   if startjump == 0 then
	     startjump = vars.timeSnap
	   end	   
	  vars.jumping = vars.timeSnap
	end
	hooksecurefunc("JumpOrAscendStart", hook_JumpOrAscendStart)
	
	return self
	
end
Priorities = classPriorities()