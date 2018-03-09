Container = class()

function Container:_init(realContainer)
  self.items = {}
  if realContainer ~= nil then
    for i = 1, realContainer:GetNumInventorySlots() do
      local entry = {}
      entry.itemType = realContainer:GetItemTypeInSlot(i)
      entry.count = realContainer:GetItemCountInSlot(i)
      table.insert(self.items, entry)
    end
  end
end

function Container:AddItem(itemType, count)
  if itemType == nil then
    error("bad ItemType")
  end
  if count == nil then count = 1 end
  if type(count) ~= "number" or count < 0 then
    error("bad count " .. tostring(count))
  end
  for i = 1, #self.items do
    if self.items[i].itemType == itemType then
      self.items[i].count = self.items[i].count + count
      return
    end
  end
  local entry = {}
  entry.itemType = itemType
  entry.count = count
  table.insert(self.items, entry)
end

function Container:RemoveItem(itemType, count)
  if itemType == nil then
    error("bad ItemType")
  end
  if type(count) ~= "number" or count < 0 then
    error("bad count " .. tostring(count))
  end
  for i = 1, #self.items do
    if self.items[i].itemType == itemType then
      if self.items[i].count >= count then
        self.items[i].count = self.items[i].count - count
        return count
      else
        local res = self.items[i].count
        self.items[i].count = 0
        return res
      end
    end
  end
  return 0
end

function Container:ApplyTo(rawCont)
  rawCont:RemoveAllItems()
  for i = 1, #self.items do
    if self.items[i].count > 0 then
      rawCont:AddItem(self.items[i].itemType, self.items[i].count)
    end
  end
end

function Container.Init()
  ItemTypes.Require()
end

function Container.Require()
  if not Container.inited then
    Container.Init()
    Container.inited = true
  end
end

function Container.OnServerInit()
  Container.Require()
  return true
end

function Container.RunTests()
  local cont = Container()
  local iden = "FDJFDLADSFASDIUASDFDAFEYTEERFERTSDACXBCUTDFGISDAGAYSUHSDagagfdsadkugadssadjksfgduyihasduasahisdguadshiadftfadhadsguadadsftgdasidhaurue6teq6627367236723723"
  local itemType = ItemType.Create(iden, "Weapon.Sword", 0x00012EB7, 8.0, 30, 7.0, "OneHanded")
  if itemType == nil then
    return error("bad test")
  end
  local success, errorString = pcall(function()
    cont:AddItem(itemType, 32)
    local removed16 = cont:RemoveItem(itemType, 16)
    cont:AddItem(itemType, 1)
    local removed17 = cont:RemoveItem(itemType, 64)
    if removed16 ~= 16 or removed17 ~= 17 then
      error("test failed " .. removed16 .. " " .. removed17)
    end
  end)
  if not success then
    error("test failed with exception: " .. errorString)
  end
end

return Container
