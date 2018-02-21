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
  elseif opcode == "Actor" then
    local fileName = "Native" .. tostring(rawRes:GetRefID())
    if NPC.IsFileNameInUse(fileName) == false then
      local npc = NPC.Create(fileName)
      npc:SetValue("baseID", rawRes:GetBaseID())
      npc:SetValue("x", rawRes:GetX())
      npc:SetValue("y", rawRes:GetY())
      npc:SetValue("z", rawRes:GetZ())
      npc:SetValue("angleZ", rawRes:GetAngleZ())
      if rawRes:GetLocation() == nil then
        error("bad actor locaiton")
      end
      npc:SetValue("locationID", rawRes:GetLocation():GetID())
      npc:SetValue("virtualWorld", rawRes:GetVirtualWorld())
      npc:Save()
      user:SendChatMessage(Theme.info .. "DS загрузил экземпляр " .. Theme.sel ..  opcode .. "-" .. string.format("%X",rawRes:GetRefID()))
      rawRes:Kick()
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
