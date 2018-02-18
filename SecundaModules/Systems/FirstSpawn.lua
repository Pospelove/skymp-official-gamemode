local FirstSpawn = {}

function FirstSpawn.OnUserLoad(user)
  local hasSpawnPoint = (user:GetAccountVar("x") ~= nil and user:GetAccountVar("x") ~= 0.0)
  if not hasSpawnPoint then
    local spawnPoint = { 0x0000003C, 17224.7734, -47204.4531, -51.8551, 58.7287 }
    user:SetAccountVar("location", spawnPoint[1])
    user:SetAccountVar("x", spawnPoint[2])
    user:SetAccountVar("y", spawnPoint[3])
    user:SetAccountVar("z", spawnPoint[4])
    user:SetAccountVar("angle", spawnPoint[5])
    print("The first spawn of " .. tostring(user))
  end
  return true
end

function FirstSpawn.OnUserSpawn(user)
  if user:GetTintmaskCount() == 0 and not stringx.startswith(user:GetName(), "layner") then
    SetTimer(500, function() user:ShowRaceMenu() end)
  end
  return true
end

function FirstSpawn.OnUserCharacterCreated(user)
  user:SendChatMessage(Theme.notice .. "Провинция Скайрим приветствует Вас")
  return true
end

return FirstSpawn
