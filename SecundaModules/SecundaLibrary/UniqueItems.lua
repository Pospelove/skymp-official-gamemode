local UniqueItems = {}

function UniqueItems.OnServerInit()
  ItemType.Create("Факел", "Armor.Shield", 0x00036343, 1.0, 5, 0.0, "LightArmor")
  return true
end

return UniqueItems
