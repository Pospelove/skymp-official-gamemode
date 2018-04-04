local ActorValues = {}

local timerStarted = {}

function ActorValues.OnUserConnect(user)
  user:AddTask(function()
    user:SetBaseAV("HealRate", 0)
  end)
end

function ActorValues.OnPlayerJump(pl)
  local stamina = pl:GetCurrentAV("Stamina")
  pl:SetCurrentAV("Stamina", stamina - 75)
  return true
end

return ActorValues
