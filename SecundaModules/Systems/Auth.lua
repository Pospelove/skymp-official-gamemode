Auth = {}

-- Key is user ID
local gLoggedMap = {}
local gLoadMsgStateMap = {}
local gMaxLoadState = 32

local function LoadingMsgStep(user)
  local id = user:GetID()
  if gLoadMsgStateMap[id] == nil then
    return
  end

  if gLoadMsgStateMap[id] >= gMaxLoadState then
    return
  end

  local base = Theme.info .. ru "Загрузка"
  local addiTxt = {"", ".", "..", "..."}

  user:ClearChat()
  local addiIdx = 1 + gLoadMsgStateMap[id] % 4
  user:SendChatMessage(base .. addiTxt[addiIdx])

  gLoadMsgStateMap[id] = gLoadMsgStateMap[id] + 1
  if gLoadMsgStateMap[id] < gMaxLoadState then
    SetTimer(200, function() LoadingMsgStep(user) end)
  end
end

local function ShowLoadingMessage(user)
  gLoadMsgStateMap[user:GetID()] = 1
  LoadingMsgStep(user)
end

local function StopLoadingMessage(user)
  gLoadMsgStateMap[user:GetID()] = gMaxLoadState
end

function Auth.OnUserConnect(user)
  --user:SetVirtualWorld(user:GetID())
  gLoggedMap[user:GetID()] = false
  ShowLoadingMessage(user)
  user:CheckAuth(function(isLogged)
    SetTimer(2000, function()
      StopLoadingMessage(user)
      user:ClearChat()
      if isLogged then
        user:SendChatMessage(Theme.success .. ru "С возвращением, " .. user:GetName())
        user:Load()
      else
        user:SendChatMessage(Theme.error .. ru "Вы не были авторизированы")
        user:Kick()
      end
    end)
  end)
end

function Auth.OnUserLoad(user)
  print("Account loaded: " .. tostring(user))
end

function Auth.OnUserSave(user)
  print("Account saved: " .. tostring(user))
end

function Auth.OnUserDisconnect(user)
  user:Save()
  local id = user:GetID()
  gLoggedMap[id] = nil
  gLoadMsgStateMap[id] = nil
end

return Auth
