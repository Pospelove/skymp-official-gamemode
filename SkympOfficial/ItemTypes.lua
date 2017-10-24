-- ItemTypes.lua

local ItemTypes = {}

function ItemTypes.Create()
	local itemTs = {
	--	Identifier			Class					FormID			Weight			Price		Damage/Armor/etc
		{"IronSword",		"Weapon.Sword",			0x00012EB7,		8.0,			30,			7.0},
		{"IronGreatsword",	"Weapon.GreatSword",	0x0001359D,		14.0,			60,			14.5},
		{"IronArmor",		"Armor",				0x00012E49,		31.0,			150,		26.0},
		{"IronBoots",		"Armor",				0x00012E4B,		6.0,			25,			10.0},
		{"IronGauntlets",	"Armor",				0x00012E46,		5.0,			30,			10.0},
		{"IronHelmet",		"Armor",				0x00012E4D,		5.0,			80,			15.0},
		{"IronShield",		"Armor",				0x00012EB6,		14.0,			55,			20.0},
		{"Gold001",			"Misc.Gold",			0x0000000F,		0.0,			1,			nil},
		{"Lockpick",		"Misc.Lockpick",		0x0000000A,		0.0,			3,			nil},
		{"Drum",			"Misc.Misc",			0x000DABA9,		4.5,			11,			nil},
		{"SteelSword",		"Weapon.Sword",			0x00013989,		10.0,			45,			8.0},
		{"IronArrow",		"Ammo",					0x0001397D,		0.0,			1,			8.0},
		{"LongBow",			"Weapon.Bow",			0x0003B562,		5.0,			50,			7.0},
	}
	for i = 1, #itemTs do
		ItemType.Create(itemTs[i][1], itemTs[i][2], itemTs[i][3], itemTs[i][4], itemTs[i][5], itemTs[i][6])
	end
end

function ItemTypes.OnServerInit()
	ItemTypes.Create()
	ItemTypes.cache = {}
end

function ItemTypes.OnPlayerChatCommand(player, tokens)
	local hasExtraPermission = Main.IsDeveloper(player)

	if tokens[1] == "/additem" then
		if not hasExtraPermission then return player:SendChatMessage(Strings.NoPermission) end
		local itemT = ItemTypes.LookupByIdentifier(tostring(tokens[2]))
		local count = tonumber(tokens[3])
		if not itemT then return player:SendChatMessage(Color.red .. "Предмет не найден (" .. tostring(tokens[2]) .. ")") end
		if not count then count = 1 end
		player:AddItem(itemT, count)
		return
	end

	if tokens[1] == "/enumitems" then
		if not hasExtraPermission then return player:SendChatMessage(Strings.NoPermission) end
		for i = 1, player:GetNumInventorySlots() do
		local entry = {}
		entry.ident = player:GetItemTypeInSlot(i):GetIdentifier()
		entry.count = player:GetItemCountInSlot(i)
		player:SendChatMessage(entry.ident .. " " .. entry.count)
		end
		return
	end

	if tokens[1] == "/randeq" then
		player:MuteInventoryNotifications(true)
		if not hasExtraPermission then return player:SendChatMessage(Strings.NoPermission) end
		for i = 1, player:GetNumInventorySlots() do
			local itemT = player:GetItemTypeInSlot(i)
			player:UnequipItem(itemT, -1)
			if itemT:GetClass() == "Armor" or itemT:GetClass() == "Weapon" or itemT:GetClass() == "Ammo" then
				if math.random(0, 1) == 1 then
					player:EquipItem(itemT, -1)
				end
			end
		end
		player:MuteInventoryNotifications(false)
		return
	end

end

function ItemTypes.LookupByIdentifier(str)
	if ItemTypes.cache[str] == nil then
		ItemTypes.cache[str] = ItemType.LookupByIdentifier(str)
	end
	return ItemTypes.cache[str]
end

return ItemTypes