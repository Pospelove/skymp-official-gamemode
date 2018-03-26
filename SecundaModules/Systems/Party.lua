Party = class()
Party.data = {}
Party.data.parties = {}
Party.data.vals = {}
Party.chatCol = "#1a9759"
Party.chatName = '[Шайка]'
Party.maxMembers = 4

function Party.Docs()
  return [[
  -- Static methods:
  Party.GetPartyPool(leader) -- Get party of leader
  Party.InParty(user) -- Get leader of user's party
  Party.ChatMsg(leader, msg ) -- Send msg to party chat
  Party.SystemMsg(user, msg, all) -- Send msg to all users: user = leader of party, all = 1; to one user: user = user, all = 0
  Party.SetVal(user, var, val) -- Set temporaru var on user.
  Party.GetVal(user, var) -- Set temporaru var on user.

  -- Methods:
  Party:getLeader() -- Get leader
  Party:setLeader(leader) -- Set leader if not exist
  Party:changeLeader(leader) -- Change leader of party. If leader = nil, next leader will be next player
  Party:addMember(member) -- Add member to party
  Party:kickMember(member) -- Kick member from party
  Party:destroyParty() -- Destroy party
  Party:getMembers() -- Get table of members


  -- Callbacks:
  OnUserKickedFromParty(party, m) -- Call when user is kicked from party
  OnUserAddedToParty(party,m) -- Call when user id added to party
  OnPartyChangedLeader(party, oldleader, newleader) - Call when leader is changed
  OnPartyDestroy(party) -- Call when party destroying..
  OnPartyInit(party, leader, user) -- Call when party init
  ]]
end
--- ChatTheme.lua create
--- ошибка во время запроса
Party.cmds = {} -- Cmds of Party module

Party.cmds['invite'] = {}
Party.cmds['invite']['func'] = function(user, victim, act)
	Party.CheckInvite( user, victim ) end
Party.cmds['invite']['customcheck'] = function(user,victim)
	if victim == nil then return Party.SystemMsg( user, "Неправильный формат. Подробнее /party help") end
	local inparty = Party.GetVal(user,"InParty")
	local isleader = Party.GetVal(user,"IsPartyLeader")
	if inparty and not isleader then Party.SystemMsg( user, ("Вы не являетесь лидером!")) end
	return inparty == isleader end
Party.cmds['invite']['description'] = 'Пригласить игрока в шайку.'
Party.cmds['invite']['format'] = " <Имя игрока>"

Party.cmds['yes'] = {}
Party.cmds['yes']['func'] = function(user, victim, act)
	Party.Confirmation(user, act) end
Party.cmds['yes']['customcheck'] = function(user, victim)
	return true	end
Party.cmds['yes']['description'] = 'Принять приглашение.'
Party.cmds['yes']['format'] = ""

Party.cmds['no'] = {}
Party.cmds['no']['func'] = function(user, victim, act)
	Party.Confirmation(user, act) end
Party.cmds['no']['customcheck'] = function(user, victim)
	return true	end
Party.cmds['no']['description'] = 'Принять приглашение.'
Party.cmds['no']['format'] = ""

Party.cmds['kick'] = {}
Party.cmds['kick']['func'] = function(user, victim, act)
	Party.GetPartyPool(user):kickMember(victim) end
Party.cmds['kick']['customcheck'] = function(user, victim)
	if victim == nil then return Party.SystemMsg( user, "Неправильный формат. Подробнее /party help") end
	local isleader = Party.GetVal(user,"IsPartyLeader")
	local inparty = Party.GetVal(user,"InParty")
	local vic_inparty = Party.GetVal(victim, 'InParty')
	if not vic_inparty then Party.SystemMsg( user, "Игрок не в шайке!") return end
	if not inparty then Party.SystemMsg( user, "Вы не в шайке!") return false end
	if not isleader then Party.SystemMsg( user, "Вы не являетесь лидером!") return false end
	return true	end
Party.cmds['kick']['description'] = 'Исключить игрока из шайки.'
Party.cmds['kick']['format'] = " <Имя игрока>"

Party.cmds['destroy'] = {}
Party.cmds['destroy']['func'] = function(user, victim, act)
	Party.GetPartyPool(user):destroyParty() end
Party.cmds['destroy']['customcheck'] = function(user, victim)
	local isleader = Party.GetVal(user,"IsPartyLeader")
	local inparty = Party.GetVal(user,"InParty")
	if not inparty then Party.SystemMsg( user, "Вы не в шайке!") return false end
	if not isleader then Party.SystemMsg( user, "Вы не являетесь лидером!") return false end
	return true	end
Party.cmds['destroy']['description'] = 'Расформировать шайку.'
Party.cmds['destroy']['format'] = ""

Party.cmds['changeleader'] = {}
Party.cmds['changeleader']['func'] = function(user, victim, act)
	Party.GetPartyPool(user):changeLeader(victim) end
Party.cmds['changeleader']['customcheck'] = function(user, victim)
	if victim == nil then return Party.SystemMsg( user, "Неправильный формат. Подробнее /party help") end
	local isleader = Party.GetVal(user,"IsPartyLeader")
	local inparty = Party.GetVal(user,"InParty")
	local vic_inparty = Party.GetVal(victim, 'InParty')
	if not vic_inparty then Party.SystemMsg( user, "Игрок не в шайке!") return end
	if not inparty then Party.SystemMsg( user, "Вы не в шайке!") return false end
	if not isleader then Party.SystemMsg( user, "Вы не являетесь лидером!") return false end
	return true	end
Party.cmds['changeleader']['description'] = 'Сменить лидера шайки.'
Party.cmds['changeleader']['format'] = " <Имя игрока>"

Party.cmds['dev'] = {}
Party.cmds['dev']['func'] = function(user, victim, act)
	Party.DevFunc(user, victim) end
Party.cmds['dev']['customcheck'] = function(user, victim)
	return true	end
Party.cmds['dev']['description'] = 'Команда для тестирования.'
Party.cmds['dev']['format'] = ""

Party.cmds['members'] = {}
Party.cmds['members']['func'] = function(user, victim, act)
	Party.GetAllMembers(user) end
Party.cmds['members']['customcheck'] = function(user, victim)
	local inparty = Party.GetVal(user,"InParty")
	if not inparty then Party.SystemMsg( user, "Вы не в шайке!") return false end
	return true end
Party.cmds['members']['description'] = 'Показать список членов шайки.'
Party.cmds['members']['format'] = ""

Party.cmds['leave'] = {}
Party.cmds['leave']['func'] = function(user, victim, act)
	Party.GetPartyPool(user):kickMember(user) end
Party.cmds['leave']['customcheck'] = function(user, victim)
	local inparty = Party.GetVal(user,"InParty")
	if not inparty then Party.SystemMsg( user, "Вы не в шайке!") return false end
	return true end
Party.cmds['leave']['description'] = 'Покинуть шайку.'
Party.cmds['leave']['format'] = ""

Party.cmds['help'] = {}
Party.cmds['help']['func'] = function(user, victim, act)
	Party.GetCmds(user) end
Party.cmds['help']['customcheck'] = function(user, victim)
	return true end
Party.cmds['help']['description'] = 'Показать список команд для управления шайкой'
Party.cmds['help']['format'] = ""


function Party.Think(user, victim, act)

	if victim ~= nil then
		victim = User.Lookup(victim)

		if victim == nil then
			return Party.SystemMsg( user, "Игрок не найден!")
		end
	end

	if user == victim then return Party.SystemMsg( user, "Вы не можете выполнить это действие над собой!")  end

	if Party.cmds[act] then
		if Party.cmds[act]['customcheck'](user,victim) then
			return Party.cmds[act]['func'](user,victim,act)
		else return end
	else Party.SystemMsg( user, "Команда не найдена. Подробнее /party help") end
end

function Party.CheckInvite(user, victim)
	local victim_inparty = Party.GetVal(victim,'InParty')
	local req = Party.GetVal(victim,'PartyInviter')
	local user_inparty = Party.GetVal(user,'InParty')

	if not victim_inparty then
		if not req then
			if user_inparty then
				local mems = tablex.size(Party.GetPartyPool(Party.GetVal(user,'PartyLeader')):getMembers())
				if mems <= Party.maxMembers then Party.MakeRequest(user, victim)
				else Party.SystemMsg( user, 'Слишком много игроков в шайке!' ) end
			else Party.MakeRequest(user, victim) end
		else Party.SystemMsg( user,  tostring(victim) .. ' уже отвечает на приглашению в шайку. Подождите!') end
	else Party.SystemMsg( user, "Игрок " .. tostring(victim) .. " уже в шайке!" ) end
end

function Party.GetAllMembers(user)
	local mems = Party.GetPartyPool(Party.GetVal(user,'PartyLeader')):getMembers()
	Party.SystemMsg( user, "Игроки в пати: ")
	for k,v in pairs(mems) do
		Party.SystemMsg( user, k .. ": " .. tostring(v))
	end

end

function Party.GetCmds(u)
	Party.SystemMsg( u, "Список команд для управления шайкой:" )
	for k,v in pairs(Party.cmds) do
		Party.SystemMsg( u, "/party " .. k .. v['format'] .. " - " .. v['description'])
	end
	Party.SystemMsg(u, "/p <Сообщение> - отправить сообщение в чат.")
end

function Party.CheckCmd(user, cmdtext)
	local args = stringx.split(cmdtext)
	local cmd = stringx.replace(args[1], '/', '')

	if cmd == 'party' then
		local act = args[2]
		local victim = args[3]

		if #args < 2 or #args > 3 then
			Party.SystemMsg( user, "Неправильный формат. Подробнее /party help")
			return end

		Party.Think( user, victim, act )

	elseif cmd == 'p' then
		args = stringx.split(cmdtext, ' ', 2)
		local text = args[2]
		Party.ChatMsg(user, text)
	end
end

function Party.ChatMsg(user, text)
	local party = Party.InParty(user)
	local suffix = tostring(user) .. ':   '

	if party then Party.SendToAll(party, Party.chatCol .. Party.chatName .. suffix .. text ) return
	else return user:SendChatMessage(Party.chatCol .. Party.chatName .. ' Вы не состоите в шайке') end
end

function Party.SystemMsg(user, text, all)
	if all then
		local party = Party.InParty(user)
		Party.SendToAll(party, Party.chatCol ..'[Шайка] ' .. text )
	else
		user:SendChatMessage(Party.chatCol ..'[Шайка] ' .. text )
	end
end

function Party.SendToAll(leader, msg)
	local members = Party.GetPartyPool(leader):getMembers()

	for k,v in pairs(members) do
		v:SendChatMessage(msg)
	end

end

function Party.DevFunc(user, vic)
--[[ 	 local pool = Party.GetPartyPool(vic)
	if not pool then user:SendChatMessage('Шайка не найдена') end

	for k,v in pairs(pool:getMembers()) do
		user:SendChatMessage(tostring(v))
	end

	user:SendChatMessage("Лидер пати " .. tostring(pool:getLeader()))  ]]
	user:SendChatMessage("Список пулов: ")

	for k, v in pairs(Party.data.parties) do
		Party.SystemMsg( user, k)
	end
	if Party.InParty(user) then Party.SystemMsg( user, 'true')
	elseif not Party.InParty(user) then Party.SystemMsg( user, 'false')  end

	Party.SystemMsg( user, 'InParty? '.. tostring(Party.GetVal(vic,'InParty')))
	Party.SystemMsg( user, 'Partyleader?' .. tostring(Party.GetVal(vic,'PartyLeader')))
	Party.SystemMsg( user, 'IsPartyLeader?' .. tostring(Party.GetVal(vic,'IsPartyLeader')))


end

function Party.MakeRequest(user, victim)
	Party.SystemMsg( user, "Приглашение отправлено персонажу " .. tostring(victim))
	Party.SystemMsg( victim,  tostring(user) .. " предложил вступить в шайку. Введите /party 'yes' или 'no'")
	Party.SetVal(victim,'PartyInviter', user)
	SetTimer(20000, function()
						if Party.GetVal(victim, 'PartyInviter') then
						Party.SetVal(victim,'PartyInviter', nil)
						Party.SystemMsg(victim, 'Время ожидания приглашения истекло.')
						Party.SystemMsg(user, tostring(victim) .. ' не ответил на приглашение.') end end)
end

function Party.Confirmation(user, act)
	local leader = Party.GetVal(user,'PartyInviter')
	Party.SetVal(user,'PartyInviter', nil)

	if leader then
		local inparty = Party.GetVal(leader,'InParty')

		if act == 'yes' then
			if not inparty then
				party = Party(leader, user)
			else
				party = Party.GetPartyPool(leader)
				party:addMember(user)
			end
		else
			Party.SystemMsg( user, "Вы отклонили запрос на вступление в шайку персонажа " .. tostring(leader))
			Party.SystemMsg( leader, "Персонаж " .. tostring(user) .. "отклонил запрос на вступление в шайку.")
		end
	else
		Party.SystemMsg( user, "У вас нет запросов на вступление в шайку.")
	end
end

function Party.InParty(user)
	return Party.GetVal(user,'PartyLeader')
end

function Party:_init(leader, user)
	self.mems = {}

	self:setLeader(leader)
	Party.SetPartyPool(self, self.leader)

	self:addMember(user)
	Secunda.OnPartyInit(self, leader, user)
end

function Party:setLeader(l)
	self.leader = l
	if tablex.size(self.mems) == 0 then self.mems[1] = l end
	Party.SetVal(l,'IsPartyLeader', true)
	Party.SetVal(l,'InParty', true)
	Party.SetVal(l,'PartyLeader', self.leader)
end

function Party:addMember(m)
	Party.SystemMsg( self.leader, tostring(m) .. ' вступил в шайку.', 1)
	self.mems[#self.mems+1] = m
	Party.SetVal(m,'InParty', true)
	Party.SetVal(m,'PartyLeader', self.leader)
	Secunda.OnUserAddedToParty(self,m)
	Party.SystemMsg( m, "Вы вступили в шайку персонажа " .. tostring(self.leader))
end

function Party:kickMember(m)
	if self.leader == m then
		local oldl = self.leader
		self:changeLeader()
	end

	Party.SetVal(m,'InParty', nil)
	Party.SetVal(m,'PartyLeader', nil)
	table.remove( self.mems, tablex.find(self.mems, m))
	Party.SystemMsg(self.leader, 'Игрок '..tostring(m)..' покинул шайку.', 1)
	Party.SystemMsg(m, 'Вы покинули шайку!')
	local size = tablex.size(self.mems)
	Secunda.OnUserKickedFromParty(self, m)
	if size < 2 then
		self:destroyParty()
	end
end

function Party:changeLeader(newleader)
	if not newleader then
		local id = tablex.find(self.mems, self.leader)
		newleader = self.mems[id+1]
	end
	local oldl = self.leader
	Party.SetPartyPool(nil, self.leader)
	self:setLeader(newleader)
	Party.SetPartyPool(self, self.leader)
	Party.SetVal(oldl,'IsPartyLeader', nil)
	self:swap(oldl,newleader)
	for k,v in pairs(self.mems) do
		Party.SetVal(v,'PartyLeader', self.leader)
	end
	Secunda.OnPartyChangedLeader(self, oldl, newleader)
	Party.SystemMsg(self.leader, 'В шайке новый лидер: '..tostring(self.leader), 1)
end

function Party:swap(u1,u2)
	local id1 = tablex.find(self.mems, u1)
	local id2 = tablex.find(self.mems, u2)
	local u = self.mems[id1]

	self.mems[id1] = self.mems[id2]
	self.mems[id2] = u1
end

function Party:destroyParty()
	Party.SystemMsg(self.leader, 'Шайка расформирована!', 1)

	for k,v in pairs(self.mems) do
		Party.SetVal(v,'InParty', nil)
		Party.SetVal(v,'PartyLeader', nil)
		Party.SetVal(v,'IsPartyLeader', nil)
	end

	Secunda.OnPartyDestroy(self)

	Party.SetPartyPool(nil, self.leader)
	self.mems = nil
	self.leader = nil
	self = nil
end

function Party:getLeader()
	return self.leader
end

function Party:getMembers()
	return self.mems
end

function Party.SetPartyPool( pool, leader)
	Party.data.parties[tostring(leader)] = pool
end
function Party.GetPartyPool( leader )
	return Party.data.parties[tostring(leader)]
end

function Party.SetVal(u, name, val)
	if not Party.data.vals[u] then
		Party.data.vals[u] = {}
	end
	Party.data.vals[u][name] = val
end

function Party.GetVal(u, name)
	if not Party.data.vals[u] then return nil end
	return Party.data.vals[u][name]
end

function Party.OnUserChatCommand(user, cmdtext)
	Party.CheckCmd(user, cmdtext)
  return true
end

function Party.OnUserDisconnect(user)
	local isTest = user.pl:IsNPC()
  if isTest then
    return
  end
	local inparty = Party.InParty(user)
	if inparty then Party.GetPartyPool(inparty):kickMember(user) end
  return true
end

function Party.OnHit(source, target)
	if Party.GetVal(source,'InParty') then
		if tostring(Party.InParty(source)) == tostring(Party.InParty(target)) then Party.SystemMsg(source, 'Своих бить запрещено!') return false end
	else return true end
end

return Party
