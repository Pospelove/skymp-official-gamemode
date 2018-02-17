local Workbench = {}

--[[
alchWorkbench = Object.Create(0x00093C6C, 0x000bad0c, Location(0x000133C6), 432, 635, -255)
alchWorkbench:RegisterAsFurniture()
alchWorkbench:SetName("Бичеварня");
alchWorkbench:AddKeyword("FurnitureForce3rdPerson")
alchWorkbench:AddKeyword("FurnitureSpecial")
alchWorkbench:AddKeyword("isAlchemy")
alchWorkbench:AddKeyword("RaceToScale")
alchWorkbench:AddKeyword("WICraftingAlchemy")

enchWorkbench = Object.Create(0x0010E322, 0x000D5501, Location(0x000133C6), 29.9677, 599.4473, -256.0001)
enchWorkbench:RegisterAsFurniture()
enchWorkbench:AddKeyword("FurnitureForce3rdPerson")
enchWorkbench:AddKeyword("FurnitureSpecial")
enchWorkbench:AddKeyword("isEnchanting")
enchWorkbench:AddKeyword("RaceToScale")
enchWorkbench:AddKeyword("WICraftingEnchanting")

local door = Object.Create(0x000E3A7A, 0x000C78A3, Location(0x000133C6), -1024, -416, 0)
door:RegisterAsDoor()
door:SetLockLevel(1)

local chair = Object.Create(0x00093C64, 0x0006B691, Location(0x000133C6), -694, 654, 0)
chair:RegisterAsFurniture()

smithForge = Object.Create(0x000D6987, 0x000CAE0B, Location(0x0000003C), 20459, -45225, -83)
smithForge:RegisterAsFurniture()
smithForge:AddKeyword("isBlacksmithForge")
smithForge:AddKeyword("CraftingSmithingForge")
smithForge:AddKeyword("FurnitureForce3rdPerson")
smithForge:AddKeyword("FurnitureSpecial")
smithForge:AddKeyword("RaceToScale")
smithForge:AddKeyword("WICraftingSmithing")
]]

local acti = {}
bubble = {}
local dis = {}

function Workbench.OnActivate(source, target)
  if not source:is_a(User) or not target:is_a(WorldObject) then
    return true
  end
  -- TODO: Do not use raw players and objects
  local object = target.obj
  local player = source.pl
  if not player or not object then return true end

	if object:GetLockLevel() == 255 then
		if player:GetItemCount(ItemTypes.LookupByIdentifier("Железный ключ")) > 0 then
			object:SetLockLevel(0)
			player:SendChatMessage(Color.green .. "Вы открыли замок с помощью ключа")
		end
	end

	SetTimer(300, function()
		local furn = player:GetCurrentFurniture()
    if not furn then return true end
		local showSelf = true

		if furn:GetBaseID() == 0x000CAE0B then
			player:SetChatBubble(Color.gold .. ru("Использует кузницу"), 60000, showSelf)
			bubble[player:GetName()] = true
		end

		if furn:GetBaseID() == 0x000bad0c then
			player:SetChatBubble(Color.green .. ru("Использует алхимический стол"), 60000, showSelf)
			bubble[player:GetName()] = true
		end

		if furn:GetBaseID() == 0x000D5501 then
			player:SetChatBubble("#f442f4" .. ru("Использует зачаровательный стол"), 60000, showSelf)
			bubble[player:GetName()] = true
		end
	end)

	for i = 1, 1 do
		if 0x0006B691 == object:GetBaseID() then -- chairs

			local ae = "Idlechairfrontenter"
			local aee = "Idlechairfrontexit"

			if acti[object:GetID()] then
				ae = aee
				acti[object:GetID()] = nil
			else
				acti[object:GetID()] = true
			end

			local fn = function()
				player:SendAnimationEvent(ae, true)
			end
			for i = 1, 20 do
				SetTimer(i * 100, fn)
			end
			return true
		end
	end

	if object:GetBaseID() == 0x000bad0c then
			local ae = "Idlealchemyenter"
			local aee = "Idlealchemyenter"

			if acti[object:GetID()] then
				ae = aee
				acti[object:GetID()] = nil
			else
				acti[object:GetID()] = true
			end

			local fn = function()
				player:SendAnimationEvent(ae, true)
			end
			for i = 1, 14 do
				SetTimer(i * 100, fn)
			end
			return true
	end

	if object:GetBaseID() == 0x000D5501 then
			local ae = "Idleenchantingenter"
			local aee = "Idleenchantingenter"

			if acti[object:GetID()] then
				ae = aee
				acti[object:GetID()] = nil
			else
				acti[object:GetID()] = true
			end

			local fn = function()
				player:SendAnimationEvent(ae, true)
			end
			for i = 1, 14 do
				SetTimer(i * 100, fn)
			end
			return true
	end

	return true
end

return Workbench
