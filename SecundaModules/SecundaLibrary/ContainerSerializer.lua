ContainerSerializer = {}

local gItemTypeByJson = {}
local gN = 1

local function GetNewIden()
  local iden = "CUSTOM_ITEM_TYPE" .. gN
  gN = gN + 1
  return iden
end

local function GetItemTypeInfo(itemType)
  local inf = {}
  inf.iden = itemType:GetIdentifier()
  inf.class = itemType:GetClass()
  inf.subClass = itemType:GetSubclass()
  inf.formID = itemType:GetBaseID()
  inf.weight = packfloat(itemType:GetWeight())
  inf.goldValue = itemType:GetGoldValue()
  inf.damage = packfloat(itemType:GetDamage())
  inf.armorRating = packfloat(itemType:GetArmorRating())
  inf.soulSize = itemType:GetSoulSize()
  inf.gemSize = itemType:GetCapacity()
  inf.health = packfloat(itemType:GetHealth())
  inf.skillName = itemType:GetSkillName()
  inf.effects = {}
  if itemType:GetEnchantment() ~= nil then
    inf.enchStr = MagicSerializer.Serialize(itemType:GetEnchantment())
  end
  for i = 1, itemType:GetNumEffects() do
    local entry = {}
    entry.iden = itemType:GetNthEffectIdentifier(i)
    entry.mag = packfloat(itemType:GetNthEffectMagnitude(i))
    entry.dur = packfloat(itemType:GetNthEffectDuration(i))
    entry.area = packfloat(itemType:GetNthEffectArea(i))
    table.insert(inf.effects, entry)
  end
  inf.effects = pretty.write(inf.effects)
  return inf
end

local function CreateItemType(inf)
  inf = tablex.deepcopy(inf)
  inf.effects = pretty.read(inf.effects)
  local classPlusSubclass = ""
  classPlusSubclass = classPlusSubclass .. inf.class
  if inf.subClass:len() > 0 then
    classPlusSubclass = classPlusSubclass .. "." .. inf.subClass
  end
  local infJson = json.encode(inf)
  if gItemTypeByJson[infJson] ~= nil then
    return gItemTypeByJson[infJson]
  end
  local itemType = ItemType.Create(GetNewIden(), classPlusSubclass, inf.formID, unpackfloat(inf.weight), inf.goldValue, 1.0, inf.skillName)
  itemType:SetWeight(unpackfloat(inf.weight))
  itemType:SetGoldValue(inf.goldValue)
  itemType:SetDamage(unpackfloat(inf.damage))
  itemType:SetArmorRating(unpackfloat(inf.armorRating))
  itemType:SetSoulSize(inf.soulSize)
  itemType:SetCapacity(inf.soulSize)
  if inf.enchStr ~= nil then
    local ench = MagicSerializer.Deserialize(inf.enchStr, "Enchantment")
    itemType:SetEnchantment(ench)
  end
  pcall(function() itemType:SetHealth(unpackfloat(inf.heatlh)) end)
  for i = 1, #inf.effects do
    local entry = inf.effects[i]
    itemType:AddEffect(Effect.LookupByIdentifier(entry.iden), unpackfloat(entry.mag), unpackfloat(entry.dur), unpackfloat(entry.area))
  end
  gItemTypeByJson[infJson] = itemType
  return itemType
end

function ContainerSerializer.Serialize(cont)
  local t = {}
  for i = 1, #cont.items do
    local entry = cont.items[i]
    local tableEntry = {}
    local isCustom = not ItemTypes.IsFromDS(entry.itemType)
    if isCustom then
      tableEntry.inf = GetItemTypeInfo(entry.itemType)
      tableEntry.count = entry.count
    else
      tableEntry.iden = entry.itemType:GetIdentifier()
      tableEntry.count = entry.count
    end
    table.insert(t, tableEntry)
  end
  return json.encode(t)
end

function ContainerSerializer.Deserialize(jsonData)
  local cont = Container()
  local t = json.decode(jsonData)
  for i = 1, #t do
    local tableEntry = t[i]
    local itemType = nil
    local count = tableEntry.count
    if tableEntry.iden ~= nil then
      itemType = ItemTypes.Lookup(tableEntry.iden)
    else
      itemType = CreateItemType(tableEntry.inf)
    end
    cont:AddItem(itemType, count)
  end
  return cont
end

return ContainerSerializer
