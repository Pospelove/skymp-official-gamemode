Anticheat = {}

local gLastPlayerHit = {}

local function OnDetect(pl, acCode)
  pl:SendChatMessage(Theme.error .. "�� ���� ������� �� ���������� � ��������� (", acCode, ")")
  SetTimer(500, function() pl:Kick() end)
end

function Anticheat.OnPlayerHitPlayer(pl, target, weap, ammo, spell)
  local playerid = pl:GetID()
  local clock = GetTickCount()
  if not spell then
    if clock - gLastPlayerHit[playerid] > 100 then
      gLastPlayerHit[playerid] = clock
    else
      OnDetect(pl, 0x01)
    end
  end

end

return Anticheat
