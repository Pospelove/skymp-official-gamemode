Anticheat = {}

local gLastPlayerHit = {}

local isTest = true


local function OnDetect(pl, acCode)
  if isTest then
    pl:SendChatMessage(Theme.error .. "Error " .. acCode)
  else
    pl:SendChatMessage(Theme.error .. "?? ???? ??????? ?? ?????????? ? ????????? (", acCode, ")")
    SetTimer(500, function() pl:Kick() end)
  end
end

function Anticheat.OnPlayerHitPlayer(pl, target, weap, ammo, spell)
  local playerid = pl:GetID()
  local clock = GetTickCount()
  if not spell then
    if gLastPlayerHit[playerid] == nil then gLastPlayerHit[playerid] = 0 end
    if clock - gLastPlayerHit[playerid] > 100 then
      gLastPlayerHit[playerid] = clock
    else
      --OnDetect(pl, 0x01)-- bad calls
    end
  end
  return true
end

return Anticheat

----------------------------------------------------------------------------------------------
