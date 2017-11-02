-- DemoMine.lua

local DemoMine = {}

function DemoMine.OnServerInit()
	local door1 = Object.Create(0x000B6CCE, 0x00037CFE, Location(0x0000003C), 8889.0400, -58185.6836, 1429.7943)
	door1:SetAngle(0.0, 0.0, 143.0)
	local door2 = Object.Create(0x000B6CCD, 0x00037CFE, Location(0x000B6BE6), 2472.5962, 1303.8418, 9245.0801)
	door2:SetAngle(0.0, 0.0, 193.0)
	door1:RegisterAsTeleportDoor(door2)
	door2:RegisterAsTeleportDoor(door1)

	local chest = Object.Create(0, 0x0007434B, Location(0x0000003C), 8257.3135, -57405.4766, 1474.5438)
	chest:SetAngle(0.0, 0.0, 34.0)
	chest:RegisterAsContainer()

	local ore1 = Object.Create(0x000DEAD6, 0x000A2C46, Location(0x000B6BE6), 1643.8424, 5038.1445, 8219.3301)
	ore1:SetAngle(0.0, 0.0, 114.5)

	DemoMine.door1 = door1
	DemoMine.door2 = door2
	DemoMine.chest = chest
	DemoMine.ore1 = ore1

	DemoMine.state = {}
end

function DemoMine.OnPlayerChatCommand(player, tokens)
	if tokens[1] == "/mine" then
		player:SetSpawnPoint(Location(0x0000003c), 6580.0000, -55964.0000, 709.0000, 120.0)
		player:Spawn()
	end
end

function DemoMine.OnPlayerActivateObject(player, object)

	if object == DemoMine.door1 then
		if not DemoMine.state[player:GetName()] then
			DemoMine.doorX = player:GetX()
			DemoMine.doorY = player:GetY()
			DemoMine.doorZ = player:GetZ()
			DemoMine.doorA = player:GetAngleZ()
			SetTimer(3000, function()
				player:ShowDialog(10001, "Message", "", "Чтобы зайти в шахту сначала начните работу (с помощью сундука)", -1)
			end)
		end
		return true
	end

	if object == DemoMine.chest then
		if not DemoMine.state[player:GetName()] then
			player:ShowDialog(10002, "List", "Начать работу на месторождении железа?", "Ок\nОтмена", 0)
		else
			player:ShowDialog(10002, "List", "Завершить работу на месторождении железа?", "Ок\nОтмена", 0)
		end
		return false
	end

	return true
end

function DemoMine.OnPlayerHitObject(player, object, weap, ammo)
	if object == DemoMine.ore1 then
		if DemoMine.state[player:GetName()] then
			if weap == ItemType.LookupByIdentifier("Pickaxe") then

				if DemoMine.state[player:GetName()].tutorial then
					player:SendChatMessage(Color.gold .. "Вам нужно ударить 6 раз, чтобы получить 1 кусок руды")
					DemoMine.state[player:GetName()].tutorial = false
				end

				if DemoMine.state[player:GetName()].hits > 0 then
					DemoMine.state[player:GetName()].hits = DemoMine.state[player:GetName()].hits - 1
				else
					DemoMine.state[player:GetName()].hits = 5
					player:AddItem(ItemType.LookupByIdentifier("IronOre"), 1)
					if DemoMine.state[player:GetName()].tutorial1 then
						player:SendChatMessage(Color.gold .. "Когда устанете работать - возвращайтесь к сундуку за наградой")
						DemoMine.state[player:GetName()].tutorial1 = false
					end
				end

			else
				player:SendChatMessage(Color.red .. "Добыча руды возможна только с помощью кирки")
			end
		end
	end
end

function DemoMine.OnPlayerHitPlayer(player, target, weap, ammo)
	if DemoMine.state[player:GetName()] and DemoMine.state[target:GetName()] then
		player:SendChatMessage(Color.red .. "Вы не можете наносить урон другим работникам шахты")
		return false
	end
	return true
end

function DemoMine.OnPlayerDialogResponse(player, dialogID, inputText, listItem)

	if dialogID == 10001 then
		player:SetSpawnPoint(Location(0x0000003c), DemoMine.doorX, DemoMine.doorY, DemoMine.doorZ, DemoMine.doorA)
		player:Spawn()
	end

	if dialogID == 10002 then
		if listItem == 0 then
			if not DemoMine.state[player:GetName()] then
				DemoMine.state[player:GetName()] = {}
				DemoMine.state[player:GetName()].hits = 5
				DemoMine.state[player:GetName()].tutorial = true
				DemoMine.state[player:GetName()].tutorial1 = true
				player:SendChatMessage(Color.gold .. "Пройдите в шахту и добудьте немного железной руды")
				player:SendChatMessage(Color.gold .. "Для этого достаньте кирку на R (как оружие) и стучите по залежам руды")
				player:AddItem(ItemType.LookupByIdentifier("Pickaxe"), 1)
				player:EquipItem(ItemType.LookupByIdentifier("Pickaxe"), 0)
			else
				DemoMine.state[player:GetName()] = nil
				player:SendChatMessage(Color.green .. "Руководство шахты благодарно за ваш труд")
				local n = player:GetItemCount(ItemType.LookupByIdentifier("IronOre"))
				player:RemoveItem(ItemType.LookupByIdentifier("IronOre"), n)
				player:RemoveItem(ItemType.LookupByIdentifier("Pickaxe"), 1)
				player:AddItem(ItemType.LookupByIdentifier("Gold001"), n * 2)
			end
		end
	end
end

return DemoMine