ItemTypes = {}

local gRaw = dsres.itemTypes
local gNumIdensUse = {}

function ItemTypes.Get(iden)
  return ItemType.LookupByIdentifier(iden)
end

function ItemTypes.Init()

  local numItemTypes = #gRaw
  print("")
  print("Creating " .. numItemTypes .. " item types")

  local clock = GetTickCount()

  for i = 1, numItemTypes do
    local t = gRaw[i]
    if t ~= nil then
      local iden = t[1]
      local class = t[2]
      local formID = t[3]
      local weight = t[4]
      local goldValue = t[5]
      local damageArmorPoints = t[6]
      local skill = t[7]
      local enchIden = t[8]
      local soulSize = t[9]
      local gemSize = t[10]
      local effectItems = {}
      local j = 11
      while t[j] ~= nil do
        table.insert(effectItems, t[j])
        j = j + 1
      end

      if stringx.startswith(class, "Weapon") or stringx.startswith(class, "Ammo") then
        if damageArmorPoints == 0.0 then
          damageArmorPoints = 1.0
        end
      end

      if class ~= "Weapon" and class ~= "Armor" and class ~= "Book" and class ~= "Weapon.Staff" then -- Not implemented
        if gNumIdensUse[iden] == nil then
          gNumIdensUse[iden] = 0
        end
        local iden_ = iden
        if gNumIdensUse[iden] > 0 then
          iden_ = iden .. tostring(gNumIdensUse[iden])
        end
        local itemType = ItemType.Create(iden_, class, formID, weight, goldValue, damageArmorPoints, skill)
        if itemType == nil then
          print ("Unable to create " .. iden_)
        end
        gNumIdensUse[iden] = gNumIdensUse[iden] + 1
      end
    end
  end

  print("Done in " .. (GetTickCount() - clock) .. "ms")
end

function ItemTypes.TestPerfomance()

  local FormatTime = function(clock, numCalls)
    local ms = ((GetTickCount() - clock) / numCalls)
    local perSec = math.floor(1 / ms * 1000)
    return ms  .. "ms " .. "(" .. perSec .. " per sec)"
  end

  local clock = GetTickCount()
  local numCalls = 10000
  for i = 1, numCalls do
    local itemType = ItemType.LookupByIdentifier("Корзина")
  end
  print("ItemType.LookupByIdentifier() = " .. FormatTime(clock, numCalls))
end

function ItemTypes.Require()
  if not ItemTypes.inited then
    ItemTypes.Init()
    ItemTypes.inited = true
  end
end

function ItemTypes.RunTests()
  local iden = "KVGUFTJOUFUIADSGADSYHWTETLQHWQOWLMWADDAJUGJASDTDASDSGADSYHWTETLQHWTETFBVSDASD"
  ItemType.Create(iden, "Weapon.Sword", 0x00012EB7, 8.0, 30, 7.0, "OneHanded")
  if ItemType.LookupByIdentifier(iden) == nil then
    error("test failed")
  end
end

function ItemTypes.OnServerInit()
  ItemTypes.Require()
  return true
end

return ItemTypes