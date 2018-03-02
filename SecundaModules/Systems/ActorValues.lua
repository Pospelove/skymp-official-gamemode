local ActorValues = {}

local timerStarted = {}

function ActorValues.OnUserConnect(user)
  user:AddTask(function()
    user:SetBaseAV("HealRate", 0)
  end)
end

function ActorValues.OnUserUpdate(user)
  FurnOnUserUpdate(user)
  if user:IsJumping() then
    local stamina = user:GetCurrentAV("Stamina")
    user:SetCurrentAV("Stamina", stamina - 25)
  end
  if user:IsJumping() or user:IsFalling() then
    user:SetBaseAV("StaminaRateMult", 0)
  else
    if user:GetBaseAV("StaminaRateMult") == 0 and not timerStarted[user:GetID()] then
      timerStarted[user:GetID()] = true
      SetTimer(3000, function()
        user:SetBaseAV("StaminaRateMult", 100)
        timerStarted[user:GetID()] = nil
      end)
    end
  end
  return true
end

return ActorValues
