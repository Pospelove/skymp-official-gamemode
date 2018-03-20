local FirstSpawn = {}

function FirstSpawn.OnUserLoad(user)
  if user:GetAccountVar("whiterunSpawn") == nil then
    user:SetAccountVar("x", 0.0)
    user:SetAccountVar("whiterunSpawn", true)
  end
  local hasSpawnPoint = (user:GetAccountVar("x") ~= nil and user:GetAccountVar("x") ~= 0.0)
  if not hasSpawnPoint then
    local sp = {
    {19428, 46646.6 ,-147.288,243,0x3c},
    {19570.3,-47331.3 ,-144.88,359 ,0x3c},
    {18627.3 ,-45223.7 ,-111.08,86 ,0x3c},
    {18612.6 ,-44967.3 ,-128.878 ,86 ,0x3c},
    {18385.4 ,-45129.8 ,-111.505 ,86 ,0x3c},
    {20505.8 ,-45914.8 ,-147.197 ,70 ,0x3c},
    {21515 ,-45653.9 ,-121.432 ,44, 0x3c},
    {23506.7 ,-46140.3 ,-6.59117 ,326, 0x3c},
    {23309.2 ,-45841.4 ,-26.5323 ,326, 0x3c},
    {22810.5 ,-45378.2 ,-134.284 ,319, 0x3c},
    {20896.8 ,-42707.2 ,-124.315,199 ,0x3c},
    {21129.9 ,-42786.6 ,-111.349 ,199, 0x3c},
    {20575.3 ,-42594.6 ,-130.995 ,199 ,0x3c},
    {20706.3 ,-42879.5 ,-111.162 ,199 ,0x3c},
    {20895.5 ,-42323.2 ,-154.963 ,199 ,0x3c},
    {22817.2 ,-44043.6 ,-139.282 ,340 ,0x3c},
    {24164.2 ,-42442.3 ,-78.2803 ,51 ,0x3c},
    {24448.7 ,-42378.5 ,-140.137 ,51 ,0x3c},
    {24616.6 ,-41826.2 ,-159.583 ,51 ,0x3c},
    {25044.8 ,-41765.5 ,-161.579 ,51, 0x3c},
    {31127.6 ,-16344 ,-4464.88 ,327, 0x3c},
    {30755.1 ,-16525.6 ,-4464.13 ,336, 0x3c},
    {30492 ,-16535.4 ,-4467.41 ,336, 0x3c},
    {30167.5 ,-16569.2 ,-4468.02 ,336, 0x3c},
    {30539.3 ,-16292.3 ,-4474.78 ,336, 0x3c},
    {30921.8 ,-16509 ,-4464.34 ,283, 0x3c},
    {30724.2 ,-16759.6 ,-4446.44,283, 0x3c},
    {30132.4 ,-16666.5 ,-4455.9 ,283, 0x3c},
    {29798.4 ,-16870.3 ,-4477.34 ,283, 0x3c},
    {-85212.3 ,7602.62 ,-4051.41 ,126 ,0x3c},
    {-84727 ,7172.67 ,-4218.55 ,126, 0x3c},
    {-84248.8 ,7197.11 ,-4285.82 ,126, 0x3c},
    {-83749.4 ,5448.77 ,-4301.85 ,126 ,0x3c},
    {-83658.3 ,3963.89 ,-4293.1,122 ,0x3c},
    {-81231.8 ,5922.78 ,-4737.86 ,99 ,0x3c},
    {-80623.3 ,6618.31 ,-4715.91 ,102 ,0x3c},
    {-80062.4 ,6519.67 ,-4719.68 ,108 ,0x3c},
    {-84645.7 ,9474.42 ,-4047.44 ,181 ,0x3c},
    {-84412.6 ,9382.05 ,-4067.68 ,181 ,0x3c},
    {-86084.3 ,9007.42 ,-3960.88 ,276 ,0x3c},
    {-86236.8 ,9468.61 ,-3949.88 ,266 ,0x3c}
    }


    local spawnPoint = sp[math.random(1, #sp)]
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
