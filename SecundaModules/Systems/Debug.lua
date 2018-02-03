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

  local setexp = Command("/setexp", "sf", "/setexp <skill> <value>", function(user, args)
    if not Debug.IsDeveloper(user) then
      return true
    end
    if type(args[1]) == "string" and type(args[2]) == "number" then
      user:SetSkillExperience(args[1], args[2])
      user:SendChatMessage(Theme.info .. "Процент опыта для навыка " .. Theme.sel .. args[1]:lower() .. Theme.info .. " теперь равен " .. Theme.sel .. tostring(args[2]));
      return true
    end
    return not Debug.IsDeveloper(user)
  end)


  local valhelp = Command("/valhelp", "", Debug.emptyTip, function(user)
    if not Debug.IsDeveloper(user) then
      return true
    end
    user:SendChatMessage(Theme.info .. "sections: av, avcurrent, skillexp, acc")
    user:SendChatMessage(Theme.info .. "actions: set, get")
    user:SendChatMessage(Theme.info .. "Только для значений типа " .. Theme.sel .. "number")
    return true
  end)

  local val = Command("/val", "ssssf", "/val <userName> <section> <variableName> <set/get> <value> (/valhelp)", function(user, args)
    if not Debug.IsDeveloper(user) then
      return true
    end
    local userName = args[1]
    local section = args[2]
    local varName = args[3]
    local action = args[4]
    local value = args[5]
    if type(userName) == "string" and type(section) == "string" and type(varName) == "string" and type(action) == "string" and type(value) == "number" then
      local targets = {}

      -- Form targets
      if userName == "*" then
        targets = User.GetAllUsers()
      else
        local usr = User.Lookup(userName)
        if usr then
          table.insert(targets, usr)
        else
          user:SendChatMessage(Theme.error .. "Игрок с именем " .. userName .. " не найден")
        end
      end

      if targets ~= nil and #targets ~= 0 then
        for i = 1, #targets do
          local target = targets[i]
          if target ~= nil then
            local set = nil
            local get = nil
            if section == "av" then
              set = function(newVal)
                target:SetBaseAV(varName, newVal)
              end
              get = function()
                return target:GetBaseAV(varName)
              end
            elseif section == "avcurrent" then
              set = function(newVal)
                target:SetCurrentAV(varName, newVal)
              end
              get = function()
                return target:GetCurrentAV(varName)
              end
            elseif section == "skillexp" then
              set = function(newVal)
                target:SetSkillExperience(varName, newVal)
              end
              get = function()
                return target:GetSkillExperience(varName)
              end
            elseif section == "acc" then
              set = function(newVal)
                target:SetAccountVar(varName, newVal)
              end
              get = function()
                return target:GetAccountVar(varName)
              end
            end
            if set == nil or get == nil then
              user:SendChatMessage(Theme.error .. "Секция не найдена (" .. section .. ")")
              return true
            end
            if action == "get" then
              local res = get()
              local del = Theme.info .. " -> " .. Theme.sel
              local eq = Theme.info .. " = " .. Theme.sel
              user:SendChatMessage(Theme.sel .. target:GetName() .. del .. section .. del .. varName .. eq .. tostring(res))
            elseif action == "set" then
              set(value)
              local del = Theme.info .. " -> " .. Theme.sel
              local eq = Theme.info .. " теперь равно " .. Theme.sel
              user:SendChatMessage(Theme.sel .. target:GetName() .. del .. section .. del .. varName .. eq .. tostring(res))
              target:Save()
            else
              user:SendChatMessage(Theme.error .. "Операция не найдена (" .. action .. ")")
              return true
            end
          end
        end
      end

      return true
    end
    return false
  end)

end

return Debug
