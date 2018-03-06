local AI = {}

local nonAgro = {
  CowRace = true,
  ChickenRace = true,
  HareRace = true,
  ElkRace = true,
  DogRace = true,
}

local cache = {}

local function IsNonAgressive(baseID)
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

function AI.OnPlayerStreamInPlayer(pl, target)
  if pl:IsNPC()then
    if not IsNonAgressive(pl:GetBaseID()) then
      if DebugMiroslav.IsPlacedID(pl:GetID()) then
        pl:SetCombatTarget(nil)
      else
        pl:SetCombatTarget(pl:GetHost())
      end
    end
  end
  return true
end

return AI
