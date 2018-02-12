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
  inf.weight = itemType:GetWeight()
  inf.goldValue = itemType:GetGoldValue()
  inf.damage = itemType:GetDamage()
  inf.armorRating = itemType:GetArmorRating()
  inf.soulSize = itemType:GetSoulSize()
  inf.gemSize = itemType:GetCapacity()
  inf.health = itemType:GetHealth()
  inf.skillName = itemType:GetSkillName()
  inf.effects = {}
  for i = 1, itemType:GetNumEffects() do
    local entry = {}
    entry.iden = itemType:GetNthEffectIdentifier(i)
    entry.mag = itemType:GetNthEffectMagnitude(i)
    entry.dur = itemType:GetNthEffectDuration(i)
    entry.area = itemType:GetNthEffectArea(i)
    table.insert(effects, entry)
  end
  return inf
end

local function CreateItemType(inf)
  local classPlusSubclass = ""
  classPlusSubclass = classPlusSubclass .. inf.class
  if inf.subClass:len() > 0 then
    classPlusSubclass = classPlusSubclass .. "." .. inf.subClass
  end
  local infJson = json.encode(inf)
  if gItemTypeByJson[infJson] ~= nil then
    return gItemTypeByJson[infJson]
  end
  local itemType = ItemType.Create(GetNewIden(), classPlusSubclass, inf.formID, inf.weight, inf.goldValue, 1.0, inf.skillName)
  itemType:SetWeight(inf.weight)
  itemType:SetGoldValue(inf.goldValue)
  itemType:SetDamage(inf.damage)
  itemType:SetArmorRating(inf.armorRating)
  itemType:SetSoulSize(inf.soulSize)
  itemType:SetCapacity(inf.soulSize)
  itemType:SetHealth(inf.heatlh)
  for i = 1, #inf.effects do
    local entry = inf.effects[i]
    itemType:AddEffect(Effect.LookupByIdentifier(entry.iden), entry.mag, entry.dur, entry.area)
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
