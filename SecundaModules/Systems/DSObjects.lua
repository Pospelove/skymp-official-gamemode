local DSObjects = {}

function DSObjects.OnUserDataSearchResult(user, opcode, rawRes)
  if opcode == "Cont" then
    if WorldObject.Lookup(rawRes:GetID()) == nil then
      user:SendChatMessage(Theme.info .. "Загружен объект номер " .. res:GetID())
      local fileName = tostring(rawRes:GetID())
      local wo = WorldObject.Create(fileName, rawRes)
      wo:Save()
    end
  end
  return true
end

return DSObjects
