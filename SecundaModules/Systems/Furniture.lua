local Furniture = {}

local acti = {}
local UNSYNCED_AE = true
local SYNCED_AE = false

local function Anim(user, object, anim)
			local ae = anim
			local aee = anim

			if acti[object:GetID()] then
				ae = aee
				acti[object:GetID()] = nil
			else
				acti[object:GetID()] = true
			end

			local fn = function()
				user.pl:SendAnimationEvent(ae, UNSYNCED_AE)
			end
			for i = 1, 14 do
				SetTimer(i * 100, fn)
			end
			return true
end

local furnUserID = {}
local bubble = {}

local function IsFurnitureInUse(object)
  if furnUserID[object] ~= nil then
    local user = User.Lookup(furnUserID[object])
    if user ~= nil then
      local furn = user:GetCurrentFurniture()
      if furn ~= nil then
        if furn:GetID() == object:GetID() then
          return true
        end
      end
    end
  end
  return false
end

local FurnitureDialog01 = 1000001

function Furniture.OnUserDialogResponse(user, dialogId, inputText, listItem)
	if dialogId == FurnitureDialog01 then
		local result = nil
		local count = 0
		local craftIngrFilter = ""
		if listItem == 2 or listItem == -1 then -- отмена
			return true
		elseif listItem == 0 then -- кожа
			result = ItemTypes.Lookup("Кожа")
			count = 2
			craftIngrFilter = "Шкура"
		else -- полоски кожи
			result = ItemTypes.Lookup("Полоски кожи")
			count = 3
			craftIngrFilter = "Кожа"
		end
		for i = 1, user:GetNumInventorySlots() do
			local itemType = user:GetItemTypeInSlot(i)
			local iden = itemType:GetIdentifier()
			if stringx.startswith(iden, craftIngrFilter) then
				if user:RemoveItem(itemType, 1) then
					user:AddItem(result, count)
					user:SendChatMessage(Theme.info .. "Вы создали предмет " .. Theme.sel .. result:GetIdentifier() .. Theme.info .. " в количестве " .. Theme.sel .. tostring(count))
					return true
				end
			end
		end
		user:SendChatMessage(Theme.error .. "Вам требуется " .. craftIngrFilter .. ", чтобы изготовить это")
	end
	return true
end

function Furniture.OnActivate(source, target)
  if (source:is_a(User) and target:is_a(WorldObject)) then
    --if target:IsCooking() then source:Kick() end

		if IsFurnitureInUse(target.obj) then
			if target:GetValue("baseID") == 0x000BAD0C or target:GetValue("baseID") == 0x000D54FF then -- alch
				return false
			end
			if target:GetValue("baseID") == 0x000BAD0D or target:GetValue("baseID")== 0x000D5501 then -- ench
				return false
			end
		end

    SetTimer(1, function()
      local user = source

  		local furn = source:GetCurrentFurniture()
  		local showSelf = true

			if target:IsCooking() then
				--source:SendChatMessage(target:GetValue("type"))
				target:SetValue("type", "Furniture")
				--source:SendChatMessage(target:GetValue("type"))
				target.obj:AddKeyword("CraftingCookpot")
	      target.obj:AddKeyword("FurnitureForce3rdPerson")
	  		target.obj:AddKeyword("FurnitureSpecial")
	  		target.obj:AddKeyword("isCookingSpit")
	  		target.obj:AddKeyword("RaceToScale")

				source.pl:SetChatBubble(Color.gold .. ru("Занимается приготовлением пищи"), 60000, showSelf)
  			bubble[source:GetName()] = true
			end

			if target:GetValue("baseID") == 0x000727A1 then -- Дубильный ствнок
				source:ShowDialog(FurnitureDialog01, "List", "Какой предмет Вы хотите изготовить?", "Кожа\nПолоски кожи\nОТМЕНА")
				return true
			end

      if target:GetValue("baseID") == 0x000D932F then -- верстак
        return true
      end

  		if target:GetValue("baseID") == 0x000CAE0B then
  			source.pl:SetChatBubble(Color.gold .. ru("Использует кузницу"), 60000, showSelf)
  			bubble[source:GetName()] = true
        return true
  		end

  		if target:GetValue("baseID") == 0x000BAD0C or target:GetValue("baseID") == 0x000D54FF then
        if IsFurnitureInUse(furn) then return false end
  			source.pl:SetChatBubble(Color.green .. ru("Использует алхимический стол"), 60000, showSelf)
  			bubble[source:GetName()] = true
        Anim(source, furn, "Idlealchemyenter")
        return true
  		end

  		if target:GetValue("baseID") == 0x000BAD0D or target:GetValue("baseID")== 0x000D5501 then
        if IsFurnitureInUse(furn) then return false end
  			source.pl:SetChatBubble("#f442f4" .. ru("Использует зачаровательный стол"), 60000, showSelf)
  			bubble[source:GetName()] = true
        Anim(source, furn, "Idleenchantingenter")
        return true
  		end

      --user:SendChatMessage(tostring(target:GetValue("baseID")))
  	end)
  end
  return true
end

function Furniture.OnUserUpdate(user)

  user.pl:EnableMovementSync(true)
  user.pl:EnableMovementSync(false)
  local furn = user:GetCurrentFurniture()
  if furn ~= nil then
    furnUserID[furn:GetID()] = user:GetID()
  end
  if bubble[user:GetName()] == true and (user:GetCurrentFurniture() == nil or not user:IsStanding()) then
    user.pl:SetChatBubble("   ", 60000, true)
    bubble[user:GetName()] = nil
    return true
  end
  return true
end

return Furniture
