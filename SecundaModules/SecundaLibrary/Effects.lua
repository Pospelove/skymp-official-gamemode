Effects = {}

local gNumIdensUse = {}
local gMgefByFormID = {}

function Effects.Init()

  local numItemTypes = #dsres.effects
  print("")
  print("Creating " .. numItemTypes .. " effects")

  local clock = GetTickCount()

  for i = 1, numItemTypes do
    local t = dsres.effects[i]
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
      local mgef = Effect.Create(iden_, archetype, formID, castingType, delivery)
      gMgefByFormID[formID] = mgef
      if mgef ~= nil then
        mgef:SetActorValues(av1, av2)
        if gNumIdensUse[iden] == nil then gNumIdensUse[iden] = 0 end
        gNumIdensUse[iden] = gNumIdensUse[iden] + 1
      else
        print("Unable to create " .. iden_)
      end
    end
  end

  print("Done in " .. (GetTickCount() - clock) .. "ms")
end

function Effects.Lookup(key)
  if type(key) == "string" then
    return Effect.LookupByIdentifier(key)
  end
  if type(key) == "number" then
    return gMgefByFormID[key]
  end
  return nil
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
