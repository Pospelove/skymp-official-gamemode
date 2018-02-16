local InventoryNotifications = {}

function InventoryNotifications.OnUserConnect(user)
  user:MuteInventoryNotifications(true)
end

function InventoryNotifications.OnUserSpawn(user)
  SetTimer(2000, function()
    user:MuteInventoryNotifications(false)
  end)
end

return InventoryNotifications
