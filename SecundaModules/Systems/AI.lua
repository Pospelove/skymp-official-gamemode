local AI = {}

function AI.OnPlayerUpdate(pl)
  if pl:IsNPC()then
    if deru(pl:GetName()) ~= deru "������" and deru(pl:GetName()) ~= deru "������" and deru(pl:GetName()) ~= deru "������" and deru(pl:GetName()) ~= deru "�����" then
      if 1 then pl:SetCombatTarget(pl:GetHost()) end
    end
  end
  return true
end

return AI
