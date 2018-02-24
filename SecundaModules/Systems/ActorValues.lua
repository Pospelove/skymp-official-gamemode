local ActorValues = {}

local lastMsg = {}

function ActorValues.OnUserConnect(user)
  user:AddTask(function()
    user:SetBaseAV("HealRate", 0)
  end)
end

function ActorValues.OnUserUpdate(user)
  local jumpTarget = "высоту"
  local mult = 0.90
  if user:IsRunning() then jumpTarget = "длину"; mult = 0.875 end
  if user:IsJumping() then
    local stamina = user:GetCurrentAV("Stamina")
    user:SetCurrentAV("Stamina", stamina * mult)
    if stamina < 10 then
      local health = user:GetCurrentAV("Health")
      user:SetCurrentAV("Health", health - (1 + 0.25 * mult))
      local lastMsgMoment = lastMsg[user:GetID()]
      if lastMsgMoment == nil or GetTickCount() - lastMsgMoment > 2500 then
        user:SendChatMessage(Theme.info .. "Вы измождены бесконечными прыжками в " .. tostring(jumpTarget) .. "")
        lastMsg[user:GetID()] = GetTickCount()
      end
    end
  end
  return true
end

return ActorValues
