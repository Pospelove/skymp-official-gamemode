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
local ignoredPlayers = {}
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
  table.insert(ignoredPlayers, user.pl)
end

local function UpdateCombat(pl)
  if pl:IsNPC()then
    if not IsNonAgressive(pl:GetBaseID()) then
      if DebugMiroslav.IsPlacedID(pl:GetID()) then
        pl:SetCombatTarget(nil)
      else
        local host = pl:GetHost()
        for i = 1, #ignoredPlayers do
          if ignoredPlayers[i] == host then
            pl:SetCombatTarget(nil)
            return
          end
        end
        pl:SetCombatTarget(host)
      end
    end
  end
end

function AI.OnPlayerStreamInPlayer(pl, target)
  UpdateCombat(pl)
  return true
end

function AI.OnPlayerUpdate(pl)
  UpdateCombat(pl)
  return true
end

return AI
