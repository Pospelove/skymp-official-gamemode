-- Death.lua

local Death = {}
Death.equipmentBackup = {}

function Death.OnPlayerChatCommand(player, tokens)
	local hasExtraPermission = Main.IsDeveloper(player)

	if tokens[1] == "/kill" then
		if not hasExtraPermission then return player:SendChatMessage(Strings.NoPermission) end
			player:SetCurrentAV("Health", 0)
		return
	end
end

function Death.OnPlayerDying(player, killer)
	Death.equipmentBackup[player:GetName()] = Account.GetEquipment(player)
	if killer then
		SendChatMessageToAll(Color.gold .. player:GetName() .. " был убит " .. killer:GetName())
	else
		SendChatMessageToAll(Color.gold .. player:GetName() .. " умер")
	end
end

function Death.OnPlayerDeath(player, killer)
	player:SendChatMessage(Color.grey .. "Вы будете перемещены на точку возрождения через 5 секунд")
	SetTimer(5250, function()
		Account.SetRandomSpawn(player)
		player:Spawn()
	end)
end

function Death.OnPlayerSpawn(player)
	SetTimer(250, function()
		local backupEq = Death.equipmentBackup[player:GetName()]
		if backupEq then
			Account.SetEquipment(player, backupEq)
		end
	end)
end

return Death