AI = {}

local nonAgro = {
  CowRace = true,
  ChickenRace = true,
  HareRace = true,
  ElkRace = true,
  DogRace = true,
  [0x829b6] = true,
  [0xb8eca] = true,
  FoxRace = true
}

local cache = {}
local timerSet = {}

local function IsNonAgressive(baseID)
  if nonAgro[baseID] == true then return true end
  if cache[naseID] ~= nil then return cache[baseID] end
  for i = 1, #dsres.npc do
    local entry = dsres.npc[i]
    if entry[1] == baseID then
      if nonAgro[entry[3]] then
        cache[baseID] = true
        return true
      end
    end
  end
  cache[baseID] = false
  return false
end

function AI.IgnoreUser(user)
  -- ...
end

function AI.OnPlayerSpawn(pl)
  if pl:IsNPC()then
    if not IsNonAgressive(pl:GetBaseID()) then
      pl:SetAggressive(true)
    else
      pl:SetAggressive(false)
    end
  end
end

return AI
