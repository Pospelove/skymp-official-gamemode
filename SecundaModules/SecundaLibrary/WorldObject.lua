WorldObject = class()

function WorldObject.Docs()
  return [[
  -- Static methods:

  -- Methods:

  -- Callbacks:
  ]]
end

-- Private variables

local gKeys = {}
local gWos = {}
local gFilenames = {}

-- Public

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
  local suc = pcall(function()
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
    print("unable to load data for " .. self:GetFileName())
  end
end

function WorldObject:Save()
  self:_PrepareDataToSave()
  local filePath = "files/worldobjects/" .. self:GetFileName() .. ".json"
  local file = io.open(filePath, "w")
  if file == nil then
    error("unable to open file " .. filePath .. " for writing")
  end

  local data = ""
  local success, errc = pcall(function() data = json.encode(self.data) end)
  if success then
    file:write(data)
  else
    error (errc .. "\n\n" .. pretty.write(self.data))
  end
  io.close(file)
end

function WorldObject:SetValue(varName, newValue)
  self:_PrepareDataToSave()
  self.data[varName] = newValue
  self:_ApplyData()
end

function WorldObject:GetValue(varName)
  self:_PrepareDataToSave()
  return self.data[varName]
end

function WorldObject.Create(fileName, optionalRawObject)
  local wo = WorldObject(fileName, optionalRawObject)
  WorldObject._SaveFileNames()
  return wo
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
    isOpen = 0
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
    self.obj:SetPos(self.data.x, self.data.y, self.data.z)
    self.obj:SetAngle(self.data.angleX, self.data.angleY, self.data.angleZ)
    self.obj:SetLocation(Location(self.data.locationID))
    self.obj:SetVirtualWorld(self.data.virtualWorld)
    self.obj:SetLockLevel(self.data.lockLevel)
    self.obj:SetOpen(self.data.isOpen)
  end
  self:_PrepareDataToSave()
end

function WorldObject:_PrepareDataToSave()
  if self.obj == nil then
    return
  end
  self.data.baseID = self.obj:GetBaseID()
  self.data.refID = self.obj:GetID()
  self.data.x = self.obj:GetX()
  self.data.y = self.obj:GetY()
  self.data.z = self.obj:GetZ()
  self.data.angleX = self.obj:GetAngleX()
  self.data.angleY = self.obj:GetAngleY()
  self.data.angleZ = self.obj:GetAngleZ()
  self.data.locationID = self.obj:GetLocation() and self.obj:GetLocation():GetID() or 0
  self.data.virtualWorld = self.obj:GetVirtualWorld()
  self.data.lockLevel = self.obj:GetLockLevel()
  self.data.isOpen = self.obj:IsOpen()
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
  for i = 1, #fileNames do
    local fileName = fileNames[i]
    local wo = WorldObject(fileName)
    wo:Load()
  end
end

function WorldObject.OnServerInit()
  WorldObject._LoadAll()
  return true
end

return WorldObject
