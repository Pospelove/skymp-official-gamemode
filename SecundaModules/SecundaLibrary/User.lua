User = class()

function User.Docs()
  return [[
  -- Static methods:
  User.Lookup(key) -- Lookup user by key (ID or Name)
  User.GetAllUsers() -- Get list of users
  User.GetUsersMap() -- Get map-like table of users, faster than GetAllUsers() (example: user = User.GetUsersMap()["Pospelov"])

  -- Methods:
  tostring(user) -- Convert user to "<name>[<id>]" string (example: Pospelov[0])
  user:Load() -- Load account
  user:Save() -- Save account
  user:CheckAuth(callback) -- Async check if user is logged. Calls callback(true) if is logged or callback(false) if not
  user:GetAccountVar(varName) -- Get value of account variable with specified name
  user:SetAccountVar(varName, newValue) -- Change account var value. It's OK to use in OnUserLoad
  user:ShowRaceMenu() -- Show the character editor

  -- Callbacks:
  OnUserLoad(user) -- Called from user:Load() when loading account
  OnUserSave(user) -- Called from user:Save() when account is saved (NOT saving)
  OnUserConnect(user) --
  OnUserDisconnect(user) --
  OnUserSpawn(user) --
  OnUserCharacterCreated(user) --
  OnUserChatMessage(user, text) -- Called on chat message (not command)
  OnUserLearnPerk(user, perk) --
  ]]
end

-- Private variables

local gUserCtorEnabled = true
local gUsersMap = {}
local gUserTested = false

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
  return self:GetName() .. "[" .. self:GetID() .. "]"
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

function User:SetAccountVar(varName, newValue)
  if self.account == nil then return nil end
  self.account[varName] = newValue
end

function User:ShowRaceMenu()
  self.pl:ShowMenu("RaceSex Menu")
  self.pl:SetVirtualWorld(1000000)
end

function User:AddTask(conditionStr, f)
  if self.tasks == nil then
    self.tasks = {}
  end
  local t = {}
  t.cond = conditionStr
  t.f = f
  table.insert(self.tasks, t)
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
		if key:gsub("_CURRENT", "") ~= key then
      if value == 1 and key == "Health_CURRENT" then
        self:AddTask("IsSpawned", function() player:SetCurrentAV("Health", 0) end)
      end
			player:SetCurrentAV(key:gsub("_CURRENT", ""), value)
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

function User:_ApplyAccount()
  local success, err = pcall(function()
    local player = self.pl
    local account = tablex.deepcopy(self.account)
    player:SetSpawnPoint(Location(account.location), account.x, account.y, account.z, account.angle)
    player:Spawn()
    local s = nil
    local e = nil
    s, e = pcall(function() self:_SetLook(json.decode(account.look)) end)
    if not s then print(e) end
    s, e = pcall(function() self:_SetActorValues(json.decode(account.avs)) end)
    if not s then print(e) end
    s, e = pcall(function() self:_SetPerks(json.decode(account.perks)) end)
    if not s then print(e) end
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
  self.account.x = math.floor(player:GetX())
  self.account.y = math.floor(player:GetY())
  self.account.z = math.floor(player:GetZ())
  self.account.angle = math.floor(player:GetAngleZ())
  self.account.look = json.encode(self:_GetLook())
  self.account.avs = json.encode(self:_GetActorValues())
  self.account.perks = json.encode(self:_GetPerks())
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
end

function User.HasOverride(key)
  local hasOverride = {
    GetID = true,
    GetName = true,
    SetName = true,
    SendChatMessage = true,
    AddPerk = true,
    RemovePerk = true,
    HasPerk = true
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
    pl:SetVirtualWorld(0)
    local user = User.Lookup(pl:GetName())
    user:Save()
    Secunda.OnUserCharacterCreated(user)
  end
  return true
end

function User.OnPlayerSpawn(pl)
  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    Secunda.OnUserSpawn(user)
  end
  return true
end

function User.OnPlayerChatInput(pl, input)
  if pl:IsNPC() == false then
    if stringx.at(input, 1) ~= "/" then
      local user = User.Lookup(pl:GetName())
      Secunda.OnUserChatMessage(user, deru(input))
    end
  end
  return true
end

function User.OnPlayerLearnPerk(pl, perk)
  if perk:IsPlayable() == false then
    error "non-playable perk"
  end
  local user = User.Lookup(pl:GetName())
  user:AddPerk(perk)
  Secunda.OnUserLearnPerk(user, perk)
  return true
end

function User.OnPlayerUpdate(pl)
  if pl:IsNPC() == false then
    local user = User.Lookup(pl:GetName())
    if user.tasks ~= nil then
      local tasks = tablex.deepcopy(user.tasks)
      local newTasks = nil
      for i = 1, #tasks do
        if user[tasks[i].cond]() then
          tasks[i].f()
        else
          if newTasks == nil then
            newTasks = {}
          end
          table.insert(newTasks, tasks[i])
        end
      end
      user.tasks = newTasks
    end
  end
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

    local userStr = user:GetName() .. "[" .. user:GetID() .. "]"
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
