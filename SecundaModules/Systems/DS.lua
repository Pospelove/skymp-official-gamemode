local DS = {
  opcodes = { "NavMesh", "TPDs", "Cont", "Door", "Item", "Actor" }
  users = {}
}

function DS.Start(user)
  if not Set(DS.users)[user] then
    table.insert(DS.users, user)
    user:StartDataSearch()
    print("DataSearch was started for " .. tostring(user))
  end
end

function DS.OnUserDisconnect(user)
  DS.users = (Set(DS.users) - Set{ user }):values()
  return true
end

function DS.UpdatePermsissions(user)
  local ds = (not not user:GetAccountVar("ds"))
  if ds then
    DS.Start(user)
  end
  for i = 1, #DS.opcodes do
    local opcode = DS.opcodes[i]
    local enable = (not not user:GetAccountVar("ds_" .. opcode))
    EnableDataSearchOpcode(opcode, ds and enable)
  end
end

function DS.OnUserLoad(user)
  DS.UpdatePermissions(user)
  return true
end

return DS
