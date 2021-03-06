local AnimList = {}

local DialogAnimList01 = 1228228

function AnimList.OnUserDialogResponse(user, dialogID, inputText, listItem)
	if DialogAnimList01 == dialogID then
    inputText = ""
		if listItem == 0 then
			inputText = "IdleFluteStart"
		end
		if listItem == 1 then
			inputText = "IdleCiceroDance1"
		end
		if listItem == 2 then
			inputText = "IdleCiceroDance2"
		end
		if listItem == 3 then
			inputText = "IdleSitCrossleggedEnter"
		end
		if listItem == 4 then
			inputText = "IdleTake"
		end
		if listItem == 5 then
			inputText = "IdleSell"
		end
		if listItem == 6 then
			inputText = "IdleSearchingChest"
		end
		if inputText ~= "" and inputText ~= nil then
			user:SetTempVar("bAnimStarted", true)
			user:ForceThirdPerson()
			user:SetControlEnabled("CamSwitch", false)
			SetTimer(1, function() user:SetTempVar("bAnimListCamSwitchDisabled", true) end)
			for i = 0, 2 do
				user.pl:SendAnimationEvent(inputText)
			end
		end
	end
  return true
end

function AnimList.OnEvery1000ms(user)
	-- Unlock CamSwitch
	if user:GetTempVar("bAnimListCamSwitchDisabled") and user:IsRunning() then
		user:SetTempVar("bAnimListCamSwitchDisabled", false)
		user:SetControlEnabled("CamSwitch", true)
		user:SetTempVar("bAnimStarted", false)
	end

	-- Fix of FirstPerson movement in anim
	if user:GetTempVar("bAnimStarted") and user:IsFirstPerson() then
		user:SetTempVar("bAnimStarted", false)
		user:ForceThirdPerson()
		SetTimer(350, function()
			user:SendAnimationEvent("jumpfall")
			SetTimer(100, function()
				user:SendAnimationEvent("jumpland")
			end)
		end)
	end
	return true
end

function AnimList.OnUserChatCommand(user, cmdtext)
  if cmdtext == "/animlist" then
		user:ShowDialog(DialogAnimList01, "List", "???????? ????????", "?????? ?? ??????\n????? 1\n????? 2\n????????\n????? ???????\n????????? ?????\n???????? ??????", 0)
		user:SendChatMessage(Theme.tip .. "??????????? ??????? " .. Theme.sel .. "/stop, " .. "#FFFFFF" .. Theme.tip .. "????? ?????????? ????????");
	end
  if cmdtext == "/stop" then
    user:SendChatMessage(Theme.success .. "???????? ???????????")
    user.pl:SendAnimationEvent("idlestop")
  end
  return true
end

return AnimList
