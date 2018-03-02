Horse = {}

local horseIdsSet = {
      [0x00109E3D] = true,
			[0x00109AB1] = true,
			[0x00109E41] = true,
			[0x00109E40] = true,
			[0x00109E3E] = true,
			[0x00097E1E] = true,
			[0x0009CCD7] = true,
			[0x0010BF90] = true
}

function Horse.OnPlayerUpdate(pl)
  if pl:IsNPC() and horseIdsSet[pl:GetBaseID()] then
    pl:SetBaseAV("Health", 1000 * 1000)
    pl:SetCurrentAV("Health", 1000 * 1000)
  end
  return true
end

local urbadguyMsg = {}

function Horse.OnPlayerHitPlayer(pl, target, weap, ammo, spell)
  if target:IsNPC() and horseIdsSet[target:GetBaseID()] then
    if weap == nil and ammo == nil and spell == nil then
      if not urbadguyMsg[pl:GetName()] then
        urbadguyMsg[pl:GetName()] = true
        local ending = "��� �� ������?"
        if math.random(0, 1) == 0 then ending = "��� �� �������?" end
        if math.random(0, 4) == 0 then ending = "������ ��������!" end
        SetTimer(2333, function() pl:SendChatMessage(Theme.info .. ru("�� ��������� ������ ���� ������. " .. ending)) end)
      end
    else
      pl:SendChatMessage(Theme.info .. ru("�������� " .. Theme.sel .. target:GetName() .. Theme.info .. " ���������� ����"))
    end
    return false
  end
  return true
end

function Horse.OnPlayerActivatePlayer(pl, target)
  if target:IsNPC() and horseIdsSet[target:GetBaseID()] and target:GetCurrentAV("Health") > 0 then
	   if target:GetRider() == pl then
       pl:Dismount()
       pl:SendChatMessage(ru(Theme.info .. "�� ������ � ������"))
     else
       pl:Mount(target)
       pl:SendChatMessage(ru(Theme.info .. "�� ���� �� ������"))
     end
     target:SetCombatTarget(nil)
  end
	return true
end

return Horse
