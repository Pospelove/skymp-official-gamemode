local DSObjects = {}

function DSObjects.OnUserDataSearchResult(user, opcode, res)
  if opcode == "Cont" then
    user:SendChatMessage(Theme.info .. "Загружен объект номер " .. res:GetID())
  end
  return true
end

return DSObjects
