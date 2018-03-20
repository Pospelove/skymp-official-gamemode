Exchange = {}

local exchangeCmdNames = {
  obmen = true,
  ob = true,
  ex = true,
  exchange = true,
  change = true,
  trade = true
}

local gData = {}
local gObjectOwner = {}
local gOwnerObject = {}
local gIsInvisibleChest = {}
local gContForMe = {}

function Exchange.OnPlayerActivateObject(pl, obj)
  if gIsInvisibleChest[obj:GetID()] then
    if gObjectOwner[obj:GetID()] ~= pl:GetName() then
      print("Exchange.lua bad activation")
      return false
    end
  end
  return true
end

function Exchange.OnUserChatCommand(user, cmd)

  local tokens = stringx.split(cmd)

  if cmd == "/stop" then
    local t = gData[user:GetName()]
    if t ~= nil then
      user:SendChatMessage(Theme.info .. "Обмен отменён")
      local target = User.Lookup(t.targetName)
      if target then
        target:SendChatMessage(Theme.info .. "Обмен отменён")
      end
      gData[user:GetName()] = nil
      gData[t.targetName] = nil
    end
  end

  if cmd == "/ok" then
    local t = gData[user:GetName()]
    if t ~= nil then
      if t.state == "WaitForAccept" then
        gData[user:GetName()].state = "Accepted"
        local t2 = gData[t.targetName]
        if t2.state == "WaitForAccept" then
          user:SendChatMessage(Theme.info .. "Ожидание другого игрока")
          return true
        elseif t2.state == "Accepted" then
          local contForUser = gContForMe[user:GetName()]
          if not contForUser then error("no contForUser") end
          local contForTarget = gContForMe[t.targetName]
          if not contForTarget then error("no contForTarget") end

          local target = User.Lookup(t.targetName)
          if target then
            contForUser:AddTo(user.pl)
            contForTarget:AddTo(target.pl)
            user:SendChatMessage(Theme.success .. "Готово")
            target:SendChatMessage(Theme.success .. "Готово")

            gData[user:GetName()] = nil
            gData[t.targetName] = nil
          else
            -- TODO:
            user:SendChatMessage(Theme.error .. "Игрок вышел из игры")
          end
        end
      end
    end
  end

  if cmd == "/ready" then
    local t = gData[user:GetName()]
    if t ~= nil then
      if t.state == "Exchange" then
        gData[user:GetName()].state = "WaitForAccept"
        local t2 = gData[t.targetName]
        if t2.state == "Exchange" then
          user:SendChatMessage(Theme.info .. "Ожидание другого игрока")
          return true
        elseif t2.state == "WaitForAccept" then
          local cont1 = Container(gOwnerObject[user:GetName()])
          local cont2 = Container(gOwnerObject[t.targetName])

          local msgYouGive = (Theme.notice .. "Вы предлагаете:")
          local msgOtherGive = (Theme.notice .. "Он(а) предлагает:")
          local msgHowToAccept = (Theme.info .. "Исопльзуйте " .. Theme.sel .. "/ok" .. Theme.info .. ", чтобы подтвердить обмен или " .. Theme.sel .. "/stop" .. Theme.info .. ", чтобы отказаться")

          user:SendChatMessage(msgYouGive)
          user:SendChatMessage(cont1:Dump())
          user:SendChatMessage(msgOtherGive)
          user:SendChatMessage(cont2:Dump())
          user:SendChatMessage(msgHowToAccept)
          gContForMe[user:GetName()] = cont2

          local target = User.Lookup(t.targetName)
          if not target then
            user:SendChatMessage(Theme.error .. "Игрок вышел из игры")
            gData[user:GetName()] = nil
            gData[t.targetName] = nil
            -- TODO
            return true
          end

          target:SendChatMessage(msgYouGive)
          target:SendChatMessage(cont2:Dump())
          target:SendChatMessage(msgOtherGive)
          target:SendChatMessage(cont1:Dump())
          target:SendChatMessage(msgHowToAccept)
          gContForMe[target:GetName()] = cont1

          return true
        end
      end
    end
  end

  if cmd == "/yes" or cmd == "/no" then
    local isYes = (cmd == "/yes")
    local t = gData[user:GetName()]
    if t ~= nil then
      if t.state == "WaitForLocalYesNo" then
        if isYes then
          local target = User.Lookup(t.targetName)
          if target then
            gData[t.targetName].state = "Exchange"
            gData[user:GetName()].state = "Exchange"

            local msg = (Theme.info .. "Сейчас откроется меню, в которое Вы должны переместить предметы, которые хотите обменять")
            user:SendChatMessage(msg)
            target:SendChatMessage(msg)
            msg = (Theme.info .. "Когда закончите - введите " .. Theme.sel .. "/ready" .. Theme.info .. ", чтобы начать подтверждение обмена")
            user:SendChatMessage(msg)
            target:SendChatMessage(msg)

            local obj = Object.Create(0, 0xaf6ae, user:GetLocation(), user:GetX(), user:GetY(), user:GetZ() - 200)
            if obj == nil then
              error("unable to create invisible chest1")
            end
            obj:RegisterAsContainer()
            obj:SetName(user:GetName())
            gObjectOwner[obj:GetID()] = user:GetName()
            gOwnerObject[user:GetName()] = obj:GetID()
            gIsInvisibleChest[obj:GetID()] = true

            local objt = Object.Create(0, 0xaf6ae, target:GetLocation(), target:GetX(), target:GetY(), target:GetZ() - 200)
            if objt == nil then
              error("unable to create invisible chest2")
            end
            objt:RegisterAsContainer()
            objt:SetName(target:GetName())
            gObjectOwner[objt:GetID()] = target:GetName()
            gOwnerObject[target:GetName()] = objt:GetID()
            gIsInvisibleChest[objt:GetID()] = true

            SetTimer(2000, function()
              obj:Activate(user.pl)
              objt:Activate(target.pl)
            end)
          else
            user:SendChatMessage(Theme.error .. "Игрока нет в сети. Подождите, пока " .. t.targetName .. " вернётся на сервер")
          end
        else
          local target = User.Lookup(t.targetName)
          gData[t.targetName] = nil
          gData[user:GetName()] = nil
          if target then target:SendChatMessage(Theme.info .. "Игрок отказался от обмена") end
          user:SendChatMessage(Theme.info .. "Вы отказались от обмена")
        end
      end
    end
    return true
  end

  if tokens[1] == "/obmen" or tokens[1] == "/ob" or tokens[1] == "/ex" or tokens[1] == "/exchange" or tokens[1] == "/change" then
    if not tokens[2] then
      user:SendChatMessage(Theme.error .. "Вы не ввели имя игрока")
      return true
    end
    local target = User.Lookup(tokens[2])
    if not target then
      user:SendChatMessage(Theme.error .. "Игрок не найден (" .. tokens[2] .. ")")
      return true
    end
    if user:GetID() == target:GetID() then
      user:SendChatMessage(Theme.error .. "Вы не можете обмениваться с самим собой")
      return true
    end
    if Math.GetDistance(user, target) > 256 then
      user:SendChatMessage(Theme.error .. "Игрок слишком далеко (" .. tokens[2] .. ")")
      return true
    end
    user:SendChatMessage(Theme.info .. "Ожидаем ответа от игрока " .. Theme.sel .. tokens[2])
    target:SendChatMessage(Theme.info .. "Игрок " .. Theme.sel .. user:GetName() .. Theme.info .. " предлагает Вам начать обмен")
    target:SendChatMessage(Theme.info .. "Используйте " .. Theme.sel .. "/yes" .. Theme.info .. ", чтобы согласиться или " .. Theme.sel .. "/no" .. Theme.info .. ", чтобы отказаться")

    local t = {
      state = "WaitForRemoteYesNo",
      targetName = target:GetName()
    }
    gData[user:GetName()] = t

    local t2 = {
      state = "WaitForLocalYesNo",
      targetName = user:GetName()
    }
    gData[target:GetName()] = t2

  end
  return true
end

return Exchange
