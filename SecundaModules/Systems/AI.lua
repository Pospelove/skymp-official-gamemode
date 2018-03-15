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

local function StepAI(playerid)
  local pl = Player.LookupByID(playerid)
  if pl and pl:IsNPC() and pl:GetCurrentAV("Health") > 0 and pl:GetHost() ~= nil then
    UpdateCombat(pl)
    SetTimer(10000, function()
      StepAI(playerid)
    end)
  else
    timerSet[playerid] = nil
  end
end

local function SetAITimer(pl)
  local playerid = pl:GetID()
  if pl:IsNPC() and not timerSet[playerid] then
    timerSet[playerid] = true
    SetTimer(1, function()
      StepAI(playerid)
    end)
  end
end

function AI.OnPlayerSpawn(pl)
  return true
end

function AI.OnPlayerStreamInPlayer(pl, target)
  SetAITimer(pl)
  UpdateCombat(pl)
  UpdateCombat(target)
  return true
end

function AI.OnPlayerHostPlayer(pl, target)
  UpdateCombat(target)
end

return AI
