local Death = {}

function Death.OnUserDying(user, killer)
	local n = 10
	SetTimer(n * 1000 + 100, function()
		for i = 1, 20 do
			user:SendChatMessage(Theme.info .. "")
		end
		user:SendChatMessage(Theme.success .. "Вы были возрождены")
	end)
	for i = 1, n do
		SetTimer((n * 1000) - (i * 1000), function()
      user:ClearChat()
			user:SendChatMessage(Color.info .. "Вы будете перемещены на точку возрождения через 5 секунд")
			user:SendChatMessage(Color.info .. "Осталось " .. i)
		end)
	end
	SetTimer(n * 1000, function()
		user:Spawn()
	end)
end

return Death
