local Debug = {}

Debug.emptyTip = ""

function Debug.GetPassCode()
  return 228228
end

function Debug.IsDeveloper(user)
  return not not user:GetAccountVar("developerMode")
end

function Debug.OnServerInit()

  local secretlogin = Command("/secretlogin", "i", Debug.emptyTip, function(user, args)
    if args[1] == Debug.GetPassCode() then
      local devMode = Debug.IsDeveloper(user)
      if not devMode then
        user:SendChatMessage(Theme.success .. "Режим разработчика активирован на вашем аккаунте")
        devMode = true
      else
        user:SendChatMessage(Theme.success .. "Режим разработчика деактивирован на вашем аккаунте")
        devMode = false
      end
      print(tostring(user) " - developerMode = " .. tostring(devMode))
      user:SetAccountVar("developerMode", devMode)
      user:Save()
    end
    return true
  end)

  local setav = Command("/setav", "sf", "/setav <av> <value>", function(user, args)
    if type(args[1]) == "string" and type(args[2]) == "number" then
      user:SetBaseAV(args[1], args[2])
      user:SendChatMessage(Theme.info .. "Значение " .. Theme.sel .. args[1]:lower() .. Theme.info .. " теперь равно " .. Theme.sel .. tostring(args[2]));
      return true
    end
    return not Debug.IsDeveloper(user)
  end)

  local setexp = Command("/setexp", "sf", "/setexp <skill> <value>", function(user, args)
    if type(args[1]) == "string" and type(args[2]) == "number" then
      user:SetSkillExperience(args[1], args[2])
      user:SendChatMessage(Theme.info .. "Процент опыта для навыка " .. Theme.sel .. args[1]:lower() .. Theme.info .. " теперь равен " .. Theme.sel .. tostring(args[2]));
      return true
    end
    return not Debug.IsDeveloper(user)
  end)

end

return Debug
