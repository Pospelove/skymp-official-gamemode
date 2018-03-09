ContainerLoot = {}

--TODO: Treas and alchemy bags

local containerType = {
  Food = {0x845, 0x97F68, 0x97f54, 0x97f6c, 0x97f6a, 0x97f6e, 0x97f70, 0x97f64, 0x97f66, 0x97f51},
  BanditChest = {0x3ac21},
  DraugrChest = {0x20670},
  RuinUrnSmall = {0x1cd65, 0x1cd63},
  RuinUrnLarge = {0x1c4aa, 0x1c4ac},
  Home = {0x24ca4, 0x24ca5, 0x24ca6, 0x24ca, 0x21366, 0x21364},
  BarrelIngredient = {0x92b10, 0x92b13},
  Chest = {0x9af19, 0x21363},
  Clothing = {0x6b303, 0x21365, 0xc4d4e, 0xc2a05, 0x21362},
  BarrelMeatAndSalt = {0x10d9c1},
  Bag = {0xb7879, 0xaf6ae, 0xacd6f},
  MeadBarrel = {0x101c95},
  HokinsBarrel = {0x8836c},
  DwarvenTreas = {0x2069a},
  Dwarven = {0x20650, 0x20653},
  DraugrCorpse = {0x8008d},
  BanditTreas = {0x2064f},
  FalmerTreas = {0x20659},
  DraugrTreasBoss = {0x20671},
  WarlockChest = {0x5418e},
  ImperialChest = {0x8a3b4}
}
-- NobleChest01 was last

local function GetType(baseID)
  for typeStr, ids in pairs(containerType) do
    for i = 1, #ids do
      if ids[i] == baseID then return typeStr end
    end
  end
end

local function CreateContainer(typeStr)
  local cont = Container()
  local items = nil
  local uniqueItems = nil
  local numSlotsRange = {0,0}
  local numItemsRange = {0,0}
  if typeStr == "Food" or typeStr == "HokinsBarrel" or typeStr == "MeadBarrel" or typeStr == "BarrelIngredient" then
    items = {"Зелёное яблоко", "Морковь", "Лук-порей", "Картофель", "Красное яблоко", "Помидор", "Соль", "Чеснок"}
    uniqueItems = {}
    numSlotsRange = {1, 2}
    numItemsRange = {1, 20}
  elseif typeStr == "DraugrCorpse" then
    items = {"Костная мука", "Древний нордский меч"}
    uniqueItems = {}
    numSlotsRange = {1, 2}
    numItemsRange = {1, 2}
  elseif typeStr == "BanditChest" or typeStr == "BanditTreas" then
    items = {}
    cont:AddItem(ItemTypes.Lookup("Золото"), math.random(1, 30))
    uniqueItems = {"Железный кинжал", "Стальной кинжал", "Железный меч", "Стальной меч", "Железный боевой топор", "Стальной боевой топор", "Железная булава", "Стальная булава"}
    numSlotsRange = {1, 3}
    numItemsRange = {1, 2}
  elseif typeStr == "DraugrChest" then
    items = {"Древний нордский меч", "Древний нордский боевой топор", "Слабое зелье лечения", "Железный слиток"}
    cont:AddItem(ItemTypes.Lookup("Золото"), math.random(1, 30))
    uniqueItems = {}
    numSlotsRange = {1, 3}
    numItemsRange = {1, 2}
  elseif typeStr == "Home" or typeStr == "Clothing" then
      items = {"Одежда", "Одежда2", "Одежда3", "Одежда4", "Одежда5", "Одежда6", "Одежда7", "Одежда8", "Одежда9", "Утюг"}
      uniqueItems = {}
      numSlotsRange = {1, 3}
      numItemsRange = {1, 2}
  end
  local numSlots = math.random(numSlotsRange[1], numSlotsRange[2])
  for i = 1, numSlots do
    local numItems = math.random(numItemsRange[1], numItemsRange[2])
    if #items > 0 then
      local i = math.random(1, #items)
      local itemType = ItemTypes.Lookup(items[i])
      cont:AddItem(itemType, numItems)
    end
  end
  if #uniqueItems > 0 then
    local i = math.random(1, #uniqueItems)
    local itemType = ItemTypes.Lookup(uniqueItems[i])
    cont:AddItem(itemType, 1)
  end
  return cont
end

local gRaw = dsres.itemTypes

local function Accept(itemType)
  if itemType:GetGoldValue() > 100 or itemType:GetEnchantment() ~= nil then
    return false
  end
  return true
end

local function GetCount(itemType)
  if itemType:GetSubclass() == "Food" then
    return math.random(1, 5)
  end
  return 1
end

function ContainerLoot.FillContainer(wo)
  pcall(function()
    local typeStr = GetType(wo:GetValue("baseID"))
    if not typeStr then return end
    local cont = CreateContainer(typeStr)
    cont:ApplyTo(wo.obj)
  end)
end

return ContainerLoot
