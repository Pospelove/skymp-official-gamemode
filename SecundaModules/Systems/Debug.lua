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
        user:SendChatMessage(Theme.success .. "Режим разработчика активирован на вашем аккаунте")
        devMode = true
      else
        user:SendChatMessage(Theme.success .. "Режим разработчика деактивирован на вашем аккаунте")
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
      user:SendChatMessage(Theme.info .. "Значение " .. Theme.sel .. tokens[2]:lower() .. Theme.info .. " теперь равно " .. Theme.sel .. tokens[3]);
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
        user:SendChatMessage(Theme.info .. "Значение " .. Theme.sel .. tokens[2] .. Theme.info .. " теперь равно " .. Theme.sel .. tokens[3])
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
      user:SendChatMessage(Theme.success .. "Удалено " .. n .. " экземпляров")
    else
      if tokens[2] ~= nil then
        user:SendChatMessage(Theme.error .. "Неизвестный раздел")
      else
        user:SendChatMessage(Theme.error .. "Вы не ввели название раздела")
      end
      return true
    end
  end

  if tokens[1] == "/hittask" then
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
      user:SendChatMessage(Theme.error .. "Вы не ввели строку на Lua")
    end
  end

  if tokens[1] == "/cmd" then
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

  return true
end

function Debug.OnHit(source, target)
  if source:is_a(User) then
    local hittask = source:GetAccountVar("hittask")
    if hittask == nil or hittask == "" then
      return true
    end
    if target:is_a(WorldObject) then
      self = target -- global
      local f = loadstring(hittask)
      local res = f()
      self = nil
      if res ~= nil then
        user:SendChatMessage(Theme.info .. "Возвращено значение " .. Theme.sel .. tostring(res))
      end
    end
  end
  return true
end

return Debug
