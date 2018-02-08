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
      print(tostring(user) .. " - developerMode = " .. tostring(devMode))
      user:SetAccountVar("developerMode", devMode)
      user:Save()
    end
    return true
  end)

  local setav = Command("/setav", "sf", "/setav <av> <value>", function(user, args)
    if not Debug.IsDeveloper(user) then
      return true
    end
    if type(args[1]) == "string" and type(args[2]) == "number" then
      user:SetBaseAV(args[1], args[2])
      user:SendChatMessage(Theme.info .. "Значение " .. Theme.sel .. args[1]:lower() .. Theme.info .. " теперь равно " .. Theme.sel .. tostring(args[2]));
      return true
    end
    return not Debug.IsDeveloper(user)
  end)

  local perk = Command("/perk", "s", "/perk <add/rm>", function(user, args)
    if not Debug.IsDeveloper(user) then
      return true
    end
    local perk = Perk.LookupByID(0xbe126)
    if perk == nil then
      error("bad perk id")
    end
    if args[1] == "rm" then
      user:RemovePerk(perk)
      user:SendChatMessage(Theme.info .. "Перк отнят")
      return true
    elseif args[1] == "add" then
      user:AddPerk(perk)
      user:SendChatMessage(Theme.info .. "Перк выдан")
      return true
    end
    return not Debug.IsDeveloper(user)
  end)
end

return Debug
