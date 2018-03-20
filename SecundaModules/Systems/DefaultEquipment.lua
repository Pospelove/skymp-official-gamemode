local DefaultEquipment = {}

function DefaultEquipment.OnUserLoad(user)
  if not user:GetAccountVar("hasDefaultEquipment1") then
    user:SetAccountVar("hasDefaultEquipment1", true)
    user:AddTask(function()
      SetTimer(3000, function()
        local iden = "Одежда" .. math.random(2, 7)
        local itemType = ItemTypes.Lookup(iden)
        if itemType then
          user:AddItem(itemType, 1)
          user:EquipItem(itemType, -1)
        end
        local boots = {
          0x000BACD7,
          0x0003452F,
          0x000D1921,
          0x0004223D,
          0x000C5D12,
          0x0010E2CE,
          0x000C36E8,
          0x000E0DD4,
          0x0006B46C,
          0x0001BE1B,
          0x000209A5,
          0x000261BD,
          0x000209A5,
          0x00080699
        }
        local id = boots[math.random(1, #boots)]
        local bootsItemType = ItemTypes.Lookup(id)
        if bootsItemType then
          user:AddItem(bootsItemType, 1)
          user:EquipItem(bootsItemType, -1)
        end
      end)
    end)
  end
end

return DefaultEquipment
