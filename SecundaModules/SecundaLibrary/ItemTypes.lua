ItemTypes = {}

local gRaw = dsres.itemTypes
local gNumIdensUse = {}
local gItemTypesByID = {}

function ItemTypes.GetAllItemTypes()
  local t = {}
  for k, v in pairs(gItemTypesByID) do
    table.insert(t, v)
  end
  return t
end

function ItemTypes.IsFromDS(itemType)
  if itemType == nil then
    error "ItemTypes.IsFromDS() nil passed as itemType parameter"
  end
  local all = ItemTypes.GetAllItemTypes()
  for i = 1, #all do
    if all[i] == itemType then
      return true
    end
  end
  return false
end

function ItemTypes.Get(iden)
  return ItemType.LookupByIdentifier(iden)
end

function ItemTypes.LookupByID(id)
  return gItemTypesByID[id]
end

function ItemTypes.Lookup(key)
  if type(key) == "number" then
    return ItemTypes.LookupByID(key)
  elseif type(key) == "string" then
    return ItemTypes.Get(key)
  end
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
      local enchID = t[8]
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
          print ("Unable to create " .. tostring(formID))
        else
          if class ~= itemType:GetClass() .. "." .. itemType:GetSubclass() and class ~= itemType:GetClass() then
            error(class .. " ~= " .. itemType:GetClass() .. "." .. itemType:GetSubclass())
          end
          itemType:SetEnchantment(Magic2.Lookup(enchID))
          for i = 1, #effectItems do
            local formID = effectItems[i][1]
            local mag = effectItems[i][2]
            local dur = effectItems[i][3]
            local area = effectItems[i][4]
            local mgef = Effects.Lookup(formID)
            if mgef == nil then
              -- ...
            else
              itemType:AddEffect(mgef, mag, dur, area)
            end
          end
          gItemTypesByID[formID] = itemType
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
  local anyIden = ItemTypes.GetAny():GetIdentifier()
  for i = 1, numCalls do
    local itemType = ItemType.LookupByIdentifier(anyIden)
  end
  print("ItemType.LookupByIdentifier() = " .. FormatTime(clock, numCalls))
end

function ItemTypes.Require()
  Effects.Require()
  Magic2.Require()
  if not ItemTypes.inited then
    ItemTypes.Init()
    ItemTypes.inited = true
  end
end

function ItemTypes.GetAny()
  for k, v in pairs(gItemTypesByID) do return v end
end

function ItemTypes.RunTests()
  local iden = "KVGUFTJOUFUIADSGADSYHWTETLQHWQOWLMWADDAJUGJASDTDASDSGADSYHWTETLQHWTETFBVSDASD"
  ItemType.Create(iden, "Weapon.Sword", 0x00012EB7, 8.0, 30, 7.0, "OneHanded")
  if ItemType.LookupByIdentifier(iden) == nil then
    error("test failed")
  end

  if ItemTypes.IsFromDS(ItemType.LookupByIdentifier(iden)) then
    error("test failed")
  end

  if not ItemTypes.IsFromDS(ItemTypes.GetAny()) then
    error("test failed")
  end
end

function ItemTypes.OnServerInit()
  ItemTypes.Require()
  return true
end

return ItemTypes
