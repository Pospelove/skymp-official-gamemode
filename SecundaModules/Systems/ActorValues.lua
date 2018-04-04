local ActorValues = {}

local timerStarted = {}

function ActorValues.OnUserConnect(user)
  user:AddTask(function()
    user:SetBaseAV("HealRate", 0)
  end)
end

function ActorValues.OnPlayerUpdate(pl)
  if pl:IsNPC() then return true end

  if pl:IsJumping() or pl:IsInJumpState() then
    local stamina = pl:GetCurrentAV("Stamina")
    pl:SetCurrentAV("Stamina", stamina - 25)
  end
  if pl:IsJumping() or pl:IsFalling() then
    pl:SetBaseAV("StaminaRateMult", 0)
  else
    if pl:GetBaseAV("StaminaRateMult") == 0 and not timerStarted[pl:GetID()] then
      timerStarted[pl:GetID()] = true
      SetTimer(3000, function()
        pl:SetBaseAV("StaminaRateMult", 100)
        timerStarted[pl:GetID()] = nil
      end)
    end
  end
  return true
end

return ActorValues
