-- Chat.lua

local Chat = {}

function Chat.OnPlayerChatInput(player, text)
	local n = 144
	if text:len() > n then
		return player:SendChatMessage(Color.red .. "Длина сообщения не должна превышать " .. n .. " символов")
	end

	text:gsub("#", " ")

	if player:IsSpawned() and Account.IsLogged(player) then
		
		player:SetChatBubble(text, 7000)

		for i = 0, GetMaxPlayers() do
			local pl = Player.LookupByID(i)
			if pl and pl:IsConnected() and pl:IsSpawned() and Account.IsLogged(pl) then
				local distance = math.sqrt((pl:GetX() - player:GetX()) ^ 2 + (pl:GetY() - player:GetY()) ^ 2 + (pl:GetZ() - player:GetZ()) ^ 2)
				local d = distance / 1400
				if d < 0.0 then
					print(player:GetName() .. "[" .. player:GetID() .. "] sent chat message with invalid distance")
					return player:Kick()
				end	
				if d < 1.0 then
					local hexStr = string.format("%02x", math.floor((1 - d) * 256))
					if hexStr == "100" then hexStr = "FF" end
					local colorStr = "#" .. hexStr .. hexStr .. hexStr
					pl:SendChatMessage(colorStr .. player:GetName() .. "[" .. player:GetID() .. "]: " .. text)
				end
			end
		end
	end
end

return Chat