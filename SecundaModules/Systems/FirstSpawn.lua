local FirstSpawn = {}

local function GetRandomSpawnPointWObject()
  local res = nil
  while not res do
    local wos = WorldObject.GetAllWorldObjects()
    local i = math.random(1, #wos)
    local wo = wos[i]
    if wo:GetValue("type") ~= "Door" and wo:GetValue("locationID") == 0x0000003C then
      res = wo
    end
  end
  return res
end

function FirstSpawn.OnUserLoad(user)
  if user:GetAccountVar("randSpawn") == nil then
    user:SetAccountVar("x", 0.0)
    user:SetAccountVar("randSpawn", true)
  end
  local hasSpawnPoint = (user:GetAccountVar("x") ~= nil and user:GetAccountVar("x") ~= 0.0)
  if not hasSpawnPoint then
    local spawnPoint = {0.0, 0.0, 0.0, 180.0, 0x0000003C}
    local wo = GetRandomSpawnPointWObject()
    spawnPoint[1] = wo:GetValue("x") + math.random(-128, 128)
    spawnPoint[2] = wo:GetValue("y") + math.random(-128, 128)
    spawnPoint[3] = wo:GetValue("z") + 256
    spawnPoint[4] = math.random(0, 359)
    spawnPoint[5] = 0x0000003C

    user:SetAccountVar("location", spawnPoint[5])
    user:SetAccountVar("x", spawnPoint[1])
    user:SetAccountVar("y", spawnPoint[2])
    user:SetAccountVar("z", 200 + spawnPoint[3])
    user:SetAccountVar("angle", spawnPoint[4])
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
