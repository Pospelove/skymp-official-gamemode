User = class()

-- Private variables

local gUserCtorEnabled = true
local gUsersMap = {}

-- Interface

function User.Lookup(key)
  return gUsersMap[key]
end

function User:__tostring()
  return self.pl:GetName() .. "[" .. self.pl:GetID() .. "]"
end

-- Implementation

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
  self.pl = pl
end

function User:__index(key)
  if self ~= nil then
    return User.Index(self, key)
  end
end

function User.Index(self, key)
  local result = rawget(self, key)
  if result == nil then
    result = function(badSelf, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
      local foundMethodInPlayer, pcallResult = pcall(function()
        return self.pl[key](self.pl, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
      end)
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
  end
  return true
end

function User.OnPlayerDisconnect(pl)
  if pl:IsNPC() == false then
    DeleteUser(pl)
  end
  return true
end

function User.RunTests()

  local Test_SetUserCtorEnabled = function()
    local wasEnabled = IsUserCtorEnabled()
    SetUserCtorEnabled(false)
    local success, errorText = pcall(function() local usr = User(nil) end)
    if success then
      error("test failed - Ctor was not disabled")
    end
    SetUserCtorEnabled(true)
    local success, errorText = pcall(function() local usr = User(nil) end)
    if not success then
      error("test failed - Ctor was disabled")
    end
    SetUserCtorEnabled(wasEnabled)
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

    user:SetVirtualWorld(1)

    pl:Kick()
  end

  Test_SetUserCtorEnabled()
  Test_NewUser()

end

return User
