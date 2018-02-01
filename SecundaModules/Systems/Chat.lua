local Chat = {}

function Chat.OnUserChatMessage(user, text)
	local n = 145
	if deru(text):len() > n then
		return user:SendChatMessage(Theme.error .. "Длина сообщения не должна превышать " .. n .. " символов")
	end

	text:gsub("#", " ")

	if user:IsSpawned() then

		user:SetChatBubble(text, 7000)

		for i = 0, GetMaxPlayers() do
			local u = User.Lookup(i)
			if u ~= nil and u:IsConnected() and u:IsSpawned() and u:GetVirtualWorld() == user:GetVirtualWorld() then
				local distance = Math.GetDistance(user, u)
				local d = distance / 1400
				if d < 0.0 then
					print(user:GetName() .. "[" .. user:GetID() .. "] sent chat message with invalid distance")
					return user:Kick()
				end
				if d < 1.0 then
					local hexStr = string.format("%02x", math.floor((1 - d) * 256))
					if hexStr == "100" then hexStr = "FF" end
					local colorStr = "#" .. hexStr .. hexStr .. hexStr
					u:SendChatMessage(colorStr .. user:GetName() .. "[" .. user:GetID() .. "]: " .. text)
				end
			end
		end
	end
end

return Chat
