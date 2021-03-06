FakeItems = {}
-- TODO: Rename this file

local gFlora = dsres.flora

function FakeItems.OnActivate(source, target)
  if (source:is_a(User) or source:is_a(NPC)) and target:is_a(WorldObject) then
    if target:GetValue("type") == "Activator" then
      local base = target:GetValue("baseID")
      local itemType = ItemTypes.Lookup(base)
      if target:GetValue("isCollectedItem") then
        target:SetValue("isCollectedItem", false)
        target:SetValue("isCollectedItem", true)
        target:SetValue("isDisabled", true)
        target:Save()
      end
      if not target:GetValue("isCollectedItem") then
        if target:GetValue("baseID") == 0x000D790C or target:GetValue("baseID") == 0x000D8E7F or target:GetValue("baseID") == 0x000D8E80 then
          source:AddItem(ItemTypes.Lookup(0x0000000F), math.random(1, 20))
          target:SetValue("isDisabled", true)
          target:SetValue("isCollectedItem", true)
          target:Save()
          FakeItems.OnActivate(source, target)
        end
        if itemType ~= nil and ItemTypes.IsFromDS(itemType) then
          source:AddItem(itemType, 1)
          if source:is_a(NPC) then
            source:EquipItem(itemType, 0)
          end
          target:SetValue("isDisabled", true)
          target:SetValue("isCollectedItem", true)
          target:Save()
          FakeItems.OnActivate(source, target)
          --SetTimer(1000, function() FakeItems.OnActivate(source, target) end)
        end
      end
      for i = 1, #gFlora do
        local t = gFlora[i]
        if t ~= nil then
          local floraBaseID = t[1]
          local itemTypeID = t[2]
          if floraBaseID == target:GetValue("baseID") then
            local itemType = ItemTypes.Lookup(itemTypeID)
            if itemType ~= nil and not target:GetValue("isHarvested") then
              source:AddItem(itemType, 1)
              target:SetValue("isHarvested", true)
            end
            break
          end
        end
      end
      target:ResetFor(source)
    end
  end
  return true
end

return FakeItems
