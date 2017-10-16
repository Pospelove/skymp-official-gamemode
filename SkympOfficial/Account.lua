-- Account.lua

local Account = {}

function Account.Load(name, callback)
	local file, error = io.open("files/players/" .. name .. ".json", "r")
	if file and not error then
		local str = ""
		for line in file:lines() do
			str = str .. line
		end
		file:close()
		local playerData = {}
		local success, err = pcall(function() playerData = Account.json.decode(str) end)
		if not success then
			-- json.decode бросила исключение
			SetTimer(0, function() callback(nil) end)
			print(err)
		else
			SetTimer(0, function() callback(playerData) end)
		end
	else
		SetTimer(0, function() callback(nil) end)
	end
end

function Account.Save(name, playerData, callback)
	local delayMs = 50
	local file, error = io.open("files/players/" .. name .. ".json", "w")
	if file and not error then
		file:write(Account.json.encode(playerData))
		file:close()
		if callback then SetTimer(0, callback) end
	end
end

function Account.SavePlayer(player)
	local name = player:GetName()
	return Account.Save(name, Account.accounts[name], nil)
end

function Account.IsLogged(player)
	if not player then return false end
	if not player:IsConnected() then return false end
	if not Account.temp[player:GetName()] then return false end
	if not Account.temp[player:GetName()].logged then return false end
	return true
end

function Account.New()
	return {
		name = "",
		password = "",
		x = 0,
		y = 0,
		z = 0,
		angle = 0,
		locationID = 0,
		look = nil,
	}
end

function Account.NewTemp()
	return {
		logged = false,
		register = false,
		authAttempts = 0,
	}
end

function GetLook(player)
	local look = {}
	if player:GetRace() then
		look.raceID = player:GetRace():GetID()
	else
		look.raceID = 0x00000000
	end
	look.isFemale = player:IsFemale()
	look.weight = math.floor(player:GetWeight())
	look.skinColor = player:GetSkinColor()
	look.hairColor = player:GetHairColor()
	look.headparts = {}
	for i = 1, player:GetHeadpartCount() do
		table.insert(look.headparts, player:GetNthHeadpartID(i))
	end
	look.tints = {}
	for i = 1, player:GetTintmaskCount() do
		local tint = {}
		tint.texture = player:GetNthTintmaskTexture(i)
		tint.type = player:GetNthTintmaskType(i)
		tint.color = player:GetNthTintmaskColor(i)
		tint.alpha = tostring(player:GetNthTintmaskAlpha(i))
		table.insert(look.tints, tint)
	end
	look.faceOptions = {}
	for i = 1, player:GetFaceOptionCount() do
		table.insert(look.faceOptions, tostring(player:GetNthFaceOption(i)))
	end
	look.facePresets = {}
	for i = 1, player:GetFacePresetCount() do
		table.insert(look.facePresets, (player:GetNthFacePreset(i)))
	end
	look.headTexture = player:GetHeadTextureSetID()
	return look
end

function SetLook(player, look)
	if not look then return end
	player:SetRace(Race(look.raceID))
	player:SetWeight(look.weight)
	player:SetFemale(look.isFemale)
	player:SetSkinColor(look.skinColor)
	player:SetHairColor(look.hairColor)
	player:SetHeadpartIDs(look.headparts)
	player:RemoveAllTintmasks()
	for i = 1, #look.tints do
		local tint = look.tints[i]
		--player:AddTintmask(i, tint.texture, tint.type, tint.color, tonumber(tint.alpha)) -- краш игры
		player:AddTintmask(tint.texture, tint.type, tint.color, tonumber(tint.alpha))
	end
	player:SetFacePresets(look.facePresets)
	local faceOptions = {}
	for i = 1, #look.faceOptions do
		table.insert(faceOptions,tonumber(look.faceOptions[i]))
	end
	player:SetFaceOptions(faceOptions)
	player:SetHeadTextureSetID(look.headTexture)
end

function GetInventory(player)
	local inv = {}
	for i = 1, player:GetNumInventorySlots() do
		local entry = {}
		entry.ident = player:GetItemTypeInSlot(i):GetIdentifier()
		entry.count = player:GetItemCountInSlot(i)
		table.insert(inv, entry)
	end
	return inv
end

function SetInventory(player, inv)
	player:RemoveAllItems()
	if inv ~= nil then
		for i = 1, #inv do
			local entry = inv[i]
			local itemT = ItemTypes.LookupByIdentifier(entry.ident)
			player:AddItem(itemT, entry.count)
		end
	end
end

function GetEquipment(player)
	local eq = {}
	for i = 1, player:GetNumInventorySlots() do
		local entry = {}
		local itemT = player:GetItemTypeInSlot(i)
		entry.ident = itemT:GetIdentifier()
		entry.hand = -1
		if player:IsEquipped(itemT) and itemT:GetClass() ~= "Weapon" then
			table.insert(eq, entry)
		end
	end
	for i = 0, 1 do
		local itemT = player:GetEquippedWeapon(i)
		if itemT then
			table.insert(eq, {ident = itemT:GetIdentifier(), hand = i})
		end
	end
	return eq
end

function UnequipAllItems(player)
	for i = 1, player:GetNumInventorySlots() do
		local itemT = player:GetItemTypeInSlot(i)
		if itemT and player:IsEquipped(itemT) then
			player:UnequipItem(itemT)
		end
	end
end

function SetEquipment(player, eq)
	UnequipAllItems(player)
	if eq ~= nil then
		for i = 1, #eq do
			local entry = eq[i]
			local itemT = ItemTypes.LookupByIdentifier(entry.ident)
			local hand = entry.hand
			player:EquipItem(itemT, hand)
		end
	end
end

local function SetRandomSpawn(player)
	local Tamriel = Location(0x0000003c)
	local spawns = {
		{Tamriel, 17224.7734, -47204.4531, -51.8551, 58.7287}
	}
	local i = (player:GetID() % #spawns) + 1
	player:SetSpawnPoint(spawns[i][1], spawns[i][2], spawns[i][3], spawns[i][4], spawns[i][5])
end

function Account.OnServerInit()
	Account.json = require "json"
	Account.io = require "io"
	Account.sha256 = require "sha256"
	Account.accounts = {}
	Account.temp = {}
	Account.enums = {
		DialogRegister = 1,
		DialogLogin = 2,
		DialogRepeatPass = 3,
	}
end

function Account.OnPlayerConnect(player)
	player:SetVirtualWorld(player:GetID())

	local name = player:GetName()

	Account.accounts[name] = nil
	Account.temp[name] = nil

	local onLoad = function(playerData)
		if not player:IsConnected() then return end

		Account.temp[name] = Account.NewTemp()

		if playerData then
			Account.accounts[name] = playerData
		else
			Account.accounts[name] = Account.New()
			Account.accounts[name].name = name
			Account.temp[name].register = true
		end

		local acc = Account.accounts[name]

		if acc.locationID == 0 then
			SetRandomSpawn(player)
		else
			player:SetSpawnPoint(Location(acc.locationID), acc.x, acc.y, acc.z, acc.angle)
		end
		player:Spawn()
	end

	Account.Load(name, onLoad)
end

function Account.OnPlayerDisconnect(player)
	if Account.IsLogged(player) then
		Account.SavePlayer(player)
	end
end

local function ShowRegister(player)
	player:ShowDialog(Account.enums.DialogRegister, "Input", "Придумайте пароль для Вашего аккаунта:", "", -1)
end

local function ShowLogin(player)
return
	player:ShowDialog(Account.enums.DialogLogin, "Input", "Введите Ваш пароль:", "", -1)
end

function Account.OnPlayerSpawn(player)
	local name = player:GetName()
	if not Account.IsLogged(player) then
		if Account.temp[name].register then
			ShowRegister(player)
		else
			ShowLogin(player)
		end
	end
end

local function HashPassword(str)
	return Account.sha256(str .. "===" .. str)
end

function Account.OnPlayerDialogResponse(player, dialogID, inputText, listItem)
	local name = player:GetName()

	if dialogID == Account.enums.DialogRegister then
		
		if listItem == 1 then
			return player:Kick()
		end

		local minPass = 6
		local maxPass = 32

		local function WrongCharsInPassword(str)
			for c in inputText:gmatch(".") do
				local isWrong = true
				local allowed = "qazwsxedcrfvtgbyhnujmikolpQAZWSXEDCRFVTGBYHNUJMIKOLP1234567890_"
				for c2 in allowed:gmatch(".") do
					if c == c2 then
						isWrong = false
						break
					end
				end
				if isWrong then
					return true
				end
			end
			return false
		end

		if inputText:len() < minPass then 
			player:SendChatMessage(Color.red .. "Пароль не должен быть короче " .. tostring(minPass) .. " символов")
			ShowRegister(player)
		elseif inputText:len() > maxPass then 
			player:SendChatMessage(Color.red .. "Пароль не должен быть длиннее " .. tostring(maxPass) .. " символов")
			ShowRegister(player)
		elseif WrongCharsInPassword(inputText) then
			player:SendChatMessage(Color.red .. "Пароль может содержать только символы латинского алфавита, цифры и '_'")
			player:SendChatMessage(Color.grey .. "Если не удаётся переключить раскладку клавиатуры, попробуйте перезапустить клиент")
			ShowRegister(player)
		else
			player:ShowDialog(Account.enums.DialogRepeatPass, "Input", "Пожалуйста, повторите пароль", "", -1)
			Account.accounts[name].password = HashPassword(inputText)
		end
		return
	end

	if dialogID == Account.enums.DialogLogin then
		if listItem == 1 then
			return player:Kick()
		end

		if HashPassword(inputText) ~= Account.accounts[name].password then
			local maxAttempts = 3
			Account.temp[name].authAttempts = Account.temp[name].authAttempts + 1
			player:SendChatMessage(Color.red .. "Неправильный пароль (" .. Account.temp[name].authAttempts .. "/" .. maxAttempts .. ")")
			if Account.temp[name].authAttempts == maxAttempts then
				return player:Kick()
			end
			return ShowLogin(player)
		end

		Account.OnReady(player)
		return
	end

	if dialogID == Account.enums.DialogRepeatPass then
		if listItem == 1 then
			return ShowRegister(player)
		end
		if HashPassword(inputText) ~= Account.accounts[name].password then
			player:SendChatMessage(Color.red .. "Пароли не совпадают")
			return ShowRegister(player)
		end
		Account.SavePlayer(player)
		Account.OnReady(player)
		return
	end
end

function Account.OnReady(player)
	local name = player:GetName()
	Account.temp[name].logged = true
	local acc = Account.accounts[name]
	if not acc.look then
		player:ShowMenu("RaceSex Menu")
	else
		player:SetVirtualWorld(0)
		SetLook(player, acc.look)
		player:SendChatMessage("Добро пожаловать")
	end
	player:MuteInventoryNotifications(true)
	SetInventory(player, acc.inventory)
	player:MuteInventoryNotifications(false)
end

function Account.OnPlayerUpdate(player)
	local name = player:GetName()

	if not Account.IsLogged(player) then return end

	Account.accounts[name].x = math.floor(player:GetX())
	Account.accounts[name].y = math.floor(player:GetY())
	Account.accounts[name].z = math.floor(player:GetZ())
	Account.accounts[name].angle = math.floor(player:GetAngleZ())
	Account.accounts[name].inventory = GetInventory(player)
	if player:GetLocation() then
		Account.accounts[name].locationID = player:GetLocation():GetID()
	else
		Account.accounts[name].locationID = 0x00000000
	end
end

function Account.OnPlayerCharacterCreated(player)
	local name = player:GetName()
	Account.accounts[name].look = GetLook(player)
	player:SendChatMessage(Color.green .. "Провинция Скайрим приветствует Вас")
	Account.SavePlayer(player)
	player:SetVirtualWorld(0)
end

return Account