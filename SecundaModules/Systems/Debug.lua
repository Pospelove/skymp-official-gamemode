Debug = {}

Debug.emptyTip = ""

function Debug.GetPassCode()
  return 228228
end

function Debug.IsDeveloper(user)
  return not not user:GetAccountVar("developerMode")
end

function Debug.OnUserChatCommand(user, cmd)
  local tokens = stringx.split(cmd)

  if stringx.stastswith(cmd, "/secretlogin ") then
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

  if stringx.stastswith(cmd, "/setav ") then
    if not Debug.IsDeveloper(user) then
      return true
    end
    if tokens[2] ~= nil and tokens[3] ~= nil then
      user:SetBaseAV(tokens[2], tonumber(tokens[3]))
      user:SendChatMessage(Theme.info .. "Значение " .. Theme.sel .. tokens[2]:lower() .. Theme.info .. " теперь равно " .. Theme.sel .. tokens[3]);
      return true
    end
  end

  if stringx.stastswith(cmd, "/setflag ") then
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
        DS.UpdatePermissions()
      end
    end
  end

  if stringx.stastswith(cmd, "/incrskill ") then
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

  return true
end

return Debug
