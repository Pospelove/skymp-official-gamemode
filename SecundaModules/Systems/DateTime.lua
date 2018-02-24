local DateTime = {}

local gameHour = 0x00000038
local gameDay = 0x00000037
local gameMonth = 0x00000036
local gameYear = 0x00000035
local timeScale = 0x0000003A
local daysPassed = 0x00000039

local knownHour = {}

function DateTime.OnUserUpdate(user)
  local date = os.date("*t")
  if knownHour[user:GetID()] ~= date.hour then
    user:SetGlobal(gameHour, date.hour)
    knownHour[user:GetID()] = date.hour
  end
  return true
end

function DateTime.OnUserConnect(user)
  local date = os.date("*t")
  user:SetGlobal(gameYear, date.year - (2018 - 200))
  user:SetGlobal(gameMonth, date.month)
  user:SetGlobal(gameDay, date.day)
  user:SetGlobal(timeScale, 0)
  local days = 0 -- TODO: Count days after character creation
  user:SetGlobal(daysPassed, days)
  return true
end

function DateTime.OnUserDisconnect(user)
  knownHour[user:GetID()] = nil
  return true
end

return DateTime
