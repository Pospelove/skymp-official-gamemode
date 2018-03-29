DebugMiroslav = {}

local gMiroslavUser = nil
local gPlacedIds = {}
local gUndoFunctionsStack = {}

local gNpcPlaceCommands = {
  ["/k"] = {0x0004359C, 0x0004359C, 0x0004359C}, -- ����
  ["/kor"] = "������",
  ["/kur"] = 0x000A91A0, -- ������
  ["/s"] = "������",
  ["/dk"] = {0x0002EBE2, 0x0002EBE2, 0x0002EBE2}, -- ����� ����
  ["/kr"] = 0x0006DC9D, -- Krolik
  ["/l"] = 0x000829B3, -- Lisitsa
  ["/sl"] = 0x000829B6, -- Snow lisa
  ["/m"] = "������",
  ["/ol"] = "�����",

  ["/me"] = "�������",
  ["/bme"] = "����� �������",
  ["/pme"] = "�������� �������",
  ["/v"] = {"����", "����", "����"},
  ["/sv"] = {"������� ����", "������� ����", "������� ����"},
  ["/sab"] = "��������",
  ["/ssab"] = "������� ��������",
  ["/gk"] = 0x000E4010, -- krab
  ["/gk1"] = 0x000E4010, -- krab
  ["/gk2"] = 0x000E4011, -- krab
  ["/gk3"] = 0x00021875, -- krab
  ["/zl"] = "�������",
  ["/hr"] = "������",
  ["/tr"] = "������",
  ["/ltr"] = "������� ������",
  ["/vel"] = "�������",
  ["/spr"] = "��������",
  ["/vor"] = "�������",
  ["/fal"] = "������",
  ["/lpr"] = "������� ����������",
  ["/dmk"] = { 0x0002C3C7, 0x0002C3C7, 0x0002C3C7, 0x00023ABD }, -- ���� ����� � 3 �����
  ["/dra"] = "������",
  ["/bdra"] = "���������� ������",
  ["/dpr"] = "������-�������",
  ["/dpa"] = "������-�����",
  ["/dgp"] = "������ - ������� �����",
  ["/dp"] = "������-����������",
  ["/dv"] = "������-������������",
  ["/dgv"] = "������ - ������� ������������",
  ["/skel"] = "������",
  ["/morp"] = "�������� ����",
  ["/dvp"] = "���������� ����",
  ["/dvsf"] = 0x0010ec89, -- dwemer sphere
  ["/ds"] = 0x0010ec89, -- dwemer sphere
  ["/nds"] = 0x0010ec89, -- dwemer sphere
  ["/dss"] = 0x0010ec89, -- dwemer sphere
  ["/dsm"] = 0x0010ec89, -- dwemer sphere
  ["/zs"] = 0x0010ec89, -- dwemer sphere
  ["/dvce"] = "���������� ���������",
  ["/dc"] = "���������� ���������",
  ["/dcs"] = "���������� ���������",
  ["/dcm"] = "���������� ���������",
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
  user:SendChatMessage(Theme.success  .. "�������� " .. Theme.success .. str .. " ��������")
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
    user:SendChatMessage(Theme.success  .. "�������� " .. Theme.success .. str .. " �����")
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

  local tokens = stringx.split(cmd)

  if tokens[1] == "/droprange" or tokens[1] == "/dr" then
    if not tokens[2] then tokens[2] = "Delete" end
    local m = 20.0
    local units =  m * 70.0
    user:SendChatMessage("��������� ����� � ������� " .. m .. " ������...")
    local t = (NPC.GetAllNPCs())
    local n = 0
    for i = 1, #t do
      local npc = t[i]
      local npcX = npc:GetValue("x")
      local npcY = npc:GetValue("y")
      local npcZ = npc:GetValue("z")
      local plX = user:GetX()
      local plY = user:GetY()
      local plZ = user:GetZ()
      local sqr = function(x) return x * x end
      local d = math.sqrt(sqr(npcX - plX) + sqr(npcY - plY) + sqr(npcZ - plZ))
      if d < units then
        n = n + 1
        SetTimer(1, function()
          npc:Save()
          local f = npc[tokens[2]]
          local success = pcall(function() f(npc) end)
          if not success then user:SendChatMessage(Theme.error .. tokens[2] .. " - ������� �� �������") end
        end)
      end
    end
    if tokens[2] == "Delete" then
      user:SendChatMessage(Theme.success .. "������� " .. n .. " �����������")
    else
      user:SendChatMessage(Theme.success .. "������� �������� " .. tokens[2] .. " ��� " .. n .. " �����������")
    end
  end
  if cmd == "/ignore" then
    AI.IgnoreUser(user)
    user:SendChatMessage(Theme.success .. "���������� NPC ������ ���������� ���� �����������")
  end
  if cmd == "/undo" then
    if #gUndoFunctionsStack == 0 then
      user:SendChatMessage(Theme.error .. "��� �������� ��� ������")
      return true
    end
    local f = table.remove(gUndoFunctionsStack)
    if f then f() end
    return true
  end

  for command, result in pairs(gNpcPlaceCommands) do
    if command == tokens[1] then
      gMiroslavUser = user
      PlaceNPC(result)
      user:SendChatMessage(Theme.success .. "������")
    end
  end

  return true
end

return DebugMiroslav
