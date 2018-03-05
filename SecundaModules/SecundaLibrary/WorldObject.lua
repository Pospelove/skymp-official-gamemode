WorldObject = class()

function WorldObject.Docs()
  return [[
  -- Static methods:

  -- Methods:

  -- Callbacks:
  OnWorldObjectRender(wo) --
  ]]
end

-- Private variables

local gWos = {}
local gWosByRefID = {}

-- Public

function WorldObject.IsFileNameInUse(fileName)
  if type(fileName) ~= "string" then
    error("fileName is " .. type(fileName))
  end
  for i = 1, #gWos do
    local wo = gWos[i]
    if wo ~= nil then
      if wo:GetFileName() == fileName then
        return true
      end
    end
  end
  return false
end

function WorldObject.Lookup(id)
  return gWosByRefID[id]
end

function WorldObject.GetAllWorldObjects()
  return gWos
end

function WorldObject:GetFileName()
  return self.fileName
end

function WorldObject:Load()
  return Loadable.Load(self, "worldobjects")
end

function WorldObject:Save()
  return Loadable.Save(self, "worldobjects")
end

function WorldObject:Unload()
  if self.obj ~= nil then
    self.obj:Delete()
    self.obj = nil
  end
end

local function SetHarvestedForPlayer(obj, pl)
  pl:ExecuteCommand("Skymp", "Activate(" .. obj:GetID() .. ")")
end

function WorldObject:SetValue(varName, newValue)
  self:_PrepareDataToSave()
  self.data[varName] = newValue
  self:_ApplyData()
  if varName == "isHarvested" and self.obj ~= nil then
    for i = 0, GetMaxPlayers() do
      local pl = Player.LookupByID(i)
      if pl ~= nil and newValue then
        SetHarvestedForPlayer(self.obj, pl)
      end
    end
  end
end

function WorldObject:GetValue(varName)
  self:_PrepareDataToSave()
  return self.data[varName]
end

function WorldObject:GetData()
  self:_PrepareDataToSave()
  return tablex.deepcopy(self.data)
end

function WorldObject:SetData(data)
  self.data = tablex.deepcopy(data)
  self:_ApplyData()
end

function WorldObject:ResetFor(user)
  if self.obj ~= nil then
    self.obj:ResetFor(user.pl)
  end
end

function WorldObject.Create(fileName, optionalRawObject)
  local wo = WorldObject(fileName, optionalRawObject)
  WorldObject._TaskSaveFileNames()
  return wo
end

function WorldObject:Delete()
  local newWos = {}
  for i = 1, #gWos do
    if gWos[i] ~= self then
      table.insert(newWos, gWos[i])
    else
      self:Save()
      self:Unload()
    end
  end
  gWos = newWos
  WorldObject._SaveFileNames()
end

function WorldObject.DeleteAll() -- Soft
  -- Unload (destroy) all
  for i = 1, #gWos do
    local wo = gWos[i]
    if wo ~= nil then
      wo:Unload()
    end
  end
  -- Rewrite worldobjects.json with empty file
  gWos = {}
  WorldObject._SaveFileNames()
end

function WorldObject:IsBlacksmithForge()
  return self.data.baseID == 0x000D932F
end

function WorldObject:IsAlchemy()
  return self.data.baseID == 0x000BAD0C or self.data.baseID == 0x000D54FF
end

function WorldObject:IsEnchanting()
  return self.data.baseID == 0x000BAD0D or self.data.baseID == 0x000D5501
end

function WorldObject:IsCooking()
  return self.data.baseID == 0x00068ADB or self.data.baseID == 0x0010BFE3 or self.data.baseID == 0x00104110 or self.data.baseID == 0x001010B3 or self.data.baseID == 0x00108203
end

-- IMPLEMENTATION

local function NewData()
  return {
    baseID = 0,
    refID = 0,
    x = 0,
    y = 0,
    z = 0,
    angleX = 0,
    angleY = 0,
    angleZ = 0,
    locationID = 0,
    virtualWorld = 0,
    lockLevel = 0,
    isOpen = false,
    type = "Static",
    numActivates = 0,
    isDisabled = false,
    isHarvested = false
  }
end

function WorldObject._TaskSaveFileNames()
  WorldObject._SaveFileNamesTask = function()
    WorldObject._SaveFileNames()
    print("WorldObject filenames saved")
  end
  if WorldObject._Every4000ms == nil then
    WorldObject._Every4000ms = function()
      if WorldObject._SaveFileNamesTask ~= nil then
        WorldObject._SaveFileNamesTask()
        WorldObject._SaveFileNamesTask = nil
      end
      SetTimer(4000, WorldObject._Every4000ms)
    end
    WorldObject._Every4000ms()
  end
end

function WorldObject:_init(fileName, optionalRawObject)
  if type(fileName) ~= "string" then
    erorr("filename is " .. type(filename) .. ", not string")
  end
  self.data = NewData()
  self.obj = optionalRawObject
  if self.obj ~= nil then
    self:_PrepareDataToSave()
  end
  self.fileName = fileName
  table.insert(gWos, self)
end

function WorldObject:_ApplyData()
  if self.obj == nil or self.data.baseID ~= self.obj:GetBaseID() then
    if self.obj ~= nil then
      self.obj:SetDisabled(true)
      self.obj:Delete()
      self.obj = nil
    end
    self.obj = Object.Create(self.data.refID < 0xFF000000 and self.data.refID or 0, self.data.baseID, Location(self.data.locationID), self.data.x, self.data.y, self.data.z)
    if self:IsBlacksmithForge() then
      self.data.type = "Furniture"
      self.obj:AddKeyword("isBlacksmithForge")
  		self.obj:AddKeyword("CraftingSmithingForge")
  		self.obj:AddKeyword("FurnitureForce3rdPerson")
  		self.obj:AddKeyword("FurnitureSpecial")
  		self.obj:AddKeyword("RaceToScale")
  		self.obj:AddKeyword("WICraftingSmithing")
    end
    if self:IsAlchemy() then
      self.data.type = "Furniture"
      self.obj:AddKeyword("FurnitureForce3rdPerson")
  		self.obj:AddKeyword("FurnitureSpecial")
  		self.obj:AddKeyword("isAlchemy")
  		self.obj:AddKeyword("RaceToScale")
  		self.obj:AddKeyword("WICraftingAlchemy")
    end
    if self:IsEnchanting() then
      self.data.type = "Furniture"
      self.obj:AddKeyword("FurnitureForce3rdPerson")
  		self.obj:AddKeyword("FurnitureSpecial")
  		self.obj:AddKeyword("isEnchanting")
  		self.obj:AddKeyword("RaceToScale")
  		self.obj:AddKeyword("WICraftingEnchanting")
    end
    if self:IsCooking() then
      print("creating cooking spit")
      self.data.type = "Furniture"
      self.obj:AddKeyword("CraftingCookpot")
      self.obj:AddKeyword("FurnitureForce3rdPerson")
  		self.obj:AddKeyword("FurnitureSpecial")
  		self.obj:AddKeyword("isCookingSpit")
  		self.obj:AddKeyword("RaceToScale")
    end
  end
  if self.obj ~= nil then
    if self.data.type == "Static" then
      -- Do nothing
    elseif self.data.type == "Door" then
      self.obj:RegisterAsDoor()
    elseif self.data.type == "TeleportDoor" then
      local target = Object.LookupByID(self.data.teleportTarget)
      if target ~= nil then
        self.obj:RegisterAsTeleportDoor(target)
        target:RegisterAsTeleportDoor(self.obj)
      end
    elseif self.data.type == "Activator" or self.data.type == "Item" then
      self.obj:RegisterAsActivator()
    elseif self.data.type == "Container" then
      self.obj:RegisterAsContainer()
    elseif self.data.type == "Furniture" then
      self.obj:RegisterAsFurniture()
    end
    if self.data.isDisabled then
      self.obj:SetPos(self.data.x, self.data.y, self.data.z - 2048)
    else
      self.obj:SetPos(self.data.x, self.data.y, self.data.z)
    end
    self.obj:SetAngle(self.data.angleX, self.data.angleY, self.data.angleZ)
    self.obj:SetLocation(Location(self.data.locationID))
    if self.data.virtualWorld ~= nil then -- virtualWorld is nil for native objects
      self.obj:SetVirtualWorld(self.data.virtualWorld)
    end
    self.obj:SetLockLevel(self.data.lockLevel)
    self.obj:SetOpen(self.data.isOpen)
    self.obj:SetDisabled(self.data.isDisabled)
    local s, errorStr = pcall(function()
      if self.data.inventoryStr ~= nil then
        ContainerSerializer.Deserialize(self.data.inventoryStr):ApplyTo(self.obj)
      end
    end)
    if not s then print("Error while loading container: " .. errorStr) end
  end
  self:_PrepareDataToSave()
end

function WorldObject:_PrepareDataToSave()
  if self.obj == nil then
    return
  end
  self.data.baseID = self.obj:GetBaseID()
  self.data.refID = self.obj:GetID()
  gWosByRefID[self.data.refID] = self
  self.data.type = self.obj:GetType()
  if self.obj:IsDisabled() == false then
    self.data.x = math.floor(self.obj:GetX())
    self.data.y = math.floor(self.obj:GetY())
    self.data.z = math.floor(self.obj:GetZ())
  end
  self.data.angleX = math.floor(self.obj:GetAngleX())
  self.data.angleY = math.floor(self.obj:GetAngleY())
  self.data.angleZ = math.floor(self.obj:GetAngleZ())
  self.data.locationID = self.obj:GetLocation() and self.obj:GetLocation():GetID() or 0
  self.data.virtualWorld = self.obj:GetVirtualWorld()
  self.data.lockLevel = self.obj:GetLockLevel()
  self.data.isOpen = self.obj:IsOpen()
  self.data.isDisabled = self.obj:IsDisabled()
  if self.obj:GetTeleportTarget() ~= nil then
    self.data.teleportTarget = self.obj:GetTeleportTarget():GetID()
  end
  self.data.inventoryStr = ContainerSerializer.Serialize(Container(self.obj))
end

function WorldObject._SaveFileNames()
  return FilesList.SaveFileNames(gWos, "worldobjects")
end


function WorldObject._LoadFileNames()
  return FilesList.LoadFileNames("worldobjects")
end

function WorldObject._LoadAll()
  local fileNames = WorldObject._LoadFileNames()
  print("")
  print("Loading " .. #fileNames .. " objects")
  local clock = GetTickCount()
  for i = 1, #fileNames do
    local fileName = fileNames[i]
    if fileName ~= "dummy" then
      local wo = WorldObject(fileName)
      wo:Load()
    end
  end
  print("Done in " .. (GetTickCount() - clock) .. "ms")
end

function WorldObject.OnServerInit()
  WorldObject._LoadAll()
  return true
end

function WorldObject.OnPlayerActivateObject(pl, obj)
  local wo = WorldObject.Lookup(obj:GetID())
  if wo == nil then return true end
  if type(wo.data.numActivates) == "number" then
    wo.data.numActivates = wo.data.numActivates + 1
  else
    wo.data.numActivates = 1
  end
  wo:Save()
  return true
end

function WorldObject.OnPlayerStreamInObject(pl, obj)
  if pl:IsNPC() == false then
    local wo = WorldObject.Lookup(obj:GetID())
    if wo ~= nil then
      if wo:GetValue("isHarvested") then
        SetTimer(500, function() SetHarvestedForPlayer(obj, pl) end)
      end
      if wo:IsBlacksmithForge() then
        local user = User.Lookup(pl:GetID())
        if user ~= nil then
          SetTimer(4000, function() user:AddTask(function() Recipes.SendTo(pl, "CraftingSmithingForge") end) end)
        end
      end
      if wo:IsCooking() then
        local user = User.Lookup(pl:GetID())
        if user ~= nil then
          SetTimer(100, function() user:AddTask(function() Recipes.SendTo(pl, "isCookingSpit"); Recipes.SendTo(pl, "CraftingCookpot"); print("send cookpot recipes") end) end)
        end
      end
    end
  end
  return true
end

function WorldObject.OnPlayerStreamOutObject(pl, obj)
  return true
end

return WorldObject
