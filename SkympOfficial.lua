-- SkympOfficial.lua

callbacks = {
	-- Standard
	"OnServerInit",
	"OnServerExit",
	"OnPlayerConnect",
	"OnPlayerDisconnect",
	"OnPlayerSpawn",
	"OnPlayerUpdate",
	"OnPlayerDying",
	"OnPlayerDeath",
	"OnPlayerChatInput",
	"OnPlayerDialogResponse",
	"OnPlayerCharacterCreated",
	"OnPlayerActivateObject",
	"OnPlayerHitObject",
	"OnPlayerHitPlayer",
	"OnPlayerEquipItem",

	-- Non-Standard
	"OnPlayerChatCommand"
}

Main = {
	isDeveloper = {},

	IsDeveloper = function(player)
		return Main.isDeveloper[player:GetName()]
	end,

	Split = function(inputstr, sep)
		if sep == nil then
			sep = "%s"
		end
		local t = {}
		local i = 1
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
		end
		return t
	end,

	OnPlayerChatInput = function(player, str)
		local tokens = Main.Split(str)
		OnPlayerChatCommand(player, tokens)
	end,
}

function Main.OnPlayerChatCommand(player, tokens)

	local adminPassword = "228228"

	if tokens[1] == "/secretlogin" then
		if tokens[2] == adminPassword then
			player:SendChatMessage(Color.green .. "Вы вошли как разработчик")
			Main.isDeveloper[player:GetName()] = true
			print(player:GetName() .. " used /secretlogin")
		else
			print(player:GetName() .. " /secretlogin attemt")
		end
	end
end

function OnServerInit()
	print "-------------- Skymp Official Server --------------"

	Account = require "SkympOfficial/Account"
	AntiCheat = require "SkympOfficial/AntiCheat"
	ItemTypes = require "SkympOfficial/ItemTypes"

	listeners = {
		Main,
		Account,
		AntiCheat,
		ItemTypes,
	}

	for i = 1, #callbacks do
		local fnName = callbacks[i]
		_G[fnName] = function(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
			local val = true
			for j = 1, #listeners do
				local listener = listeners[j]
				if type(listener[fnName]) == "function" then
					local result = listener[fnName](arg1, arg2, arg3, arg4, arg5, arg6, arg7)
					val = val and result
				end
			end
			return val
		end
	end
	OnServerInit()
end	

Color = {
	green =		"#1edb6d",
	red =		"#db271e",
	grey =		"#bebebe"
}

Strings = {
	NoPermission = Color.red .. "У Вас нет прав для выполнения этого действия"
}