local SpecialNPC = {}

function SpecialNPC.OnNPCSpawn(npc)
  --print("1 " .. deru(npc:GetValue("name")))
  if ru(deru(npc:GetValue("name"))) == ru "Великан" then
    --print("2")
    npc.pl:AddItem(ItemTypes.Lookup("Дубина великана"), 1)
    npc.pl:EquipItem(ItemTypes.Lookup("Дубина великана"), 0)
  end
  return true
end

function SpecialNPC.OnNPCDying(npc)
  for i = 1, 5 do
    npc.pl:RemoveItem(ItemTypes.Lookup("Дубина великана"), 1)
  end
  return true
end

return SpecialNPC
