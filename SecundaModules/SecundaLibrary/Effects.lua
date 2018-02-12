Effects = {}

local gRaw = dsres.effects
local gNumIdensUse = {}

function Effects.Init()

  local numItemTypes = #gRaw
  print("")
  print("Creating " .. numItemTypes .. " effects")

  local clock = GetTickCount()

  for i = 1, numItemTypes do
    local t = gRaw[i]
    if t ~= nil then
      local iden = t[1]
      local archetype = t[2]
      local formID = t[3]
      local castingType = t[4]
      local delivery = t[5]
      local av1 = t[6]
      local av2 = t[7]
      local iden_ = iden
      if gNumIdensUse[iden] ~= nil and gNumIdensUse[iden] > 0 then
        iden_ = iden .. tostring(gNumIdensUse[iden])
      end
      print("Creating effect " .. iden_)
      local mgef = Effect.Create(iden_, archetype, formID, castingType, delivery)
      if mgef ~= nil then
        if gNumIdensUse[iden] == nil then gNumIdensUse[iden] = 0 end
        gNumIdensUse[iden] = gNumIdensUse[iden] + 1
      else
        print("Unable to create " .. iden_)
      end
    end
  end

  print("Done in " .. (GetTickCount() - clock) .. "ms")
end

function Effects.Require()
  if not Effects.inited then
    Effects.Init()
    Effects.inited = true
  end
end

function Effects.OnServerInit()
  Effects.Require()
  return true
end

return Effects
