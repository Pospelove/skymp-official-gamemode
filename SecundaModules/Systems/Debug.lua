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
    return true
  end)

  local setav = Command("/setav", "sf", "/setav <av> <value>", function(user, args)
    if not Debug.IsDeveloper(user) then
      return true
    end
    if type(args[1]) == "string" and type(args[2]) == "number" then
      user:SetBaseAV(args[1], args[2])
      user:SendChatMessage(Theme.info .. "�������� " .. Theme.sel .. args[1]:lower() .. Theme.info .. " ������ ����� " .. Theme.sel .. tostring(args[2]));
      return true
    end
    return not Debug.IsDeveloper(user)
  end)

  local getav = Command("/getav", "s", "/getav <av>", function(user, args)
    if not Debug.IsDeveloper(user) then
      return true
    end
    if type(args[1]) == "string" then
      user:SendChatMessage(Theme.info .. "�������� " .. Theme.sel .. args[1]:lower() .. Theme.info .. " ����� " .. Theme.sel .. tostring(user:GetBaseAV(args[1])));
      return true
    end
    return not Debug.IsDeveloper(user)
  end)

  local incrskill = Command("/incrskill", "ss", "/incrskill <user name> <skill name>", function(user, args)
    if args[1] == nil then args[1] = user:GetName() end
    if args[2] == nil then args[2] = "Marksman" end
    User.Lookup(args[1]):ShowSkillIncreaseNotification(args[2])
    return true
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
      user:SendChatMessage(Theme.info .. "���� �����")
      return true
    elseif args[1] == "add" then
      user:AddPerk(perk)
      user:SendChatMessage(Theme.info .. "���� �����")
      return true
    end
    return not Debug.IsDeveloper(user)
  end)

  local kill = Command("/kill", "s", "/kill <user name>", function(user, args)
    if args[1] == nil then
      args[1] = user:GetName()
    end
    User.Lookup(args[1]):SetCurrentAV("Health", 0.0)
    return true
  end)
end

return Debug
