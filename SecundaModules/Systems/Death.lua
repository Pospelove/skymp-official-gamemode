local Death = {}

function Death.GetDelaySeconds()
  return 10
end

function Death.OnUserDying(user, killer)
	local n = Death.GetDelaySeconds()
	SetTimer(n * 1000 + 100, function()
		for i = 1, 20 do
			user:SendChatMessage(Theme.info .. "")
		end
		user:SendChatMessage(Theme.success .. "�� ���� ����������")
	end)
	for i = 1, n do
		SetTimer((n * 1000) - (i * 1000), function()
      user:ClearChat()
			user:SendChatMessage(Theme.info .. "�� ������ ���������� �� ����� ����������� ����� " .. n .. " ������")
			user:SendChatMessage(Theme.info .. "�������� " .. i)
		end)
	end
	SetTimer(n * 1000, function()
		user:Spawn()
	end)
end

return Death
