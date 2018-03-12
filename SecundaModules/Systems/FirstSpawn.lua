local FirstSpawn = {}

function FirstSpawn.OnUserLoad(user)
  if user:GetAccountVar("whiterunSpawn") == nil then
    user:SetAccountVar("x", 0.0)
    user:SetAccountVar("whiterunSpawn", true)
  end
  local hasSpawnPoint = (user:GetAccountVar("x") ~= nil and user:GetAccountVar("x") ~= 0.0)
  if not hasSpawnPoint then
    local spawnPoint = { 0x1a26f, 25557.9941, -3056.3918, -3122.6638 + 200, 58.7287 }
    if math.random(1, 2) == 1 then
      spawnPoint = { 0x1a26f, 20338.0684, -7382.1143, -3651.5171 + 200, 58.7287 }
    end
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
