local DS = {
  opcodes = { "NavMesh", "TPDs", "Cont", "Door", "Item", "Actor" }
}

function DS.UpdatePermsissions(user)
  local ds = (not not user:GetAccountVar("ds"))
  if ds then
    user:StartDataSearch()
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
