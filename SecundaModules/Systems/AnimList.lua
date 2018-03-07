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
		if inputText and string.len(inputText) > 0 then
      print("play animation " .. inputText .. " for " .. tostring(user))
			for i = 0, 2 do
				user.pl:SendAnimationEvent(inputText)
			end
		end
	end
  return true
end

function AnimList.OnUserChatCommand(user, cmdtext)
  if cmdtext == "/animlist" then
		user:ShowDialog(DialogAnimList01, "List", "�������� ��������", "������\n������ �� ������\n����� 1\n����� 2\n��������\n����� �������\n��������� �����\n�������� ������", 0)
		user:SendChatMessage(Theme.tip .. "����������� ������� " .. Theme.sel .. "/stop, " .. "#FFFFFF" .. Theme.tip .. "����� ���������� ��������");
	end
  if cmdtext == "/stop" then
    user:SendChatMessage(Theme.success .. "�������� �����������")
    user.pl:SendAnimationEvent("idlestop")
  end
  return true
end

return AnimList