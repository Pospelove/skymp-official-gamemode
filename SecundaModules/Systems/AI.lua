local AI = {}

function AI.OnPlayerUpdate(pl)
  if pl:IsNPC()then
    if deru(pl:GetName()) ~= deru "Курица" and deru(pl:GetName()) ~= deru "Лисица" and deru(pl:GetName()) ~= deru "Корова" and deru(pl:GetName()) ~= deru "Олень" then
      if 1 then pl:SetCombatTarget(pl:GetHost()) end
    end
  end
  return true
end

return AI
