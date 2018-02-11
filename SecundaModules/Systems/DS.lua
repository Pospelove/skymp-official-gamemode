local DS = {
  opcodes = { "NavMesh", "TPDs", "Cont", "Door", "Item", "Actor" },
  users = Set({})
}

function DS.Start(user)
  if not DS.users[user] then
    DS.users = DS.users + Set({ user })
    user:StartDataSearch()
    print("DataSearch was started for " .. tostring(user))
  end
end

function DS.OnUserDisconnect(user)
  DS.users = Set(DS.users) - Set({ user })
  return true
end

function DS.UpdatePermissions(user)
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
