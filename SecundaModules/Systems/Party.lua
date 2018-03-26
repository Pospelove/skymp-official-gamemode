Party = class()
Party.data = {}
Party.data.parties = {}
Party.data.vals = {}
Party.chatCol = ChatTheme.party
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
  OnPartySendedChatMsg(user, msg) -- Call when msg is sended in party chat
  ]]
end
--- ошибка во время запроса
Party.cmds = {} -- Cmds of Party module

Party.cmds['invite'] = {}
Party.cmds['invite']['func'] = function(user, victim, act)
	Party.CheckInvite( user, victim ) end
Party.cmds['invite']['customcheck'] = function(user,victim)
	if victim == nil then return Party.SystemMsg( user, Theme.error .. "Неправильный формат. Подробнее /party help") end
	local inparty = Party.GetVal(user,"InParty")
	local isleader = Party.GetVal(user,"IsPartyLeader")
	if inparty and not isleader then Party.SystemMsg( user, Theme.error .."Вы не являетесь лидером!") end
	return inparty == isleader end
Party.cmds['invite']['description'] = 'Пригласить игрока в шайку.'
Party.cmds['invite']['format'] = " <Имя игрока>"
Party.cmds['invite']['adm'] = false

Party.cmds['yes'] = {}
Party.cmds['yes']['func'] = function(user, victim, act)
	Party.Confirmation(user, act) end
Party.cmds['yes']['customcheck'] = function(user, victim)
	return true	end
Party.cmds['yes']['description'] = 'Принять приглашение.'
Party.cmds['yes']['format'] = ""
Party.cmds['yes']['adm'] = false

Party.cmds['no'] = {}
Party.cmds['no']['func'] = function(user, victim, act)
	Party.Confirmation(user, act) end
Party.cmds['no']['customcheck'] = function(user, victim)
	return true	end
Party.cmds['no']['description'] = 'Принять приглашение.'
Party.cmds['no']['format'] = ""
Party.cmds['no']['adm'] = false

Party.cmds['kick'] = {}
Party.cmds['kick']['func'] = function(user, victim, act)
	Party.GetPartyPool(user):kickMember(victim) end
Party.cmds['kick']['customcheck'] = function(user, victim)
	if victim == nil then return Party.SystemMsg( user, Theme.error .. "Неправильный формат. Подробнее /party help") end
	local isleader = Party.GetVal(user,"IsPartyLeader")
	local inparty = Party.GetVal(user,"InParty")
	local vic_inparty = Party.GetVal(victim,'InParty')
	if not vic_inparty then Party.SystemMsg( user, Theme.error .. "Игрок не в шайке!") return end
	if not inparty then Party.SystemMsg( user, Theme.error .. "Вы не в шайке!") return false end
	if not isleader then Party.SystemMsg( user, Theme.error .. "Вы не являетесь лидером!") return false end
	return true	end
Party.cmds['kick']['description'] = 'Исключить игрока из шайки.'
Party.cmds['kick']['format'] = " <Имя игрока>"
Party.cmds['kick']['adm'] = false

Party.cmds['destroy'] = {}
Party.cmds['destroy']['func'] = function(user, victim, act)
	Party.GetPartyPool(user):destroyParty() end
Party.cmds['destroy']['customcheck'] = function(user, victim)
	local isleader = Party.GetVal(user,"IsPartyLeader")
	local inparty = Party.GetVal(user,"InParty")
	if not inparty then Party.SystemMsg( user, Theme.error .. "Вы не в шайке!") return false end
	if not isleader then Party.SystemMsg( user, Theme.error .. "Вы не являетесь лидером!") return false end
	return true	end
Party.cmds['destroy']['description'] = 'Расформировать шайку.'
Party.cmds['destroy']['format'] = ""
Party.cmds['destroy']['adm'] = false

Party.cmds['changeleader'] = {}
Party.cmds['changeleader']['func'] = function(user, victim, act)
	Party.GetPartyPool(user):changeLeader(victim) end
Party.cmds['changeleader']['customcheck'] = function(user, victim)
	if victim == nil then return Party.SystemMsg( user, Theme.error .. "Неправильный формат. Подробнее /party help") end
	local isleader = Party.GetVal(user,"IsPartyLeader")
	local inparty = Party.GetVal(user,"InParty")
	local vic_inparty = Party.GetVal(victim,'InParty')
	if not vic_inparty then Party.SystemMsg( user, Theme.error .. "Игрок не в шайке!") return end
	if not inparty then Party.SystemMsg( user, Theme.error .. "Вы не в шайке!") return false end
	if not isleader then Party.SystemMsg( user, Theme.error .. "Вы не являетесь лидером!") return false end
	return true	end
Party.cmds['changeleader']['description'] = 'Сменить лидера шайки.'
Party.cmds['changeleader']['format'] = " <Имя игрока>"
Party.cmds['changeleader']['adm'] = false

Party.cmds['dev'] = {}
Party.cmds['dev']['func'] = function(user, victim, act)
	Party.DevFunc(user, victim) end
Party.cmds['dev']['customcheck'] = function(user, victim)
	local dev = Debug.IsDeveloper(user)
	if not dev then Party.SystemMsg( user, Theme.error .. "Неправильный формат. Подробнее /party help") return false end
	return true end
Party.cmds['dev']['description'] = 'Команда для тестирования.'
Party.cmds['dev']['format'] = ""
Party.cmds['dev']['adm'] = true

Party.cmds['members'] = {}
Party.cmds['members']['func'] = function(user, victim, act)
	Party.GetAllMembers(user,user) end
Party.cmds['members']['customcheck'] = function(user, victim)
	local inparty = Party.GetVal(user,"InParty")
	if not inparty then Party.SystemMsg( user, Theme.error .. "Вы не в шайке!") return false end
	return true end
Party.cmds['members']['description'] = 'Показать список членов шайки.'
Party.cmds['members']['format'] = ""
Party.cmds['members']['adm'] = false

Party.cmds['leave'] = {}
Party.cmds['leave']['func'] = function(user, victim, act)
	Party.GetPartyPool(Party.InParty(user)):kickMember(user) end
Party.cmds['leave']['customcheck'] = function(user, victim)
	local inparty = Party.GetVal(user,"InParty")
	if not inparty then Party.SystemMsg( user, Theme.error .. "Вы не в шайке!") return false end
	return true end
Party.cmds['leave']['description'] = 'Покинуть шайку.'
Party.cmds['leave']['format'] = ""
Party.cmds['leave']['adm'] = false

Party.cmds['help'] = {}
Party.cmds['help']['func'] = function(user, victim, act)
	Party.GetCmds(user) end
Party.cmds['help']['customcheck'] = function(user, victim)
	return true end
Party.cmds['help']['description'] = 'Показать список команд для управления шайкой'
Party.cmds['help']['format'] = ""
Party.cmds['help']['adm'] = false

Party.cmds['admsee'] = {}
Party.cmds['admsee']['func'] = function(user, victim, act)
	Party.GetAllMembers(user, victim) end
Party.cmds['admsee']['customcheck'] = function(user, victim)
	local dev = Debug.IsDeveloper(user)
	if not dev then Party.SystemMsg( user, Theme.error .. "Неправильный формат. Подробнее /party help") return false end
	local party = Party.InParty(victim)
	if not party then Party.SystemMsg( user, Theme.error .. "Данный персонаж не в шайке!") end
	return true end
Party.cmds['admsee']['description'] = 'Показать список членов шайки игрока.'
Party.cmds['admsee']['format'] = ""
Party.cmds['admsee']['adm'] = true

Party.cmds['admkick'] = {}
Party.cmds['admkick']['func'] = function(user, victim, act)
	Party.GetPartyPool(Party.InParty(victim)):kickMember(victim) end
Party.cmds['admkick']['customcheck'] = function(user, victim)
	local dev = Debug.IsDeveloper(user)
	if not dev then Party.SystemMsg( user, Theme.error .. "Неправильный формат. Подробнее /party help") return false end
	local party = Party.InParty(victim)
	if not party then Party.SystemMsg( user, Theme.error .. "Данный персонаж не в шайке!") end
	return true end
Party.cmds['admkick']['description'] = 'Кикнуть игрока из его шайки.'
Party.cmds['admkick']['format'] = "<Иия игрока>"
Party.cmds['admkick']['adm'] = true

Party.cmds['admdestroy'] = {}
Party.cmds['admdestroy']['func'] = function(user, victim, act)
	Party.GetPartyPool(Party.InParty(victim)):destroyParty() end
Party.cmds['admdestroy']['customcheck'] = function(user, victim)
	local dev = Debug.IsDeveloper(user)
	if not dev then Party.SystemMsg( user, Theme.error .. "Неправильный формат. Подробнее /party help") return false end
	local party = Party.InParty(victim)
	if not party then Party.SystemMsg( user, Theme.error .. "Данный персонаж не в шайке!") end
	return true end
Party.cmds['admdestroy']['description'] = 'Расформировать шайку, в которой находиться игрок.'
Party.cmds['admdestroy']['format'] = ""
Party.cmds['admdestroy']['adm'] = true

function Party.Think(user, victim, act)

	if victim ~= nil then
		victim = User.Lookup(victim)

		if victim == nil then
			return Party.SystemMsg( user, Theme.error .. "Игрок не найден!")
		end
	end

	if user == victim then return Party.SystemMsg( user, Theme.error .. "Вы не можете выполнить это действие над собой!")  end

	if Party.cmds[act] then
		if Party.cmds[act]['customcheck'](user,victim) then
			return Party.cmds[act]['func'](user,victim,act)
		else return end
	else Party.SystemMsg( user, Theme.error .. "Команда не найдена. Подробнее /party help") end
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
				else Party.SystemMsg( user, Theme.error .. 'Слишком много игроков в шайке!' ) end
			else Party.MakeRequest(user, victim) end
		else Party.SystemMsg( user, Theme.sel .. tostring(victim) .. Theme.error .. ' уже отвечает на приглашению в шайку. Подождите!') end
	else Party.SystemMsg( user, Theme.error .. "Игрок " .. Theme.sel .. tostring(victim) .. Theme.error .. " уже в шайке!" ) end
end

function Party.GetAllMembers(user, victim)
	local leader = Party.InParty(victim)
	local mems = Party.GetPartyPool(leader):getMembers()
	Party.SystemMsg( user, Theme.info .. "Игроки в шайке: ")

	for k,v in pairs(mems) do
		if not v == leader then
			Party.SystemMsg( user, Theme.info .. k .. ": " .. Theme.sel .. tostring(v))
		else
			Party.SystemMsg( user, Theme.info .. k .. ": " .. Theme.sel .. tostring(v) .. ' - Лидер')
		end
	end

end

function Party.GetCmds(u)
	Party.SystemMsg( u, Theme.info .. "Список команд для управления шайкой:" )
	for k,v in pairs(Party.cmds) do
		if not v['adm'] then
			Party.SystemMsg( u, Theme.info .. "/party " .. k .. v['format'] .. " - " .. v['description'])
		elseif Debug.IsDeveloper(u) then
			Party.SystemMsg( u, Theme.info .. "/party " .. k .. v['format'] .. " - " .. v['description'])
		end
	end
	Party.SystemMsg(u, Theme.info .. "/p <Сообщение> - отправить сообщение в чат.")
end

function Party.CheckCmd(user, cmdtext)
	local args = stringx.split(cmdtext)
	local cmd = stringx.replace(args[1], '/', '')

	if cmd == 'party' then
		local act = args[2]
		local victim = args[3]

		if #args < 2 or #args > 3 then
			Party.SystemMsg( user, Theme.error .. "Неправильный формат. Подробнее /party help")
			return end

		Party.Think( user, victim, act )

	elseif cmd == 'p' then
		args = stringx.split(cmdtext,' ', 2)
		local text = args[2]
		Party.ChatMsg(user, text)
	end
end

function Party.ChatMsg(user, text)
	local party = Party.InParty(user)
	local suffix = tostring(user) .. ': '

	if party then Party.SendToAll(party, Party.chatCol .. Party.chatName .. suffix .. text ) return
	else return user:SendChatMessage(Party.chatCol .. Party.chatName .. ' Вы не состоите в шайке') end
	Secunda.OnPartySendedChatMsg(user, text)
end

function Party.SystemMsg(user, text, all)
	if all then
		local party = Party.InParty(user)
		Party.SendToAll(party,' ' .. text )
	else
		user:SendChatMessage(' ' .. text )
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
	if Party.InParty(user) then Party.SystemMsg( user, Theme.info .. 'true')
	elseif not Party.InParty(user) then Party.SystemMsg( user, Theme.info .. 'false')  end

	Party.SystemMsg( user, Theme.info .. 'InParty? '.. tostring(Party.GetVal(vic,'InParty')))
	Party.SystemMsg( user, Theme.info .. 'Partyleader?' .. tostring(Party.GetVal(vic,'PartyLeader')))
	Party.SystemMsg( user, Theme.info .. 'IsPartyLeader?' .. tostring(Party.GetVal(vic,'IsPartyLeader')))


end

function Party.MakeRequest(user, victim)
	Party.SystemMsg( user, Theme.info .. "Приглашение отправлено персонажу " .. Theme.sel .. tostring(victim))
	Party.SystemMsg( victim, Theme.sel .. tostring(user) .. Theme.info .. " предложил вступить в шайку. Введите /party 'yes' или 'no'")
	Party.SetVal(victim,'PartyInviter', user)
	SetTimer(20000, function()
						if Party.GetVal(victim,'PartyInviter') then
						Party.SetVal(victim,'PartyInviter', nil)
						Party.SystemMsg(victim, Theme.info .. 'Время ожидания приглашения истекло.')
						Party.SystemMsg(user, Theme.sel .. tostring(victim) .. Theme.info .. ' не ответил на приглашение.') end end)
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
			Party.SystemMsg( user, Theme.info .. "Вы отклонили запрос на вступление в шайку персонажа " .. Theme.sel .. tostring(leader))
			Party.SystemMsg( leader, Theme.info .. "Персонаж " .. Theme.sel .. tostring(user) .. Theme.info .. "отклонил запрос на вступление в шайку.")
		end
	else
		Party.SystemMsg( user, Theme.info .. "У вас нет запросов на вступление в шайку.")
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
	Party.SystemMsg( self.leader, Theme.sel .. tostring(m) .. Theme.info .. ' вступил в шайку.', 1)
	self.mems[#self.mems+1] = m
	Party.SetVal(m,'InParty', true)
	Party.SetVal(m,'PartyLeader', self.leader)
	Secunda.OnUserAddedToParty(self,m)
	Party.SystemMsg( m, Theme.info .. "Вы вступили в шайку персонажа " .. Theme.sel .. tostring(self.leader))
end

function Party:kickMember(m)
	if self.leader == m then
		local oldl = self.leader
		self:changeLeader()
	end

	Party.SetVal(m,'InParty', nil)
	Party.SetVal(m,'PartyLeader', nil)
	table.remove( self.mems, tablex.find(self.mems, m))
	Party.SystemMsg(self.leader, Theme.info .. 'Игрок '.. Theme.sel ..tostring(m).. Theme.info .. ' покинул шайку.', 1)
	Party.SystemMsg(m, Theme.info .. 'Вы покинули шайку!')
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
	Party.SystemMsg(self.leader, Theme.info .. 'В шайке новый лидер: '.. Theme.sel ..tostring(self.leader), 1)
end

function Party:swap(u1,u2)
	local id1 = tablex.find(self.mems, u1)
	local id2 = tablex.find(self.mems, u2)
	local u = self.mems[id1]

	self.mems[id1] = self.mems[id2]
	self.mems[id2] = u1
end

function Party:destroyParty()
	Party.SystemMsg(self.leader, Theme.info .. 'Шайка расформирована!', 1)

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

end
function Party.OnUserDisconnect(user)
	local isTest = user.pl:IsNPC()
  if isTest then
    return
  end
	local inparty = Party.InParty(user)
	if inparty then Party.GetPartyPool(inparty):kickMember(user) end

end

function Party.OnHit(source, target)
	if Party.GetVal(source,'InParty') then
		if tostring(Party.InParty(source)) == tostring(Party.InParty(target)) then Party.SystemMsg(source, Theme.error .. 'Своих бить запрещено!') return false end
	else return true end
end

return Party
