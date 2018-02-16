WorldObject = class()

function WorldObject.Docs()
  return [[
  -- Static methods:

  -- Methods:

  -- Callbacks:
  ]]
end

-- Private variables

local gWos = {}

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
  for i = 1, #gWos do
    local wo = gWos[i]
    if wo ~= nil then
      if wo:GetValue("refID") == id then
        return wo
      end
    end
  end
  return nil
end

function WorldObject.GetAllWorldObjects()
  return gWos
end

function WorldObject:GetFileName()
  return self.fileName
end

function WorldObject:Load()
  local file = nil
  local suc, errstr = pcall(function()
    file = io.open("files/worldobjects/" .. self:GetFileName() .. ".json", "r")
    local str = ""
    for line in file:lines() do
      str = str .. line
    end
    self.data = json.decode(str)
    self:_ApplyData()
  end)
  if file ~= nil then
    io.close(file)
  end
  if not suc then
    print("error while loading data for WorldObject " .. self:GetFileName() .. ".json: " .. errstr)
    print("instance will be deleted")
    self:Delete()
  end
end

function WorldObject:Save()
  self:_PrepareDataToSave()
  local filePath = "files/worldobjects/" .. self:GetFileName() .. ".json"
  local file = io.open(filePath, "w")
  if file == nil then
    error("files/worldobjects/" .. " directory not found")
  end

  local data = ""
  local success, errc = pcall(function() data = json.encode(self.data) end)
  if success then
    file:write(data)
    print("saving worldobject " .. self:GetFileName() .. ".json")
  else
    error (errc .. "\n\n" .. pretty.write(self.data))
  end
  io.close(file)
end

function WorldObject:Unload()
  if self.obj ~= nil then
    self.obj:Delete()
    self.obj = nil
  end
end

local function SetHarvestedForPlayer(obj, pl, isHarvested)
  if isHarvested then
    pl:ExecuteCommand("Skymp", "Activate(" .. obj:GetID() .. ")")
  else
  end
end

function WorldObject:SetValue(varName, newValue)
  self:_PrepareDataToSave()
  self.data[varName] = newValue
  self:_ApplyData()
  if varName == "isHarvested" and self.obj ~= nil then
    for i = 0, GetMaxPlayers() do
      local pl = Player.LookupByID(i)
      if pl ~= nil then
        SetHarvestedForPlayer(self.obj, pl, not not newValue)
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
  WorldObject._SaveFileNames()
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
    self.obj:SetPos(self.data.x, self.data.y, self.data.z)
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
  self.data.type = self.obj:GetType()
  self.data.x = math.floor(self.obj:GetX())
  self.data.y = math.floor(self.obj:GetY())
  self.data.z = math.floor(self.obj:GetZ())
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
  local fileNames = {}
  for i = 1, #gWos do
    local wo = gWos[i]
    if wo ~= nil then
      local fileName = wo:GetFileName()
      table.insert(fileNames, fileName)
    end
  end
  local str = json.encode(fileNames)
  local file = io.open("files/worldobjects.json", "w")
  file:write(str)
  io.close(file)
end


function WorldObject._LoadFileNames()
  local jsonPath = "files/worldobjects.json"
  local file = io.open(jsonPath, "r")
  if file == nil then
    error(jsonPath .. " is missing")
  end
  local str = ""
  for line in file:lines() do
    str = str .. line
  end
  io.close(file)
  return json.decode(str)
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
  local wo = WorldObject.Lookup(obj:GetID())
  if wo ~= nil then
    SetTimer(500, function() SetHarvestedForPlayer(obj, pl, wo:GetValue("isHarvested")) end)
  end
  return true
end

function WorldObject.OnPlayerStreamOutObject(pl, obj)
  return true
end

return WorldObject
