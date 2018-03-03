NPC = class()

local gRaw = dsres.npc

function NPC.Docs()
  return [[
  -- Static methods:
  NPC.IsFileNameInUse(fileName) -- Check if file name is already used for npc
  NPC.Lookup(id) -- Lookup npc by id
  NPC.Create(fileName) --

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

function NPC.Lookup(id)
  local pl = Player.LookupByID(id)
  if pl ~= nil then
    for i = 1, #gNpcs do
      local npc = gNpcs[i]
      if npc ~= nil and npc.pl ~= nil and npc.pl:GetID() == id then
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

function NPC:_ApplyData()
  if self.pl == nil or self.baseID ~= self.data.baseID then
    self.pl = Player.CreateNPC(self.data.baseID)
    self.baseID = self.data.baseID
  end
  self.pl:SetName(ru(tostring(self.data.name)))
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
  for i = 1, #dsres.npc do
    local entry = dsres.npc[i]
    if entry then
      if self.data.baseID == entry[1] then
        local invent = entry[4]
        for iden, n in pairs(invent) do
          local itemType = ItemTypes.Lookup(iden)
          if itemType then
            self.pl:AddItem(itemType, n)
            print("added item to npc")
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
      local obj = Object.Create(0, 0xaf6ae, pl:GetLocation(), pl:GetX(), pl:GetY(), pl:GetZ() - 1024)
      if obj == nil then
        error("unable to create invisible chest")
      end
      obj:RegisterAsContainer()
      obj:SetName(pl:GetName())
      SetTimer(1000, function() Container(pl):ApplyTo(obj) end) -- Prevents doubling items
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

return NPC
