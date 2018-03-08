DebugMiroslav = {}

local gMiroslavUser = nil
local gPlacedIds = {}
local gUndoFunctionsStack = {}

local gNpcPlaceCommands = {
  ["/k"] = {0x0004359C, 0x0004359C, 0x0004359C}, -- Коза
  ["/kor"] = "Корова",
  ["/kur"] = 0x000A91A0, -- Курица
  ["/s"] = "Собака",
  ["/dk"] = {0x0002EBE2, 0x0002EBE2, 0x0002EBE2}, -- Дикая коза
  ["/kr"] = 0x0006DC9D, -- Krolik
  ["/l"] = 0x000829B3, -- Lisitsa
  ["/sl"] = 0x000829B6, -- Snow lisa
  ["/m"] = "Мамонт",
  ["/ol"] = "Олень",

  ["/me"] = "Медведь",
  ["/bme"] = "Белый медведь",
  ["/pme"] = "Пещерный медведь",
  ["/v"] = {"Волк", "Волк", "Волк"},
  ["/sv"] = {"Снежный волк", "Снежный волк", "Снежный волк"},
  ["/sab"] = "Саблезуб",
  ["/ssab"] = "Снежный саблезуб",
  ["/gk"] = 0x000E4010, -- krab
  ["/gk1"] = 0x000E4010, -- krab
  ["/gk2"] = 0x000E4011, -- krab
  ["/gk3"] = 0x00021875, -- krab
  ["/zl"] = "Злокрыс",
  ["/hr"] = "Хоркер",
  ["/tr"] = "Тролль",
  ["/ltr"] = "Ледяной тролль",
  ["/vel"] = "Великан",
  ["/spr"] = "Спригган",
  ["/vor"] = "Ворожея",
  ["/fal"] = "Фалмер",
  ["/lpr"] = "Ледяное привидение",
  ["/dmk"] = { 0x0002C3C7, 0x0002C3C7, 0x0002C3C7, 0x00023ABD }, -- Мать дымок и 3 дымка
  ["/dra"] = "Драугр",
  ["/skel"] = "Скелет",
  ["/morp"] = "Морозный паук",
  ["/dvp"] = "Двемерский паук",
  ["/dvsf"] = 0x0010ec89, -- dwemer sphere
  ["/dvce"] = "Двемерский центурион",
  ["/b"] = {0x00032860,0x00032860,0x00032860,0x00032860,0x00032860},
  ["/n"] = {0x0007EB38,0x0007EB38,0x0007EB38,0x0007EB38,0x0007EB38},
  ["/i"] = {0x00023AA9,0x00023AA9,0x00023AA9,0x00023AA9,0x00023AA9}
}

local function FindNPCIDByName(name)
  for i = 1, #dsres.npc do
    local entry = dsres.npc[i]
    if entry then
      if entry[2] == name then
        return entry[1]
      end
    end
  end
end

local function FindNPCNameByID(id)
  for i = 1, #dsres.npc do
    local entry = dsres.npc[i]
    if entry then
      if entry[1] == id then
        return entry[2]
      end
    end
  end
end

local function PlaceNPC(key)
  local user = gMiroslavUser
  if type(key) == "string" then key = FindNPCIDByName(key) end
  if type(key) == "table" then
    for i = 1, #key do PlaceNPC(key[i]) end
    return
  end
  local str = tostring(FindNPCNameByID(key))
  user:SendChatMessage(Theme.success  .. "Персонаж " .. Theme.success .. str .. " создаётся")
  local rawRes = user
  local fileName = tostring(math.random(0, 2000000000))
  fileName = fileName:gsub("%.", "")
  local npc = NPC.Create(fileName)
  npc:SetValue("baseID", key)
  npc:SetValue("x", rawRes:GetX() + math.random(-256, 256))
  npc:SetValue("y", rawRes:GetY() + math.random(-256, 256))
  npc:SetValue("z", rawRes:GetZ() + math.random(0, 32))
  npc:SetValue("angleZ", rawRes:GetAngleZ())
  if rawRes:GetLocation() == nil then
    error("bad actor locaiton")
  end
  npc:SetValue("locationID", rawRes:GetLocation():GetID())
  npc:SetValue("virtualWorld", rawRes:GetVirtualWorld())
  npc:SetValue("name", str)
  npc:Save()
  gPlacedIds[npc:GetID()] = true
  table.insert(gUndoFunctionsStack, function()
    npc:Delete()
    user:SendChatMessage(Theme.success  .. "Персонаж " .. Theme.success .. str .. " удалён")
  end)
  return true
end

function DebugMiroslav.IsPlacedID(playerid) -- public
  return not not gPlacedIds[playerid]
end

function DebugMiroslav.OnUserChatCommand(user, cmd)
  if not Debug.IsDeveloper(user) then
    return true
  end
  if cmd == "/ignore" then
    AI.IgnoreUser(user)
    user:SendChatMessage(Theme.success .. "Враждебные NPC теперь игнорируют Ваше присутствие")
  end
  if cmd == "/undo" then
    if #gUndoFunctionsStack == 0 then
      user:SendChatMessage(Theme.error .. "Нет действий для отмены")
      return true
    end
    local f = table.remove(gUndoFunctionsStack)
    if f then f() end
    return true
  end
  local tokens = stringx.split(cmd)
  for command, result in pairs(gNpcPlaceCommands) do
    if command == tokens[1] then
      gMiroslavUser = user
      PlaceNPC(result)
      user:SendChatMessage(Theme.success .. "Готово")
    end
  end

  return true
end

return DebugMiroslav
