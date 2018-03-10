local NPCUnarmedDamage = {}

local gData = {}
gData  [0x0004359C] = {20, 1} -- Коза
gData  ["Корова"] = {50, 10}
gData  [0x000A91A0] = {5, 1} -- Курица
gData  ["Собака"] = {30, 1}
gData  [0x0002EBE2] = {20, 1} -- Дикая коза
gData  [0x0006DC9D] = {5, 1} -- Krolik
gData  [0x000829B3] = {10, 1} -- Lisitsa
gData  [0x000829B6] = {10, 1}-- Snow lisa
gData  ["Мамонт"] = {300, 150}
gData  ["Олень"] = {50, 10}

gData  ["Медведь"] = {150, 70}
gData  ["Белый медведь"] = {150, 70}
gData  ["Пещерный медведь"] = {150, 70}
gData  ["Волк"] = {70, 30}
gData  ["Снежный волк"] = {100, 40}
gData  ["Саблезуб"] = {150, 80}
gData  ["Снежный саблезуб"] = {150, 80}
gData  [0x000E4010] = {20, 12}
gData  [0x000E4011] = {30, 14} -- krab
gData  [0x00021875] = {35, 18} -- krab
gData  ["Злокрыс"] = {20, 10}
gData  ["Хоркер"] = {150, 40}
gData  ["Тролль"] = {175, 98}
gData  ["Ледяной тролль"] = {175, 98}
gData  ["Великан"] = {200, 90}
gData  ["Спригган"] = {120, 66}
gData  ["Ворожея"] = {50, 30}
gData  ["Ледяное привидение"] = {100, 50}
gData  [0x0002C3C7] = {5, 10} -- dimka
gData  [0x00023ABD] = {100, 40} -- matb dimka
gData  ["Морозный паук"] = {50, 20}
gData  ["Двемерский паук"] = {100, 40}
gData  [0x0010ec89] = {130, 80} -- dwemer sphere
gData  ["Двемерский центурион"] = {300, 200}

function NPCUnarmedDamage.OnNPCSpawn(npc)
  SetTimer(200, function()
    local t = gData[npc:GetValue("baseID")]
    if not t then t = gData[deru(npc:GetValue("name"))] end
    if not t then return end
    npc.pl:SetBaseAV("UnarmedDamage", t[2])
    npc.pl:SetBaseAV("Health", t[1])
  end)
end

return NPCUnarmedDamage
