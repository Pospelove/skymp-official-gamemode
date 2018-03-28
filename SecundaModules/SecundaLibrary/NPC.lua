NPC = class()

local gRaw = dsres.npc

function NPC.Docs()
  return [[
  -- Static methods:
  NPC.IsFileNameInUse(fileName) -- Check if file name is already used for npc
  NPC.Lookup(id) -- Lookup npc by id
  NPC.Create(fileName) --
  NPC.GetAllNPCs() --

  -- Methods:
  npc:GetFileName() --
  npc:Load() --
  npc:Save() --
  npc:Unload() -- Remove model from the world
  npc:SetValue(varName, newValue) -- Set value varName to newValue
  npc:GetValue(varName) -- Get value varName
  npc:GetData() -- Get table with all of npc data
  npc:SetData(newData) -- Assign npc data to newData and apply

  -- Values:
  data = {
    baseID,
    x,
    y,
    z,
    angleZ,
    locationID,
    virtualWorld
  }

  -- Callbacks:
  OnActivate(npc, target) --
  OnNPCSpawn(npc) --
  OnNPCDying(npc) --
  ]]
end

-- Private variables

local gNpcs = {}
local gInvisibleChests = {}

-- Public

function NPC.IsFileNameInUse(fileName)
  if type(fileName) ~= "string" then
    error("fileName is " .. type(fileName))
  end
  for i = 1, #gNpcs do
    local npc = gNpcs[i]
    if npc ~= nil then
      if npc:GetFileName() == fileName then
        return true
      end
    end
  end
  return false
end

-- TODO: fix this function
function NPC.Lookup(id)
  local pl = Player.LookupByID(id)
  if pl ~= nil then
    for i = 1, #gNpcs do
      local npc = gNpcs[i]
      if npc ~= nil and npc.pl ~= nil and npc.pl:GetID() == id then -- attempt to index field 'pl' (function value)
        return npc
      end
    end
  end
  return nil
end

function NPC:GetFileName()
  return self.fileName
end

function NPC.GetAllNPCs()
  return gNpcs
end

function NPC:Load()
  return Loadable.Load(self, "npcs")
end

function NPC:Save()
  return Loadable.Save(self, "npcs")
end

function NPC:Unload()
  if self.pl ~= nil then
    self.pl:Kick()
    self.pl = nil
  end
end

function NPC:Delete()
  local newNpcs = {}
  for i = 1, #gNpcs do
    if gNpcs[i] ~= self then
      table.insert(newNpcs, gNpcs[i])
    else
      self:Save()
      self:Unload()
    end
  end
  gNpcs = newNpcs
  NPC._SaveFileNames()
end

function NPC.DeleteAll() -- Soft
  -- Unload (destroy) all
  for i = 1, #gNpcs do
    local npc = gNpcs[i]
    if npc ~= nil then
      npc:Unload()
    end
  end
  -- Rewrite worldobjects.json with empty file
  gNpcs = {}
  NPC._SaveFileNames()
end

function NPC:SetValue(varName, newValue)
  self:_PrepareDataToSave()
  self.data[varName] = newValue
  self:_ApplyData()
end

function NPC:GetValue(varName)
  self:_PrepareDataToSave()
  return self.data[varName]
end

function NPC:GetData()
  self:_PrepareDataToSave()
  return tablex.deepcopy(self.data)
end

function NPC:SetData(data)
  self.data = tablex.deepcopy(data)
  self:_ApplyData()
end

function NPC.Create(fileName)
  local npc = NPC(fileName)
  NPC._SaveFileNames()
  return npc
end

-- IMPLEMENTATION

local function NewData()
  return {
    baseID = 0,
    x = 0,
    y = 0,
    z = 0,
    angleZ = 0,
    locationID = 0,
    virtualWorld = 0
  }
end

function NPC:_init(fileName)
  if type(fileName) ~= "string" then
    erorr("filename is " .. type(filename) .. ", not string")
  end
  self.data = NewData()
  self.fileName = fileName
  self.pl = nil
  table.insert(gNpcs, self)
end

local function FindRandomBandit(isIsgoy)
  local n = #dsres.npc
  while true do
    local i = math.random(1, n)
    local entry = dsres.npc[i]
    if entry then
      local isUnique = (entry[5] == 1)
      local race = entry[3]
      local baseID = entry[1]
      if isUnique then
        if race == "NordRace" or race == "OrcRace" or race == "RedguardRace" or race == "BretonRace" or race == "KhajiitRace"  or race == "ArgonianRace" or race == "WoodElfRace" or race == "DarkElfRace" then
          if not isIsgoy then return baseID end
        end
        if race == "BretonRace" and isIsgoy then return baseID end
      end
    end
  end
end

function NPC:_ApplyData()
  local isRandomBandit = false
  if self.pl == nil or self.baseID ~= self.data.baseID then
    if self.data.baseID == 0x00032860 or self.data.baseID == 0x0007EB38 or self.data.baseID == 0x00023AA9 then -- bandit naebnik isgoy
      self.isIsgoy = (self.data.baseID == 0x00023AA9)
      self.data.baseID = FindRandomBandit(self.isIsgoy)
      isRandomBandit = true
    end
    self.pl = Player.CreateNPC(self.data.baseID)
    self.baseID = self.data.baseID
  end
  self.pl:SetName(ru(tostring(self.data.name)))
  if deru(self.pl:GetName()) == "�����" or deru(self.pl:GetName()) == "������" or deru(self.pl:GetName()) == "�������" or deru(self.pl:GetName()) == "������" then
    isRandomBandit = true
    if deru(self.pl:GetName()) == "�����" then
      self.isIsgoy = true
    end
    if deru(self.pl:GetName()) == "�������" or deru(self.pl:GetName()) == "������" then
      self.isNaemnik = true
    end
  end
  self.pl:SetPos(self.data.x, self.data.y, self.data.z)
  self.pl:SetAngleZ(self.data.angleZ)
  local loc = Location(self.data.locationID)
  if self.pl:GetLocation() ~= loc then
    self.pl:SetSpawnPoint(loc, self.data.x, self.data.y, self.data.z, self.data.angleZ)
    self.pl:Spawn()
  end
  self.pl:SetVirtualWorld(self.data.virtualWorld)
  -- Inventory:
  self.pl:RemoveAllItems()
  NPCLoot.FillContainer(self)
  if isRandomBandit then
    local add = function(a, b)
      self.pl:AddItem(ItemTypes.Lookup(a), b)
      self.pl:EquipItem(ItemTypes.Lookup(a), 0)
    end
    if self.isIsgoy then
      add(0x000EAFD0, 1)
      add("������ ������", 1)
      add("�������� ������", 1)
      add("�������� ���� ������", 1)
      add("��� ������", 1)
    elseif self.isNaemnik then
      local r = math.random(0, 100)
      if r > 70 then
        add("�������� ���", 1)
      elseif r > 50 then
        add("�������� ������", 1)
      elseif r > 30 then
        add("�������� ������", 1)
      else
        add("�������� ������ �����", 1)
      end
      r = math.random(0, 100)
      if r > 90 then
        add("�������� ������������ �����", 1)
        add("�������� ������������ ������", 1)
        add("�������� ������������ ��������", 1)
        add("�������� ������������ ����", 1)
      elseif r > 30 then
        add("�������� �����", 1)
        add("�������� ������", 1)
        add("�������� ������", 1)
        add("�������� ����", 1)
      else
        add("�������� �����", 1)
        add("�������� ������ � �������", 1)
        add("�������� ������", 1)
        if math.random(0, 1) == 1 then
          add("�������� ����", 1)
        else
          add("�������� ������� ����", 1)
        end
      end
    else
      local r = math.random(0, 100)
      if math.random(0, 2) == 2 then add("����������� �����", 1) else add("���������� �����", 1) end
      add("���������� ������", 1)
      add("���������� ������", 1)
      if math.random(0, 10) > 8 then
        add("�������", 1)
      else
        if math.random(0, 2) == 0 then add("������� ����", 1) else add("���������� ����", 1) end
      end
      if r > 90 then
        add("�������� ���", 1)
      elseif r > 80 then
        add("���������� ������", 1)
      elseif r > 70 then
        add("�������� ������", 1)
      elseif r > 60 then
        add("�����", 1)
      elseif r > 50 then
        add("�������� ������ �����", 1)
      elseif r > 40 then
        add("�������� ���", 1)
      elseif r > 30 then
        add("�������� ������", 1)
      elseif r > 20 then
        add("�������� ���", 1)
      elseif r > 10 then
        add("�������� ������ �����", 1)
      else
        add("�������� ��������� ���", 1)
      end

    end
    self.isRandomBandit = true
  else
    for i = 1, #dsres.npc do
      local entry = dsres.npc[i]
      if entry then
        if self.data.baseID == entry[1] then
          local invent = entry[4]
          for iden, n in pairs(invent) do
            local itemType = ItemTypes.Lookup(iden)
            if itemType then
              self.pl:AddItem(itemType, n)
            end
          end
        end
      end
    end
  end
end

function NPC:_PrepareDataToSave()
  if self.pl ~= nil then
    self.data.x = math.floor(self.pl:GetX())
    self.data.y = math.floor(self.pl:GetY())
    self.data.z = math.floor(self.pl:GetZ())
    self.data.angleZ = math.floor(self.pl:GetAngleZ())
    local loc = self.pl:GetLocation()
    if loc ~= nil then
      self.data.locationID = loc:GetID()
    end
    self.data.virtualWorld = self.pl:GetVirtualWorld()
    self.data.name = self.pl:GetName()
  end
end

function NPC._SaveFileNames()
  return FilesList.SaveFileNames(gNpcs, "npcs")
end


function NPC._LoadFileNames()
  return FilesList.LoadFileNames("npcs")
end

function NPC._LoadAll()
  local fileNames = NPC._LoadFileNames()
  print("")
  print("Loading " .. #fileNames .. " NPCs")
  local clock = GetTickCount()
  for i = 1, #fileNames do
    local fileName = fileNames[i]
    if fileName ~= "dummy" then
      local npc = NPC(fileName)
      npc:Load()
    end
  end
  print("Done in " .. (GetTickCount() - clock) .. "ms")
end

function NPC:__index(key)
  if self ~= nil then
    return NPC._Index(self, key)
  end
end

function NPC._HasOverride(key)
  local hasOverride = {
  }
  return hasOverride[key]
end

function NPC._Index(self, key)
  local result = rawget(self, key)
  if result == nil then
    result = function(badSelf, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
      local success
      local pcallResult
      local foundMethodInPlayer = false
      if not NPC._HasOverride(key) then
        success, pcallResult = pcall(function()
          return self.pl[key](self.pl, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
        end)
        foundMethodInPlayer = success
      end
      if foundMethodInPlayer then
        return pcallResult
      else
        local indexBackup = NPC.__index
        NPC.__index = NPC
        local hasFunction, err = pcall(function()
          pcallResult = self[key](badSelf, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
        end)
        NPC.__index = indexBackup
        if not hasFunction then
          error("error when calling '" .. key .. "'" .. ":" .. " " .. err)
        end
        return pcallResult
      end
    end
  end

  return result
end

local function PrepareDsres()
  return true
end

-- Callbacks

function NPC.OnServerInit()
  NPC._LoadAll()
  PrepareDsres()
  return true
end

function NPC.OnPlayerActivateObject(pl, object)
  if pl:IsNPC() then
    local npc = NPC.Lookup(pl:GetID())
    if npc ~= nil then
      local wo = WorldObject.Lookup(object:GetID())
      if wo ~= nil then
        return Secunda.OnActivate(npc, wo)
      end
    end
  end
  return true
end

function NPC.OnPlayerActivatePlayer(pl, targetPl)
  if not pl:IsNPC() and targetPl:IsNPC() then
    local npc = NPC.Lookup(targetPl:GetID())
    local user = User.Lookup(pl:GetID())
    if npc and user then
      if npc:GetCurrentAV("health") == 0 then
        local loot = gInvisibleChests[npc:GetID()]
        loot:SetPos(user:GetX(), user:GetY(), user:GetZ() - 128)
        loot:Activate(pl)
      end
      return Secunda.OnActivate(user, npc)
    end
  end
  return true
end

function NPC.OnPlayerDying(pl, killer)
  if pl:IsNPC() then
    local npc = NPC.Lookup(pl:GetID())
    if npc ~= nil then
      Secunda.OnNPCDying(npc)
      local obj = Object.Create(0, 0xaf6ae, pl:GetLocation(), pl:GetX(), pl:GetY(), pl:GetZ() - 1024)
      if obj == nil then
        error("unable to create invisible chest")
      end
      obj:RegisterAsContainer()
      obj:SetName(pl:GetName())
      SetTimer(1000, function() -- Prevents doubling items
        Container(pl):ApplyTo(obj)
        --if npc.isRandomBandit then
        --  obj:RemoveAllItems()
        --  obj:AddItem(pl:GetEquippedWeapon(0), 1)
        --end
      end)
      if gInvisibleChests[pl:GetID()] ~= nil then
        gInvisibleChests[pl:GetID()]:Delete()
        gInvisibleChests[pl:GetID()] = nil
      end
      gInvisibleChests[pl:GetID()] = obj
    end
  end
  return true
end

function NPC.OnPlayerChangeContainer(pl, cont, itemType, count, isAdd)
  if not isAdd and (itemType:GetClass() == "Weapon" or itemType:GetClass() == "Armor") then
    for ownerNpcID, loot in pairs(gInvisibleChests) do
      if loot:GetID() == cont:GetID() then
        local npcRaw = Player.LookupByID(ownerNpcID)
        if npcRaw and npcRaw:IsNPC() then
          if npcRaw:IsEquipped(itemType) then
            for handID = -1, 1 do npcRaw:UnequipItem(itemType, handID) end
          end
        end
        break
      end
    end
  end
  return true
end

function NPC.OnPlayerDisconnect(pl)
  if gInvisibleChests[pl:GetID()] ~= nil then
    gInvisibleChests[pl:GetID()]:Delete()
    gInvisibleChests[pl:GetID()] = nil
  end
  return true
end

function NPC.OnPlayerSpawn(pl)
  if pl:IsNPC() then
    local npc = NPC.Lookup(pl:GetID())
    if npc then
      return Secunda.OnNPCSpawn(npc)
    end
  end
  return true
end

return NPC
