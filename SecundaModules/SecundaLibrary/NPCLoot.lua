NPCLoot = {}

local function GetContFor(key)
  local cont = Container()
  local Add = function(itemTypeIden, count)
    cont:AddItem(ItemTypes.Lookup(itemTypeIden), count)
  end
  if key == 0x0004359C or key == 0x0002EBE2 then
    Add("����� �����", 1)
    Add("����� ������", 1)
    return cont
  end
  if key == "������" then
    Add("������� �����", 1)
    return cont
  end
  if key == 0x000A91A0 then
    Add("������� ������", 1)
    --print("CHICKEN LOOT")
    if math.random(1, 10) == 5 then Add("������� ����", 1) end
    return cont
  end
  if key == "������" then
    Add("����������", 1)
    return cont
  end
  if key == 0x0006DC9D then
    Add("����� �������� �����", math.random(1, 4))
    return cont
  end
  if key == 0x000829B3 then
    Add("����� ������", 1)
    return cont
  end
  if key == 0x000829B6 then
    Add("����� ������� ������", 1)
    return cont
  end
  if key == "������" then
    Add("������ �������", 2)
    return cont
  end
  if key == "�����" then
    if math.random(1, 3) == 1 then
      Add("������� ����", 1)
    else
      Add("��������� ����", 1)
    end
    return cont
  end
  if key == "�������" then
    Add("�������� �����", 1)
    Add("����� �������", 1)
    return cont
  end
  if key == "�������" or key == "�������� �������" then
    Add("�������� �����", 1)
    Add("����� �������", 1)
    return cont
  end
  if key == "����� �������" then
    Add("�������� �����", 1)
    Add("����� ������ �������", 1)
    return cont
  end
  if key == "����" then
    Add("������ �����", 1)
    return cont
  end
  if key == "������� ����" then
    Add("����� �������� �����", 1)
    return cont
  end
  if key == "��������" then
    Add("����� ���������", 1)
    return cont
  end
  if key == "������� ��������" then
    Add("����� �������� ���������", 1)
    return cont
  end
  if key == 0x000E4010 or key == 0x000E4010 or key == 0x000E4011 or key == 0x00021875 then
    Add("������ ��������� �����", 2)
    return cont
  end
  if key == "�������" then
    Add("����� ��������", 1)
    return cont
  end
  if key == "������" then
    Add("���� �������", 4)
    return cont
  end
  if key == "������" or key == "������� ������" then
    Add("��� ������", 1)
    return cont
  end
  if key == "�������" then
    Add("����� ��������", 1)
    Add("������", 100)
    return cont
  end
  if key == "��������" then
    Add("������ ���������", 1)
    if math.random(1, 100) == 1 then
      Add("������", 1)
    end
    return cont
  end
  if key == "�������" then
    Add("����� �������", 1)
    return cont
  end
  if key == "������� ����������" then
    Add("���� �������� ����������", 1)
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
  --npc.pl:AddItem("������", 1)
end

return NPCLoot
