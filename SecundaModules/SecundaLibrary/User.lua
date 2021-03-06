User = class()

function User.Docs()
  return [[
  -- Static methods:
  User.Lookup(key) -- Lookup user by key (ID or Name)
  User.GetAllUsers() -- Get list of users (very fat)
  User.GetUsersMap() -- Get map-like table of users, faster than GetAllUsers() (example: user = User.GetUsersMap()["Pospelov"])

  -- Methods:
  tostring(user) -- same to 'user:GetName()'
  user:Load() -- Load account
  user:Save() -- Save account
  user:CheckAuth(callback) -- Async check if user is logged. Calls callback(true) if is logged or callback(false) if not
  user:GetAccountVar(varName) -- Get value of account variable with specified name
  user:SetAccountVar(varName, newValue, forceChanges) -- Change account var value. It's OK to use in OnUserLoad
  user:ShowRaceMenu() -- Show the character editor
  user:UnequipAll() -- Unequip all items
  user:SetTempVar(varName, newValue) --
  user:GetTempVar(varName) --
  user:ForceFirstPerson() --
  user:ForceThirdPerson() --

  -- Callbacks:
  OnUserLoad(user) -- Called from user:Load() when loading account
  OnUserSave(user) -- Called from user:Save() when account is saved (NOT saving)
  OnUserConnect(user) --
  OnUserDisconnect(user) --
  OnUserSpawn(user) --
  OnUserCharacterCreated(user) --
  OnUserChatMessage(user, text) -- Called on chat message (not command)
  OnUserChatCommand(user, cmdtext) -- Called on chat command
  OnUserLearnPerk(user, perk) --
  OnUserDying(user, killer) --
  OnUserDataSearchResult(user, opcode, result) --
  OnHit(user, target) --
  OnActivate(user, target) --
  OnUserDialogResponse(user, dialogId, inputtext, listitem) --
  OnUserCraftItem(user, itemType, count) --
  OnUserBowShot(user, power) --
  OnUserUseItem(user, itemType) --  Called on item eat or use
  OnUserTempVarAssign(user, varName, oldValue, newValue) -- Called when you use SetTempVar()
  ]]
end

-- Private variables

local gUserCtorEnabled = true
local gUsersMap = {}
local gUserTested = false
local gIsTimerStarted = {}

-- Public

function User.Lookup(key)
  return gUsersMap[key]
end

function User.GetAllUsers()
  local res = {}
  for k, v in pairs(gUsersMap) do
    if type(k) == "string" then
      table.insert(res, v)
    end
  end
  return res
end

function User.GetUsersMap()
  return gUsersMap
end

function User:__tostring()
  return self:GetName()
end

function User:Load()
  local file = nil
  local suc = pcall(function()
    file = io.open("files/players/" .. self:GetName() .. ".json", "r")
    local str = ""
    for line in file:lines() do
      str = str .. line
    end
    self.account = json.decode(str)
  end)
  if file ~= nil then
    io.close(file)
  end
  if not suc then
    self.account = {}
    self.account.name = self:GetName()
    self:Save()
    print("creating new account for " .. tostring(self))
  end
  Secunda.OnUserLoad(self)
  self:_ApplyAccount()
end

function User:Save()
  local isTest = self.pl:IsNPC()
  if isTest then
    return
  end
  if self.account == nil then
    error "user with account expected"
  end
  self:_PrepareAccountToSave()
  local file = io.open("files/players/" .. self:GetName() .. ".json", "w")

  local data = ""
  local success, errc = pcall(function() data = json.encode(self.account) end)
  if success then
    file:write(data)
  else
    error (errc .. "\n\n" .. pretty.write(self.account))
  end
  io.close(file)
  Secunda.OnUserSave(self)
end

function User:CheckAuth(callback)
  local isLogged = true
  SetTimer(1, function() callback(isLogged) end)
end

function User:GetAccountVar(varName)
  if self.account == nil then return nil end
  return self.account[varName]
end

function User:SetAccountVar(varName, newValue, forceChanges)
  if self.account == nil then return nil end
  if forceChanges then
    self:_PrepareAccountToSave()
  end
  self.account[varName] = newValue
  if forceChanges then
    self:_ApplyAccount()
  end
end

function User:ShowRaceMenu()
  self.pl:ShowMenu("RaceSex Menu")
  self.pl:SetVirtualWorld(1000000)
end

function User:UnequipAll()
  for i = 1, self.pl:GetNumInventorySlots() do
    local itemType = self.pl:GetItemTypeInSlot(i)
    for handID = -1, 1 do self.pl:UnequipItem(itemType, handID) end
  end
end

function User:SetTempVar(varName, newVal)
  local oldVal = self.tempVars[varName]
  self.tempVars[varName] = newVal
  Secunda.OnUserTempVarAssign(self, varName, oldVal, newVal)
end

function User:GetTempVar(varName)
  return self.tempVars[varName]
end

function User:ForceFirstPerson()
  self.pl:ExecuteCommand("cdscript", "Game.ForceFirstPerson()")
end

function User:ForceThirdPerson()
  self.pl:ExecuteCommand("cdscript", "Game.ForceThirdPerson()")
end

function User:AddTask(f)
  table.insert(self.tasksOnSpawn, f)
end

--[[ IMPLEMENTATION ]]--

-- Get/Set for save and load

function User:_GetLook()
  local player = self.pl
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

function User:_SetLook(look)
	if not look then return end
  pcall(function()
   local player = self.pl
	 player:SetRace(Race(look.raceID))
	 player:SetWeight(look.weight)
	 player:SetFemale(look.isFemale)
	 player:SetSkinColor(look.skinColor)
	 player:SetHairColor(look.hairColor)
	 player:SetHeadpartIDs(look.headparts)
	 player:RemoveAllTintmasks()
	 for i = 1, #look.tints do
		  local tint = look.tints[i]
      -- This string will crash the game! Someone (server/client/gamemode) must check tintmasks!
		  --player:AddTintmask(i, tint.texture, tint.type, tint.color, tonumber(tint.alpha))
		  player:AddTintmask(tint.texture, tint.type, tint.color, tonumber(tint.alpha))
	 end
	 player:SetFacePresets(look.facePresets)
	 local faceOptions = {}
	 for i = 1, #look.faceOptions do
		  table.insert(faceOptions,tonumber(look.faceOptions[i]))
	 end
	 player:SetFaceOptions(faceOptions)
	 player:SetHeadTextureSetID(look.headTexture)
  end)
end

function User:_GetActorValues()
  local player = self.pl
	local avNames = {
		"Health", "Magicka", "Stamina",
		"HealRate", "MagickaRate", "StaminaRate",
		"OneHanded", "TwoHanded", "Marksman", "Block", "Smithing", "HeavyArmor", "LightArmor", "Pickpocket", "Lockpicking", "Sneak",
		"Alchemy", "Speechcraft", "Alteration", "Conjuration", "Destruction", "Illusion", "Restoration", "Enchanting",
		"CarryWeight",
    "Level", "PerkPoints", "Experience"
	}
  local skillNames = {
    "OneHanded", "TwoHanded", "Marksman", "Block", "Smithing", "HeavyArmor", "LightArmor", "Pickpocket", "Lockpicking", "Sneak",
		"Alchemy", "Speechcraft", "Alteration", "Conjuration", "Destruction", "Illusion", "Restoration", "Enchanting"
  }

	local avs = {}

	for i = 1, #avNames do
		avs[avNames[i]] = math.floor(player:GetBaseAV(avNames[i]))
    local v = math.floor(player:GetCurrentAV(avNames[i]))
    if v == 0 then
      v = 1 -- Zero values will break account
    end
		avs[avNames[i] .. "_CURRENT"] = v
	end
  for i = 1, #skillNames do
    avs[skillNames[i] .. "_EXP"] = math.floor(player:GetSkillExperience(skillNames[i]))
  end

	return avs
end

function User:_SetActorValues(avs)
	if not avs then return end

  local player = self.pl

	for key, value in pairs(avs) do
    if key == "Level" then
      player:ExecuteCommand("console", "player.setlevel " .. value)
    end
		if key:gsub("_CURRENT", "") ~= key then
      if (value == 1 or value == 0) and key == "Health_CURRENT" then
        self:AddTask(function() player:SetCurrentAV("Health", 1) end)
      else
			     player:SetCurrentAV(key:gsub("_CURRENT", ""), value)
      end
    elseif key:gsub("_EXP", "") ~= key then
      player:SetSkillExperience(key:gsub("_EXP", ""), value)
		else
			player:SetBaseAV(key, value)
		end
	end
end

function User:_GetPerks()
  local perks = self:GetPerks()
  for i = 1, #perks do
    perks[i] = perks[i]:GetID()
  end
  return perks
end

function User:_SetPerks(perkIds)
  self:RemoveAllPerks()
  if perkIds ~= nil then
    for i = 1, #perkIds do
      self:AddPerk(Perk.LookupByID(perkIds[i]))
    end
  end
end

function User:_GetMagic()
  local magicIds = {}
  for i = 1, self.pl:GetNumMagic() do
    table.insert(magicIds, self.pl:GetNthMagic(i):GetBaseID())
  end
  return magicIds
end

function User:_SetMagic(magicIds)
  self.pl:RemoveAllMagic()
  if magicIds ~= nil then
    for i = 1, #magicIds do
      self.pl:AddMagic(Magic2.Lookup(magicIds[i]))
    end
  end
end

function User:_GetInventoryStr()
  local cont = Container(self.pl)
  return ContainerSerializer.Serialize(cont)
end

function User:_SetInventoryStr(inventoryStr)
  local cont = type(inventoryStr) == "string" and ContainerSerializer.Deserialize(inventoryStr) or Container()
  cont:ApplyTo(self.pl)
end

function User:_GetEquipment()
  local armor = {}
  local leftHand = -1
  local rightHand = -1
  for i = 1, self.pl:GetNumInventorySlots() do
    local itemType = self.pl:GetItemTypeInSlot(i)
    if itemType ~= nil and self.pl:IsEquipped(itemType) then
      if itemType:GetClass() == "Weapon" then
        if self.pl:GetEquippedWeapon(0) == itemType then
          rightHand = i
        end
        if self.pl:GetEquippedWeapon(1) == itemType then
          leftHand = i
        end
      elseif itemType:GetClass() == "Armor" then
        table.insert(armor, i)
      end
    end
  end
  local eq = {}
  table.insert(eq, rightHand)
  table.insert(eq, leftHand)
  for i = 1, #armor do
    table.insert(eq, armor[i])
  end
  return eq
end

function User:_SetEquipment(eq)
  self:UnequipAll()
  for i = 1, #eq do
    local slot = eq[i]
    if slot ~= -1 then
      local itemType = self.pl:GetItemTypeInSlot(slot)
      if i == 1 then
        self.pl:EquipItem(itemType, 0)
      elseif i == 2 then
        --self.pl:EquipItem(itemType, 1)
      else
        self.pl:EquipItem(itemType, -1)
      end
    end
  end
end

function User:_GetLearnedEffects()
  return self.learnedEffects
end

function User:_SetLearnedEffects(learnedEffects)
  if learnedEffects == nil then
    learnedEffects = {}
  end
  self.learnedEffects = learnedEffects
  for baseID, t in pairs(learnedEffects) do
    local itemType = ItemTypes.Lookup(tonumber(baseID))
    if itemType == nil then
      error("bad itemType")
    end
    for i = 1, #t do
      local n = t[i]
      self.pl:SetEffectLearned(itemType, n, true)
    end
  end
end

local function SetWerewolfRaw(pl, isWerewolf)
  local wasWerewolf = pl:IsWerewolf()
  if wasWerewolf ~= isWerewolf then
    pl:SetWerewolf(isWerewolf)
    pl:SetControlEnabled("Menu", not isWerewolf)
    pl:SetControlEnabled("BeastForm", not isWerewolf)
    pl:SetControlEnabled("Sneaking", not isWerewolf)
    pl:SetControlEnabled("CamSwitch", not isWerewolf)
    pl:SetControlEnabled("Activate", not isWerewolf)
    if isWerewolf then
      pl:ExecuteCommand("cdscript", "Game.ForceThirdPerson()")
    else
    pl:ExecuteCommand("cdscript", "Game.ForceFirstPerson()")
    end
  end
end

function User:_ApplyAccount()
  local success, err = pcall(function()
    local account = tablex.deepcopy(self.account)
    self.pl:SetSpawnPoint(Location(account.location), account.x, account.y, account.z, account.angle)
    self.pl:Spawn()
    local isWerewolf = not not account.isWerewolf and account.isWerewolf ~= 0
    SetWerewolfRaw(self.pl, isWerewolf)
    local s = nil
    local e = nil

    s, e = pcall(function() self:_SetLook(json.decode(account.look)) end)
    if not s then print("Error while loading look: " .. e) end

    s, e = pcall(function() self:_SetActorValues(json.decode(account.avs)) end)
    if not s then print("Error while loading avs: " .. e) end

    s, e = pcall(function() self:_SetPerks(json.decode(account.perks)) end)
    if not s then print("Error while loading perks: " .. e) end

    s, e = pcall(function() self:_SetMagic(json.decode(account.magic)) end)
    if not s then print("Error while loading magic: " .. e) end

    s, e = pcall(function() self:_SetInventoryStr(account.inventoryStr) end)
    if not s then print("Error while loading inventory: " .. e) end

    s, e = pcall(function() self:_SetLearnedEffects(pretty.read(account.learnedEffects)) end)
    if not s then print("Error while loading learned effects: " .. e) end

    s, e = pcall(function() self:_SetEquipment(json.decode(account.equipment)) end)
    if not s then print("Error while loading equipment: " .. e) end
  end)
  if not success then
    print(err)
    self.pl:Kick()
  end
end

function User:_PrepareAccountToSave()
  local player = self.pl
  local location = player:GetLocation()
  if location ~= nil then
    self.account.location = location:GetID()
  else
    self.account.location = 60
  end
  local x, y, z = self.account.x, self.account.y, self.account.z
  self.account.x = math.floor(player:GetX())
  self.account.y = math.floor(player:GetY())
  self.account.z = math.floor(player:GetZ())
  if self.account.x == 0 then self.account.x = x; print("would break spawnpoint") end
  if self.account.y == 0 then self.account.y = y; print("would break spawnpoint") end
  if self.account.z == 0 then self.account.z = z; print("would break spawnpoint") end
  self.account.angle = math.floor(player:GetAngleZ())
  self.account.look = json.encode(self:_GetLook())
  self.account.avs = json.encode(self:_GetActorValues())
  self.account.perks = json.encode(self:_GetPerks())
  self.account.magic = json.encode(self:_GetMagic())
  self.account.inventoryStr = self:_GetInventoryStr()
  self.account.learnedEffects = pretty.write(self:_GetLearnedEffects())
  self.account.equipment = json.encode(self:_GetEquipment())
end

function User:_UpdateDisplayGold()
  if User.gGold == nil then
    local idGold001 = 0x0000000F
    User.gGold = ItemTypes.Lookup(idGold001)
  end
  self.pl:SetDisplayGold(self.pl:GetItemCount(User.gGold))
end

-- ...

local function SetUserCtorEnabled(enabled)
  if enabled then
    gUserCtorEnabled = true
  else
    gUserCtorEnabled = false
  end
end

local function IsUserCtorEnabled(enabled)
  return gUserCtorEnabled
end

local function NewUser(pl)
  SetUserCtorEnabled(true)
  local user = User(pl)
  SetUserCtorEnabled(false)
  gUsersMap[pl:GetName()] = user
  gUsersMap[pl:GetID()] = user
  return user
end

local function DeleteUser(pl)
  gUsersMap[pl:GetName()] = nil
  gUsersMap[pl:GetID()] = nil
end

function User:_init(pl)
  if not gUserCtorEnabled then
    error("user ctor is disabled")
  end
  if pl == nil then
    error "nil player"
  end
  if pl:IsNPC() and gUserTested then
    error "unexcepted npc"
  end
  self.pl = pl
  self.name = pl:GetName()
  self.id = pl:GetID()
  self.perksMap = {}
  self.tasksOnSpawn = {}
  self.learnedEffects = {}
  self.tempVars = {}
end

function User:__index(key)
  if self ~= nil then
    return User.Index(self, key)
  end
end

function User:GetID()
  return self.id
end

function User:GetName()
  return self.name
end

function User:SetName(newName)
  self.name = newName
  self.pl:SetName(newName)
end

function User:SendChatMessage(text)
  self.pl:SendChatMessage(ru(text))
end

function User:SetChatBubble(text, time)
  self.pl:SetChatBubble(ru(text), time)
end

function User:AddPerk(perk)
  self.pl:AddPerk(perk)
  self.perksMap[perk:GetID()] = true
end

function User:RemovePerk(perk)
  self.pl:RemovePerk(perk)
  self.perksMap[perk:GetID()] = nil
end

function User:HasPerk(perk)
  return self.perksMap[perk:GetID()] == true
end

function User:AddItem(itemType, count)
  self.pl:AddItem(itemType, count)
  self:_UpdateDisplayGold()
end

function User:RemoveItem(itemType, count)
  local res = self.pl:RemoveItem(itemType, count)
  self:_UpdateDisplayGold()
  return res
end

function User:RemoveAllItems()
  self.pl:RemoveAllItems()
  self:_UpdateDisplayGold()
end

function User:ShowDialog(did, style, title, text, defaultIndex)
  if defaultIndex == nil then defaultIndex = -1 end
  self.pl:ShowDialog(did, ru(style), ru(title), ru(text), defaultIndex)
end

function User:GetPerks()
  local perks = {}
  for k, v in pairs(self.perksMap) do
    table.insert(perks, Perk.LookupByID(k))
  end
  return perks
end

function User:RemoveAllPerks()
  local perks = self:GetPerks()
  for i = 1, #perks do
    self:RemovePerk(perks[i])
  end
  self.perksMap = {}
end

function User.HasOverride(key)
  local hasOverride = {
    GetID = true,
    GetName = true,
    SetName = true,
    SendChatMessage = true,
    SetChatBubble = true,
    AddPerk = true,
    RemovePerk = true,
    HasPerk = true,
    AddItem = true,
    RemoveItem = true,
    RemoveAllItems = true,
    ShowDialog = true
  }
  return hasOverride[key]
end

function User.Index(self, key)
  local result = rawget(self, key)
  if result == nil then
    result = function(badSelf, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
      local success
      local pcallResult
      local foundMethodInPlayer = false
      if not User.HasOverride(key) then
        success, pcallResult = pcall(function()
          return self.pl[key](self.pl, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
        end)
        foundMethodInPlayer = success
      end
      if foundMethodInPlayer then
        return pcallResult
      else
        local indexBackup = User.__index
        User.__index = User
        local hasFunction, err = pcall(function()
          pcallResult = self[key](badSelf, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
        end)
        User.__index = indexBackup
        if not hasFunction then
          error("error when calling '" .. key .. "'" .. ":" .. " " .. err)
        end
        return pcallResult
      end
    end
  end

  return result
end

-- Implementation: Callbacks

function User.OnServerInit()
  return true
end

function User.OnPlayerConnect(pl)
  pl:SetSoulSize(0)
  if pl:IsNPC() == false then
    local user = NewUser(pl)
    Secunda.OnUserConnect(user)
  end
  return true
end

function User.OnPlayerDisconnect(pl)
  --if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    if user ~= nil then
      Secunda.OnUserDisconnect(user)
      DeleteUser(pl)
    end
  --end
  return true
end

function User.OnPlayerCharacterCreated(pl)
  if pl:IsNPC() == false then
    local lastVw = pl:GetVirtualWorld()
    SetTimer(4000, function()
      if pl:GetVirtualWorld() == lastVw then pl:SetVirtualWorld(0); print("switch vw") end
    end)
    local user = User.Lookup(pl:GetName())
    user:Save()
    Secunda.OnUserCharacterCreated(user)
  end
  return true
end

local function Every1000ms(id)
  local user = User.Lookup(id)
  if user ~= nil then
    Secunda.OnEvery1000ms(user)

    if user.pl:IsSpawned() then
      if #user.tasksOnSpawn > 0 then
        for i = 1, #user.tasksOnSpawn do
          user.tasksOnSpawn[i]()
        end
        user.tasksOnSpawn = {}
      end
    end

  end
  SetTimer(1000, function() Every1000ms(id) end)
end

function User.OnPlayerSpawn(pl)
  local id = pl:GetID()
  if not gIsTimerStarted[id] then
    gIsTimerStarted[id] = true
    SetTimer(1, function() Every1000ms(id) end)
  end

  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    Secunda.OnUserSpawn(user)
  end
  return true
end

function User.OnPlayerChatInput(pl, input)
  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    if stringx.at(input, 1) ~= "/" then
      Secunda.OnUserChatMessage(user, deru(input))
    else
      Secunda.OnUserChatCommand(user, deru(input))
    end
  end
  return true
end

function User.OnPlayerLearnPerk(pl, perk)
  if perk:IsPlayable() == false then
    error "non-playable perk"
  end
  local user = User.Lookup(pl:GetName())
  if user:HasPerk(perk) then
    return true
  end
  user:AddPerk(perk)
  Secunda.OnUserLearnPerk(user, perk)
  pl:SendChatMessage("Learn perk " .. perk:GetID())
  SetTimer(2000, function()
    -- Bug on client side: all perks will be removed after learning any perk
    local perks = user:GetPerks()
    for i = 1, #perks do
      user:RemovePerk(perks[i])
    end
    for i = 1, #perks do
      user:AddPerk(perks[i])
    end
  end)
  return true
end

function User.OnPlayerDying(pl, killer)
  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    local killerUser = nil
    if killer ~= nil and killer:IsNPC() == false then
      killerUser = User.Lookup(killer:GetName())
    end
    Secunda.OnUserDying(user, killerUser)
  end
  return true
end

function User.OnPlayerDataSearchResult(pl, opcode, res)
  local user = User.Lookup(pl:GetName())
  Secunda.OnUserDataSearchResult(user, opcode, res)
  return true
end

function User.OnPlayerHitObject(pl, object, weap, ammo, spell)
  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    local wo = WorldObject.Lookup(object:GetID())
    if wo ~= nil then
      return Secunda.OnHit(user, wo)
    end
  end
  return true
end

function User.OnPlayerHitPlayer(pl, target, weap, ammo, spell)
  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    local targetUser = User.Lookup(target:GetName())
    if targetUser ~= nil then
      return Secunda.OnHit(user, targetUser, weap, ammo, spell)
    else
      local npc = NPC.Lookup(target:GetID())
      if npc ~= nil then
        return Secunda.OnHit(user, npc, weap, ammo, spell)
      end
    end
  end
  return true
end

function User.OnPlayerActivateObject(pl, object)
  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    --user:_UpdateDisplayGold()
    local wo = WorldObject.Lookup(object:GetID())
    if wo ~= nil then
      return Secunda.OnActivate(user, wo)
    end
  end
  return true
end

local droppedObjectsQueue = {}

function User.OnPlayerDropObject(pl, object)
  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    local wo = WorldObject.Create("dummy", object)
    SetTimer(1, function() user:_UpdateDisplayGold() end)
    object:SetPos(pl:GetX() + 8.0, pl:GetY() + 9.0, pl:GetZ() + 12.0) -- Change default dropped item offset from player

    if droppedObjectsQueue[pl:GetID()] == nil then droppedObjectsQueue[pl:GetID()] = {} end
    table.insert(droppedObjectsQueue[pl:GetID()], object)
    if #droppedObjectsQueue[pl:GetID()] > 11 then
      local toFreeze = droppedObjectsQueue[pl:GetID()][1]
      toFreeze:SetHostable(false)
      table.remove(droppedObjectsQueue[pl:GetID()], 1)
    end
  end
  return true
end

function User.OnPlayerLearnEffect(pl, itemType, n)
  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    Secunda.OnUserLearnEffect(user, itemType, n)
    if ItemTypes.IsFromDS(itemType) then -- Learning effects on custom ItemType is not implemented
      local baseID = itemType:GetBaseID()
      if user.learnedEffects[baseID] == nil then
        user.learnedEffects[baseID] = {}
      end
      table.insert(user.learnedEffects[baseID], n)
    end
  end
  return true
end

function User.OnPlayerEatItem(pl, itemType)
  return User.OnPlayerUseItem(pl, itemType)
end

function User.OnPlayerUseItem(pl, itemType)
  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    return Secunda.OnUserUseItem(user, itemType)
  end
  return true
end

function User.OnPlayerBowShot(pl, power)
  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    return Secunda.OnUserBowShot(user, power)
  end
  return true
end

function User.OnPlayerDialogResponse(pl, dialogId, inputText, listItem)
  local user = User.Lookup(pl:GetID())
  if user then return Secunda.OnUserDialogResponse(user, dialogId, inputText, listItem) end
  return true
end

function User.OnPlayerCreateItem(pl, itemType, count)
  local user = User.Lookup(pl:GetID())
  if user then return Secunda.OnUserCraftItem(user, itemType, count) end
  return true
end

function User.RunTests()

  local Test_SetUserCtorEnabled = function()
    local pl = Player.CreateNPC(0x00000014)
    pl:SetName("Test")

    local wasEnabled = IsUserCtorEnabled()
    SetUserCtorEnabled(false)
    local success, errorText = pcall(function() local usr = User(pl) end)
    if success then
      error("test failed - Ctor was not disabled")
    end
    SetUserCtorEnabled(true)
    local success, errorText = pcall(function() local usr = User(pl) end)
    if not success then
      error("test failed - Unable to construct User " .. errorText)
    end
    SetUserCtorEnabled(wasEnabled)

    pl:Kick()
  end

  local Test_NewUser = function()
    local pl = Player.CreateNPC(0x00000014)
    pl:SetName("Test")

    local user = NewUser(pl)

    if user == nil then
      error("test failed - Unable to create user")
    end

    local userStr = user:GetName()
    if tostring(user) ~= userStr then
      error("test failed - Operator tostring failed (" .. tostring(tostring(user)) .. " ~= "  .. userStr .. ")")
    end

    if not user:is_a(User) then
      error("test failed - User is not user")
    end

    if user ~= User.Lookup(pl:GetName()) then
      error("test failed - Lookup failed")
    end

    if user ~= User.Lookup(pl:GetID()) then
      error("test failed - Lookup by ID failed")
    end

    user:SetBaseAV("Health", 200)
    local av = user:GetBaseAV("Health")
    if av ~= 200 then
      error("test failed - Index failed (" .. tostring(av) .. " ~= "  .. 200 .. ")")
    end

    if user:GetID() ~= pl:GetID() then
      error("test failed - Bad ID (" .. tostring(user:GetID()) .. " ~= "  .. tostring(pl:GetID()) .. ")")
    end

    if user:GetName() ~= pl:GetName() then
      error("test failed - Bad Name (" .. tostring(user:GetName()) .. " ~= "  .. tostring(pl:GetName()) .. ")")
    end

    user:SetVirtualWorld(1)

    pl:Kick()
  end

  Test_SetUserCtorEnabled()
  Test_NewUser()

  gUserTested = true

end

return User
