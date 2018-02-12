local DSObjects = {}

function DSObjects.OnUserDataSearchResult(user, opcode, rawRes)
  if opcode == "Cont" or opcode == "Door" then
    if WorldObject.Lookup(rawRes:GetID()) == nil then
      user:SendChatMessage(Theme.info .. "DS загрузил экземпляр " .. Theme.sel ..  opcode .. "-" .. string.format("%X",rawRes:GetID()))
      local fileName = tostring(rawRes:GetID())
      local wo = WorldObject.Create(fileName, rawRes)
      wo:Save()
    end
  else
    pcall(function()
      rawRes:Delete()
    end)
  end
  return true
end

return DSObjects
