local NicknameRules = {}

function NicknameRules.OnUserConnect(user)
  local name = user:GetName()
  if name:len() < 2 or name:len() > 24 then
    user:SendChatMessage(Theme.error .. "Длина имени должна быть от 2 до 24 символов")
    SetTimer(100, function() user:Kick() end)
    return true
  end
  local s = { "_" }
  for i = 1, #s do
    if name:gsub(s[i], " ") ~= name then
      user:SendChatMessage(Theme.error .. "Недопустимые символы в имени")
      SetTimer(100, function() user:Kick() end)
      return true
    end
  end
  local t = {}
  t[1] = "qqq"; t[2] = "www"; t[3] = "eee"
  t[4] = "rrr"; t[5] = "ttt"; t[6] = "yyy"
  t[7] = "uuu"; t[8] = "iii"; t[9] = "ooo"
  t[10] = "ppp"; t[11] = "aaa"; t[12] = "sss"
  t[13] = "ddd"; t[14] = "fff"; t[15] = "ggg"
  t[16] = "hhh"; t[17] = "jjj"; t[18] = "kkk"
  t[19] = "lll"; t[20] = "zzz"; t[21] = "xxx"
  t[22] = "ccc"; t[23] = "vvv"; t[24] = "bbb"
  t[25] = "nnn"; t[26] = "mmm"

  for k, v in pairs(t) do
    if string.find(name, v, 1) then
      user:SendChatMessage(Theme.error .. "Буква встречается несколько раз подряд в Вашем имени (" .. v .. ")")
      SetTimer(100, function() user:Kick() end)
      return true
    end
  end
  for i = 2, name:len() do
    if stringx.isupper(stringx.at(name, i)) then
      user:SendChatMessage(Theme.error .. "Только первая буква имени может быть заглавной")
      SetTimer(100, function() user:Kick() end)
      return true
    end
  end
  return true
end

return NicknameRules
