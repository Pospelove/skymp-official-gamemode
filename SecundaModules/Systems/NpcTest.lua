local NpcTest = {}
local NavMesh = NpcTest

function NpcTest.OnUserChatCommand(user, cmd)
  local tokens = stringx.split(cmd)
	local hasExtraPermission = Debug.IsDeveloper(user)
  local player = user.pl

	if tokens[1] == "/tpnpc" then
		player:SetPos(lastNpc:GetX(), lastNpc:GetY(), lastNpc:GetZ())
		player:SendChatMessage(lastNpc:GetX() .. " " ..  lastNpc:GetY() .. " " .. lastNpc:GetZ())
	end

	if tokens[1] == "/npc" then

		NavMesh.tempBase = nil

		blet = 0
		local npcNase = tokens[2]
		if not npcNase then npcNase = "" end
		if(npcNase == "bear") then
			NavMesh.tempBase = 0x23A8C
		elseif(npcNase == "wolf") then
			NavMesh.tempBase = 0x23ABE
		elseif(npcNase == "ulfric") then
			NavMesh.tempBase = 0x1414D
		elseif(npcNase == "horse") then
			NavMesh.tempBase = 0x109e3d
		elseif(npcNase ~= "") then
			NavMesh.tempBase = tonumber(npcNase, 16)
			blet = 1
		end

		print(NavMesh.tempBase)

		local npc = Player.CreateNPC(NavMesh.tempBase)
		npc:SetName("")
		lastNpc = npc

		local spawns = {
			{player:GetLocation(), player:GetX(), player:GetY(), player:GetZ(), player:GetAngleZ()}
		}
		local i = (npc:GetID() % #spawns) + 1
		npc:SetSpawnPoint(spawns[i][1], spawns[i][2], spawns[i][3], spawns[i][4], spawns[i][5])
		SetTimer(1000, function()
			print "Spawning NPC"
			npc:Spawn()
			if NavMesh.tempBase == 0x00013387 then
				SetTimer(10000, function()
					npc:SetWerewolf(true)
          local numi = Player.LookupByName("Numi")
          npc:SetCombatTarget(numi)
          if not numi then npc:SetCombatTarget(player) end
				end)
			end
			if npcNase == "" or blet == 1 then
				npc:AddItem(ItemTypes.Lookup("Железный меч"), 1)
				npc:EquipItem(ItemTypes.Lookup("Железный меч"), 0)
			end
		end)

    return true
	end
end

function NavMesh.OnPlayerDying(player, killer)

	if not player:IsNPC() then
	else
		SetTimer(2500, function() player:Kick() end)
	end
  return true
end

function NavMesh.OnPlayerActivatePlayer(pl, target)
  print("OnPlayerActivatePlayer(" .. pl:GetName() .. "," .. target:GetName())
	if target:GetRider() == pl then
		pl:Dismount()
	else
		pl:Mount(target)
		target:SetCombatTarget(nil)
	end
	return true
end

--hasTarget = {}
function NavMesh.OnPlayerHitPlayer(pl, target)
  --if not hasTarget[target:GetID()] then
    target:SetCombatTarget(pl)
    --hasTarget[target:GetID()] = true
  --end
  return true
end

return NpcTest
