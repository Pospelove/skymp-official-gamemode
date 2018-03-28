local AnimList = {}

local DialogAnimList01 = 1228228

function AnimList.OnUserDialogResponse(user, dialogID, inputText, listItem)
	if DialogAnimList01 == dialogID then
    inputText = ""
		if listItem == 1 then
			inputText = "IdleFluteStart"
		end
		if listItem == 2 then
			inputText = "IdleCiceroDance1"
		end
		if listItem == 3 then
			inputText = "IdleCiceroDance2"
		end
		if listItem == 4 then
			inputText = "IdleSitCrossleggedEnter"
		end
		if listItem == 5 then
			inputText = "IdleTake"
		end
		if listItem == 6 then
			inputText = "IdleSell"
		end
		if listItem == 7 then
			inputText = "IdleSearchingChest"
		end
		if inputText ~= "" and inputText ~= nil then
			user:SetTempVar("bAnimStarted", true)
			user:ForceThirdPerson()
			for i = 0, 2 do
				user.pl:SendAnimationEvent(inputText)
			end
		end
	end
  return true
end

function AnimList.OnEvery1000ms(user)
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
		user:ShowDialog(DialogAnimList01, "List", "Выберите анимацию", "ОТМЕНА\nИграть на флейте\nТанец 1\nТанец 2\nПрисесть\nВзять предмет\nПродавать зелье\nОбыскать сундук", 0)
		user:SendChatMessage(Theme.tip .. "Используйте команду " .. Theme.sel .. "/stop, " .. "#FFFFFF" .. Theme.tip .. "чтобы остановить анимацию");
	end
  if cmdtext == "/stop" then
    user:SendChatMessage(Theme.success .. "Анимация остановлена")
    user.pl:SendAnimationEvent("idlestop")
  end
  return true
end

return AnimList
