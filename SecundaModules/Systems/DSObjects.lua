local DSObjects = {}

local function GetRandomFileName()
  local res = ""
  for i = 1, 5 do
    res = res .. tostring(math.random(1000000, 9999999))
  end
  return res
end

function DSObjects.OnServerInit()
  math.randomseed(os.time())
  return true
end

function DSObjects.OnUserDataSearchResult(user, opcode, rawRes)
  if opcode == "Cont" or opcode == "Door" or opcode == "TPDs" or opcode == "Acti" then
    if WorldObject.Lookup(rawRes:GetID()) == nil then
      user:SendChatMessage(Theme.info .. "DS загрузил экземпляр " .. Theme.sel ..  opcode .. "-" .. string.format("%X",rawRes:GetID()))
      local fileName = "Native" .. tostring(rawRes:GetID())
      local wo = WorldObject.Create(fileName, rawRes)
      wo:Save()
    end
  elseif opcode == "Item" then -- deprecated
    if WorldObject.Lookup(rawRes:GetID()) == nil then
      local woTemp = WorldObject.Create("dummy", rawRes)
      local data = woTemp:GetData()
      data.type = "Activator"
      woTemp:Delete()
      local fileName = "Runtime" .. math.floor(data.x) .. "-" .. math.floor(data.y) .. "-" .. math.floor(data.z)
      if not WorldObject.IsFileNameInUse(fileName) then
        local wo = WorldObject.Create(fileName, nil)
        wo:SetData(data)
        wo:Save()
        user:SendChatMessage(Theme.info .. "DS загрузил экземпляр " .. Theme.sel ..  opcode .. "-" .. string.format("%X",wo:GetValue("refID")))
      end
    end
  else
    user:SendChatMessage(Theme.error .. "Неправильный opcode ".. opcode)
    pcall(function()
      rawRes:Delete()
    end)
  end
  return true
end

return DSObjects
