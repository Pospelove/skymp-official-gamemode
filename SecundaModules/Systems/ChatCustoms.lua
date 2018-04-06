ChatCustoms = {}

ChatCustoms.ChatCmds = {}
ChatCustoms.ChatCmds['w'] = {}
ChatCustoms.ChatCmds['w']['des'] = 'Шепот. введите /w <имя игрока> <Сообщение>.'
ChatCustoms.ChatCmds['w']['color'] = function(user, target)
										local distance = Math.GetDistance(user, target)
										local d = distance / 70
										local col = ''
											if d < 0.5 then
												col = Colors.Get("DarkGrey")
											elseif d < 1 then
												col = Colors.Get("Grey")
											elseif d < 1.5 then
												col = Colors.Get("DimGrey")
											elseif d < 2 then
												col = Colors.Get("DarkSlateGrey")
											elseif d < 2.5 then
												col = Colors.Get("Black")
											end

									 return col end
ChatCustoms.ChatCmds['w']['structure'] = {}
ChatCustoms.ChatCmds['w']['structure'][1] = ''												-- Name of chat
ChatCustoms.ChatCmds['w']['structure'][2] = ''												-- Divisor 1
ChatCustoms.ChatCmds['w']['structure'][3] = function(user) return tostring(user) end		-- Source name
ChatCustoms.ChatCmds['w']['structure'][4] = ' шепчет вам: '									-- Divisor 2
ChatCustoms.ChatCmds['w']['structtxt'] = function(txt) return txt end
ChatCustoms.ChatCmds['w']['args'] = 2
ChatCustoms.ChatCmds['w']['range'] = 2.5
ChatCustoms.ChatCmds['w']['customCheck'] = function(user, target, txt)
												if tostring(user) == tostring(User.Lookup(target)) then user:SendChatMessage(Theme.error .. 'Вы не можете отправлять сообщения самому себе!') return end
												if not User.Lookup(target) then user:SendChatMessage(Theme.error .. 'игрок '.. Theme.sel .. tostring(target) .. Theme.error .. ' не найден!') return end

												return true end


ChatCustoms.ChatCmds['n'] = {}
ChatCustoms.ChatCmds['n']['des'] = 'OOC. Введите /n <Сообщение>.'
ChatCustoms.ChatCmds['n']['customCheck'] = function(user, target, txt) return true end
ChatCustoms.ChatCmds['n']['color'] = function() return ChatTheme.ooc end
ChatCustoms.ChatCmds['n']['structure'] = {}
ChatCustoms.ChatCmds['n']['structure'][1] = ''
ChatCustoms.ChatCmds['n']['structure'][2] = ''
ChatCustoms.ChatCmds['n']['structure'][3] = function(user) return "(("..tostring(user) end
ChatCustoms.ChatCmds['n']['structure'][4] = ': '
ChatCustoms.ChatCmds['n']['structtxt'] = function(txt) return txt.."))" end
ChatCustoms.ChatCmds['n']['args'] = 1
ChatCustoms.ChatCmds['n']['range'] = 20

ChatCustoms.ChatCmds['s'] = {}
ChatCustoms.ChatCmds['s']['des'] = 'Крик. Введите /s <Сообщение>.'
ChatCustoms.ChatCmds['s']['customCheck'] = function(user, target, txt) return true end
ChatCustoms.ChatCmds['s']['color'] = function() return ChatTheme.shout end
ChatCustoms.ChatCmds['s']['structure'] = {}
ChatCustoms.ChatCmds['s']['structure'][1] = ''
ChatCustoms.ChatCmds['s']['structure'][2] = ''
ChatCustoms.ChatCmds['s']['structure'][3] = function(user) return tostring(user) end
ChatCustoms.ChatCmds['s']['structure'][4] = ' кричит: '
ChatCustoms.ChatCmds['s']['structtxt'] = function(txt) return txt end
ChatCustoms.ChatCmds['s']['args'] = 1
ChatCustoms.ChatCmds['s']['range'] = 20



function ChatCustoms.checkCmd(user, cmdtext)

	local args = stringx.split(cmdtext)
	local cmd = stringx.replace(args[1], '/', '')

	if #args < 1 then

		return end

	if ChatCustoms.ChatCmds[cmd] then

		if ChatCustoms.ChatCmds[cmd]['args'] == 2 then

			args = stringx.split(cmdtext, ' ', 3)
			local txt = args[3]
			local target = args[2]
			return ChatCustoms.customCheck(user, target, cmd, txt)

		elseif ChatCustoms.ChatCmds[cmd]['args'] == 1 then

			args = stringx.split(cmdtext, ' ', 2)
			local txt = args[2]
			local target = false
			return ChatCustoms.customCheck(user, target, cmd, txt)

		end
	end
end

function ChatCustoms.customCheck(user, target, cmd, txt)

	if not txt then return end

	if not ChatCustoms.ChatCmds[cmd]['customCheck'](user, target, txt) then return false end


	ChatCustoms.sendMsg(user, target, cmd, txt)

	return true
end

function ChatCustoms.sendMsg(user, target, cmd, txt)
	target = User.Lookup(target)
	if target then
		if (Math.GetDistance(user, target) / 70) <= ChatCustoms.ChatCmds[cmd]['range'] or ChatCustoms.ChatCmds[cmd]['range'] == 0 then
			target:SendChatMessage(ChatCustoms.buildMsg(user, target, cmd, txt))
			if cmd == 'w' then user:SendChatMessage("Вы прошептали игроку ".. tostring(target).. ": ".. txt) end
		end
	else
		local msg = ChatCustoms.buildMsg(user, target, cmd, txt)
		for k, v in pairs(User.GetAllUsers()) do
			if (Math.GetDistance(user, v) / 70) <= ChatCustoms.ChatCmds[cmd]['range'] or ChatCustoms.ChatCmds[cmd]['range'] == 0 then
				v:SendChatMessage(msg)
				end
		end
	end

end

function ChatCustoms.buildMsg(user, target, cmd, txt)
	local s = ChatCustoms.ChatCmds[cmd]['color'](user,target) .. ''
	for k, v in pairs(ChatCustoms.ChatCmds[cmd]['structure']) do

		if (type(v) == 'function') then
			s = s..v(user)
		else
			s = s..v
		end
	end
	return s..ChatCustoms.ChatCmds[cmd]['structtxt'](txt)
end

ChatCustoms.Smiles = {}
ChatCustoms.Smiles[':)'] = 'улыбается'
ChatCustoms.Smiles['))'] = 'улыбается' -- reg expression

function ChatCustoms.checkForSmiles(user, cmdtext)

	for k, v in pairs(ChatCustoms.Smiles) do
		stringx.replace(cmdtext, k, "*"..tostring(user).." "..v.." ")
	end
end

function ChatCustoms.OnUserChatCommand(user, cmdtext)

	ChatCustoms.checkForSmiles(user, cmdtext)
	ChatCustoms.checkCmd(user, cmdtext)

end


return ChatCustoms
