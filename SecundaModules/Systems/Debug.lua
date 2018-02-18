Debug = {}

Debug.emptyTip = ""

function Debug.GetPassCode()
  return "228228"
end

function Debug.IsDeveloper(user)
  return not not user:GetAccountVar("developerMode")
end

function Debug.OnUserChatCommand(user, cmd)
  local tokens = stringx.split(cmd)

  if stringx.startswith(cmd, "/secretlogin ") then
    if tokens[2] == Debug.GetPassCode() then
      local devMode = Debug.IsDeveloper(user)
      if not devMode then
        user:SendChatMessage(Theme.success .. "����� ������������ ����������� �� ����� ��������")
        devMode = true
      else
        user:SendChatMessage(Theme.success .. "����� ������������ ������������� �� ����� ��������")
        devMode = false
      end
      print(tostring(user) .. " - developerMode = " .. tostring(devMode))
      user:SetAccountVar("developerMode", devMode)
      user:Save()
    end
  end

  if stringx.startswith(cmd, "/setav ") then
    if not Debug.IsDeveloper(user) then
      return true
    end
    if tokens[2] ~= nil and tokens[3] ~= nil then
      user:SetBaseAV(tokens[2], tonumber(tokens[3]))
      user:SendChatMessage(Theme.info .. "�������� " .. Theme.sel .. tokens[2]:lower() .. Theme.info .. " ������ ����� " .. Theme.sel .. tokens[3]);
      return true
    end
  end

  if stringx.startswith(cmd, "/setflag ") then
    if not Debug.IsDeveloper(user) then
      return true
    end
    if tokens[2] ~= nil and tokens[3] ~= nil then
      tokens[3] = tokens[3]:lower()
      if tokens[3] == "on" or tokens[3] == "off" then
        local on = tokens[3] == "on"
        if isru(tokens[2]) then
          return false
        end
        user:SetAccountVar(tokens[2], on)
        user:SendChatMessage(Theme.info .. "�������� " .. Theme.sel .. tokens[2] .. Theme.info .. " ������ ����� " .. Theme.sel .. tokens[3])
        DS.UpdatePermissions(user)
      end
    end
  end

  if stringx.startswith(cmd, "/incrskill ") then
    if not Debug.IsDeveloper(user) then
      return true
    end
    if tokens[2] == nil then tokens[2] = user:GetName() end
    if tokens[3] == nil then tokens[3] = "Marksman" end
    User.Lookup(tokens[1]):IncrementSkill(tokens[2])
  end

  if cmd == "/kill" then
    if not Debug.IsDeveloper(user) then
      return true
    end
    user:SetCurrentAV("Health", 0.0)
  end

  if tokens[1] == "/drop" then
    if not Debug.IsDeveloper(user) then
      return true
    end
    if tokens[2] == "worldobject" then
      local n = #WorldObject.GetAllWorldObjects()
      WorldObject.DeleteAll()
      user:SendChatMessage(Theme.success .. "������� " .. n .. " �����������")
    else
      if tokens[2] ~= nil then
        user:SendChatMessage(Theme.error .. "����������� ������")
      else
        user:SendChatMessage(Theme.error .. "�� �� ����� �������� �������")
      end
      return true
    end
  end

  if tokens[1] == "/clearloc" then
    if not Debug.IsDeveloper(user) then
      return true
    end
    local loc = user:GetLocation()
    local locID = loc:GetID()
    local wos = WorldObject.GetAllWorldObjects()
    local n = 0
    for i = 1, n do
      if wos[i] ~= nil and wos[i]:GetValue("locationID") == locID then
        n = 1 + n
        wos[i]:Delete()
      end
    end
    user:SendChatMessage(Theme.success .. "������� " .. n .. " �����������")
  end

  if tokens[1] == "/hittask" then
    if not Debug.IsDeveloper(user) then
      return true
    end
    if tokens[2] ~= nil then
      local i = 2
      local str = ""
      while tokens[i] ~= nil do
        str = str .. " " .. tokens[i]
        i = i + 1
      end
      user:SetAccountVar("hittask", str)
      user:SendChatMessage(Theme.info .. str)
    else
      user:SendChatMessage(Theme.error .. "�� �� ����� ������ �� Lua")
    end
  end

  if tokens[1] == "/cmd" then
    if not Debug.IsDeveloper(user) then
      return true
    end
    if tokens[2] ~= nil and tokens[3] ~= nil then
      local i = 3
      local str = ""
      while tokens[i] ~= nil do
        if str:len() == 0 then str = tokens[i] else str = str .. " " .. tokens[i] end
        i = i + 1
      end
      user:SendChatMessage(Theme.sel .. tokens[2] .. Theme.info .. ": " .. str)
      user:ExecuteCommand(tokens[2], str)
    end
  end

  if tokens[1] == "/additem" then
    if not Debug.IsDeveloper(user) then
      return true
    end
    local i = 2
    local str = ""
    while tokens[i] ~= nil do
      if str:len() == 0 then str = tokens[i] else str = str .. " " .. tokens[i] end
      i = i + 1
    end

    local itemType = ItemType.LookupByIdentifier(str)
    if itemType == nil then
      user:SendChatMessage(Theme.error .. "��� �������� �� ������ (" .. tostring(str) .. ")")
    else
      local pl = Player.LookupByName(user:GetName())
      local v = (pl:GetItemCount(itemType))
      user:AddItem(itemType, 1)
      user:SendChatMessage(Theme.success .. "�������� ������ (������ � ��� " .. tostring(pl:GetItemCount(itemType)) .. ", ���� " .. tostring(v) ..")")
    end
  end

  if tokens[1] == "/setval" then
    if not Debug.IsDeveloper(user) then
      return true
    end
    if type(tokens[2]) ~= "string" then
      user:SendChatMessage(Theme.error .. "�� �� ����� �������� ����������")
      return true
    end
    if type(tokens[3]) ~= "string" then
      user:SendChatMessage(Theme.error .. "�� �� ����� ��������")
      return true
    end
    local newVal = tokens[3]
    if tonumber(tokens[3]) ~= nil then
      newVal = tonumber(tokens[3])
    end
    local forceChanges = true
    user:SetAccountVar(tokens[2], newVal, forceChanges)
    user:SendChatMessage(Theme.info .. "�������� " .. Theme.sel .. tokens[2] .. Theme.info .. " ������ ����� " .. Theme.sel .. newVal .. " (" .. type(newVal) .. ")")
    return true
  end

  if tokens[1] == "/regen" then
    if not Debug.IsDeveloper(user) then
      return true
    end
    local wos = WorldObject.GetAllWorldObjects()
    local n = 0
    for i = 1, #wos do
      local wo = wos[i]
      if wo then
        if wo:GetValue("isCollectedItem") then
          n = 1 + n
          wo:SetValue("isCollectedItem", false)
          wo:SetValue("isDisabled", false)
          wo:Save()
        elseif wo:GetValue("isHarvested") then
          n = 1 + n
          wo:SetValue("isHarvested", false)
          local wasDisabled = wo:GetValue("isDisabled")
          wo:SetValue("isDisabled", true)
          SetTimer(500, function()
            wo:SetValue("isDisabled", not not wasDisabled)
            wo:Save()
          end)
        end
      end
    end
    user:SendChatMessage(Theme.success .. "������������� " .. n .. " �����������")
  end

  if tokens[1] == "/countitem" then
    if not Debug.IsDeveloper(user) then
      return true
    end
    local i = 2
    local str = ""
    while tokens[i] ~= nil do
      if str:len() == 0 then str = tokens[i] else str = str .. " " .. tokens[i] end
      i = i + 1
    end
    local itemType = ItemType.LookupByIdentifier(str)
    if itemType == nil then
      user:SendChatMessage(Theme.error .. "��� �������� �� ������ (" .. tostring(str) .. ")")
    else
      local pl = Player.LookupByName(user:GetName())
      local v = (pl:GetItemCount(itemType))
      user:SendChatMessage(Theme.success .. "� ��� " .. tostring(pl:GetItemCount(itemType)))
    end
  end

  if tokens[1] == "/abort" then
    if not Debug.IsDeveloper(user) then
      return true
    end
    user:SendChatMessage(Theme.error .. "������ ����� ���������. ����� �� ��� �������?")
    Terminate()
  end

  return true
end

function Debug.OnHit(source, target)
  if source:is_a(User) then
    local user = source
    local hittask = source:GetAccountVar("hittask")
    if hittask == nil or hittask == "" then
      return true
    end
    if target:is_a(WorldObject) then
      self = target -- global
      local suc, errstr = pcall(function()
        local f = loadstring(hittask)
        local res = f()
        if res ~= nil then
          user:SendChatMessage(Theme.info .. "���������� �������� " .. Theme.sel .. tostring(res))
        end
      end)
      if not suc then
        user:SendChatMessage(Theme.error .. errstr)
      end
      self = nil
    end
  end
  return true
end

return Debug
