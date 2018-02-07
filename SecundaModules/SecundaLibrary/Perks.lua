local Perks = {}

local gRaw = dsres.perks
local gPerks = {}

function Perks.Init()
  local count = #gRaw
  print("")
  print("Creating " .. count .. " perks")

  local clock = GetTickCount()

  for i = 1, count do
    local t = gRaw[i]
    if t ~= nil then
      local iden = t[1]
      local id = t[2]
      local requiredPerkID = t[3]
      local av = t[4]
      local requiredSkillLevel = t[5]
      local perk = Perk.Create(id, av, requiredSkillLevel, Perk.LookupByID(requiredPerkID))
      perk:SetPlayable(av ~= "")
      table.insert(gPerks, perk)
    end
  end

  print("Done in " .. (GetTickCount() - clock) .. "ms")
end

function Perks.Require()
  if not Perks.inited then
    Perks.Init()
    Perks.inited = true
  end
end

function Perks.OnServerInit()
  Perks.Require()
  return true
end
