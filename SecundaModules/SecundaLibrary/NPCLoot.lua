NPCLoot = {}

local function GetContFor(key)
  local cont = Container()
  local Add = function(itemTypeIden, count)
    cont:AddItem(ItemTypes.Lookup(itemTypeIden), count)
  end
  if key == 0x0004359C or key == 0x0002EBE2 then
    Add("Козья шкура", 1)
    Add("Козий окорок", 1)
    return cont
  end
  if key == "Корова" then
    Add("Коровья шкура", 1)
    return cont
  end
  if key == 0x000A91A0 then
    Add("Куриная грудка", 1)
    --print("CHICKEN LOOT")
    if math.random(1, 10) == 5 then Add("Куриное яйцо", 1) end
    return cont
  end
  if key == "Собака" then
    Add("Собачатина", 1)
    return cont
  end
  if key == 0x0006DC9D then
    Add("Сырая кроличья ножка", math.random(1, 4))
    return cont
  end
  if key == 0x000829B3 then
    Add("Шкура лисицы", 1)
    return cont
  end
  if key == 0x000829B6 then
    Add("Шкура снежной лисицы", 1)
    return cont
  end
  if key == "Мамонт" then
    Add("Бивень мамонта", 2)
    return cont
  end
  if key == "Олень" then
    if math.random(1, 3) == 1 then
      Add("Большие рога", 1)
    else
      Add("Маленькие рога", 1)
    end
    return cont
  end
  if key == "Медведь" then
    Add("Медвежьи когти", 1)
    Add("Шкура медведя", 1)
    return cont
  end
  if key == "Медведь" or key == "Пещерный медведь" then
    Add("Медвежьи когти", 1)
    Add("Шкура медведя", 1)
    return cont
  end
  if key == "Белый медведь" then
    Add("Медвежьи когти", 1)
    Add("Шкура белого медведя", 1)
    return cont
  end
  if key == "Волк" then
    Add("Волчья шкура", 1)
    return cont
  end
  if key == "Снежный волк" then
    Add("Шкура снежного волка", 1)
    return cont
  end
  if key == "Саблезуб" then
    Add("Шкура саблезуба", 1)
    return cont
  end
  if key == "Снежный саблезуб" then
    Add("Шкура снежного саблезуба", 1)
    return cont
  end
  if key == 0x000E4010 or key == 0x000E4010 or key == 0x000E4011 or key == 0x00021875 then
    Add("Клешня грязевого краба", 2)
    return cont
  end
  if key == "Злокрыс" then
    Add("Хвост злокрыса", 1)
    return cont
  end
  if key == "Хоркер" then
    Add("Мясо хоркера", 4)
    return cont
  end
  if key == "Тролль" or key == "Ледяной тролль" then
    Add("Жир тролля", 1)
    return cont
  end
  if key == "Великан" then
    Add("Палец великана", 1)
    Add("Золото", 100)
    return cont
  end
  if key == "Спригган" then
    Add("Живица сприггана", 1)
    if math.random(1, 100) == 1 then
      Add("Полено", 1)
    end
    return cont
  end
  if key == "Ворожея" then
    Add("Перья ворожеи", 1)
    return cont
  end
  if key == "Ледяное привидение" then
    Add("Зубы ледяного привидения", 1)
    return cont
  end
  return nil
end

function NPCLoot.FillContainer(npc)
  --print("1")
  local cont = GetContFor(npc:GetValue("baseID"))
  if not cont then cont = GetContFor(deru(npc:GetValue("name"))) end
  if cont then
      --print("2")
    --if npc:GetValue("baseID") ==  0x000A91A0  then print("CHICKEN LOOT 2") end
    cont:ApplyTo(npc.pl)
  end
  --npc.pl:AddItem("Полено", 1)
end

return NPCLoot
