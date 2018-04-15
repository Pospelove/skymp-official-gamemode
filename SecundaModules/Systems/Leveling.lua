local Leveling = {}


local koef = {
  OneHanded = {1,0},-- +24 за попадание по цели
  TwoHanded = {1,0},-- +26 за попадание по цели
  Marksman = {1,0}, -- +29 за попадание по цели, +(2..7) за выстрел в зависимости от натяжения
  Block = {1,0}, -- +34 за блокирование удара
  Smithing = {1,0}, -- +25 за скрафченный предмет
  HeavyArmor = {1,0},
  LightArmor = {1,0},
  Pickpocket = {1,0}, -- не реализовано
  Lockpicking = {1,0}, -- +50 за сломанную отмычку
  Sneak = {1,0}, -- не реализовано
  Alchemy = {1,0}, -- +31 за скрафченное зелье
  Speechcraft = {1,0}, -- +1 за сообщение в чат
  Alteration = {1,0},
  Conjuration = {1,0},
  Destruction = {1,0},
  Illusion = {1,0},
  Restoration = {1,0},
  Enchanting = {1,0} -- +33 за зачарованный предмет, +99 за разочарованный предмет
}

local function FixExp(user)
  local experience = user:GetBaseAV("Experience")
  user:SetBaseAV("Experience", experience + 1)
  SetTimer(1, function() user:SetBaseAV("experience", experience) end)
end

local function sqr(a)
    return a * a
end

local function GetPointsForSkillLevel(skillLevel, skillName)
  local mult = koef[skillName][1]
  local mod = koef[skillName][2]
  return mult * sqr(skillLevel) + mod
end

local function AddSkillPoints(user, skillName, n)
  --user:SendChatMessage(skillName .. n)
  local skillLevel = user:GetBaseAV(skillName)
  local requiredPoints = GetPointsForSkillLevel(skillLevel, skillName)
  local nowPercentage = user:GetSkillExperience(skillName) * 0.01
  local nowPoints = nowPercentage * requiredPoints
  nowPoints = nowPoints + n
  local newPercentage = nowPoints / requiredPoints
  user:SetSkillExperience(skillName, newPercentage * 100.0)
  if newPercentage >= 1.0 then
    user:IncrementSkill(skillName)
    FixExp(user)
  end
end

function Leveling.OnUserCraftItem(user, itemType, count)
  if (itemType:GetClass() == "Weapon" or itemType:GetClass() == "Armor") and itemType:GetEnchantment() == nil then
    AddSkillPoints(user, "Smithing", 25 * count)
  elseif itemType:GetClass() == "Potion" then
    AddSkillPoints(user, "Alchemy", 31 * count)
  elseif (itemType:GetClass() == "Weapon" or itemType:GetClass() == "Armor") and itemType:GetEnchantment() ~= nil then -- is ench
    AddSkillPoints(user, "Enchanting", 33 * count)
  end
  return true
end

function Leveling.OnHit(source, target, weap, ammo, spell)
  if target:is_a(User) then
    if target:IsBlocking() then
      AddSkillPoints(target, "Block", 34)
    end
  end
  if source:is_a(User) then
    local user = source
    if weap ~= nil then
      if ammo ~= nil then
        AddSkillPoints(user, "Marksman", 29)
      elseif weap:GetSkillName() == "OneHanded" then
        AddSkillPoints(user, "OneHanded", 24)
      elseif weap:GetSkillName() == "TwoHanded" then
        AddSkillPoints(user, "TwoHanded", 26)
      end
    end
  end
  return true
end

function Leveling.OnUserBowShot(user, power)
  AddSkillPoints(user, "Marksman", 2 + (power / 20))
  return true
end

function Leveling.OnUserUseItem(user, itemType)
  if itemType:GetSubclass() == "Lockpick" then
    AddSkillPoints(user, "Lockpicking", 50)
  end
  if itemType:GetEnchantment() ~= nil then
    AddSkillPoints(user, "Enchanting", 99)
  end
  return true
end

function Leveling.OnUserChatCommand(user, cmdtext)
  return true
end

function Leveling.OnUserChatMessage(user, msg)
  AddSkillPoints(user, "Speechcraft", 1)
  return true
end

function Leveling.OnUserLearnPerk(user, perk)
  return true
end

return Leveling
