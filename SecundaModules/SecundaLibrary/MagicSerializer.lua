MagicSerializer = {}

local gMagicCache = {}
local gN = 0

function MagicSerializer.Serialize(magic)
  local entries = {}
  local n = 1, magic:GetNumEffects() do
    local entry = {}
    entry.mag = math.ceil(magic:GetNthEffectMagnitude(n))
    entry.dur = math.ceil(magic:GetNthEffectDuration(n))
    --print("dur is " .. entry.dur .. " for " .. magic:GetIdentifier())
    entry.area = math.ceil(magic:GetNthEffectArea(n))
    entry.mgefID = (magic:GetNthEffect(n):GetBaseID())
    table.insert(entries, entry)
  end
  local t = {}
  t.entries = entries
  t.cost = math.floor(magic:GetCost())
  t.formID = magic:GetBaseID()
  return pretty.write(t)
end

local function CreateIdenForMagic(type)
  local result = ""
  while true do
    gN = gN + 1
    result = tostring(type) .. "_" .. gN
    if Magic.LookupByIdentifier(result) == nil then break end
  end
  return result
end

function MagicSerializer.Deserialize(str, type)
  local cacheKey = type .. " " .. str

  if gMagicCache[cacheKey] ~= nil then return gMagicCache[cacheKey] end

  local iden_ = CreateIdenForMagic(type)
  local t = pretty.read(str)
  local magic = Magic.Create(type, iden_, t.formID, t.cost)
  for n = 1, #t.entries do
    local entry = t.entries[n]
    magic:AddEffect(Effects.Lookup(entry.mgefID), entry.mag, entry.dur, entry.area)
    --print("set dur to  " .. entry.dur .. " for " .. magic:GetIdentifier())
    --print("dur set to " .. magic:GetNthEffectDuration(magic:GetNumEffects()))
  end
  gMagicCache[cacheKey] = magic
  return magic
end

local function CreateTestSpells()
  local result = {}

  local effects = {
    { "TestFireDamageConcAimed",			"ValueMod",			0x00013CA9,			"Concentration",		"Aimed",			"Health" },
    { "TestShockDamageConcAimed",			"ValueMod",			0x00013CAB,			"Concentration",		"Aimed",			"Health" },
    { "TestFireDamageFFAimed",				"ValueMod",			0x00012F03,			"FireAndForget",		"Aimed",			"Health" },
    { "TestFireDamageFFAimedArea",			"ValueMod",			0x0001CEA1,			"FireAndForget",		"Aimed",			"Health" },
    { "TestFireRuneFFLocation",				"ValueMod",			0x0005DB8F,			"FireAndForget",		"TargetLocation",	"Health" },
    { "TestRestoreHealthConcSelf",			"ValueMod",			0x0001CEA4,			"Concentration",		"Self",				"Health" },
    { "TestTelekinesisEffect",				"Telekinesis",		0x0001A4CB,			"Concentration",		"Aimed",			"" },
    { "TestAbDamageHealth",					"ValueMod",			0x000C1E8E,			"ConstantEffect",		"Self",				"Health" },
    { "TestdunLabyRestoreMagickaConcSelf",	"ValueMod",			0x0010E834,			"Concentration",		"Self",				"Magicka" },
    { "TestDunLabyDamageHealthConcSelf",	"ValueMod",			0x000F82E2,			"Concentration",		"Self",				"Health" },
    { "TestAlchRestoreHealth",				"ValueMod",			0x0003EB15,			"FireAndForget",		"Self",				"Health" },
    { "TestAlchRestoreStamina",				"ValueMod",			0x0003EB16,			"FireAndForget",		"Self",				"Stamina" },
    { "TestAlchRestoreMagicka",				"ValueMod",			0x0003EB17,			"FireAndForget",		"Self",				"Magicka" },
    { "TestAlchDamageHealth",				"ValueMod",			0x0003EB42,			"FireAndForget",		"Self",				"Health" },
    { "TestEnchFireDamageFFContact",		"ValueMod",			0x0004605A,			"FireAndForget",		"Contact",			"Health" },
    { "TestUnlockEffect",					"ValueMod",			0x0004605C,			"FireAndForget",		"Contact",			"Health" },
    { "TestSoulTrapFFActor",				"SoulTrap",			0x0004DBA3,			"FireAndForget",		"TargetActor",		""},
    { "TestSummonEffect1",					"SummonCreature",	0x0001CEAB,			"FireAndForget",		"TargetLocation",	""}
  }
  for i = 1, #effects do
    local effect = Effect.Create(effects[i][1], effects[i][2], effects[i][3], effects[i][4], effects[i][5])
    effect:SetActorValues(effects[i][6], "")
  end

	local spells = {
		{ "TestFlames",				0x0F012FCD,		7.0,	{ "TestFireDamageConcAimed", -11.0, 0.1, 0.0 } },
		{ "TestSparks",				0x0F02DD2A,		9.0,	{ "TestShockDamageConcAimed", -12.0, 1, 0.0 } },
		{ "TestHealing",			0x0F012FCC,		10.0,	{ "TestRestoreHealthConcSelf", 25.0, 1, 0.0 } },
		{ "TestFirebolt",			0x0F012FD0,		30.0,	{ "TestFireDamageFFAimed", -44.0, 1.0, 0.0 } },
		{ "TestFireball",			0x0F01C789,		1000.0,	{ "TestFireDamageFFAimedArea", -50.0, 2.0, 4.5 } },
		{ "TestTelekinesis",		0x0F01A4CC,		1.0,	{ "TestTelekinesisEffect", 1.0, 1.0, 0.0} },
		{ "TestFireRune",			0x0F05DB90,		100.0,	{ "TestFireRuneFFLocation", -50.0, 2.0, 4.4} },
		{ "TestEquilibrium",		0x0F0DA746,		1.0,	{ "TestDunLabyDamageHealthConcSelf", -25.0, 1, 0.0}, { "TestdunLabyRestoreMagickaConcSelf", 25.0, 1, 0.0} },
		{ "TestSoulTrap",			0x0F04DBA4,		1.0,	{ "TestSoulTrapFFActor", 1.0, 45.0, 1000.0 }},
		{ "TestSummon1",			0x0F0204C4,		15.0,	{ "TestSummonEffect1", 1, 1, 1}}
	}
	for i = 1, #spells do
		local spell = Magic.Create("Spell", spells[i][1], spells[i][2], spells[i][3])
		for j = 4, #spells[i] do
			local effect = Effect.LookupByIdentifier(spells[i][j][1])
			local mag = spells[i][j][2]
			local dur = spells[i][j][3]
			local area = spells[i][j][4]
			if spell then spell:AddEffect(effect, mag, dur, area) end
		end
    table.insert(result, spell)
	end

  return result
end

function MagicSerializer.RunTests()
  local spells = CreateTestSpells()
  for i = 1, #spells do
    local str = MagicSerializer.Serialize(spells[i])
    local spellCopy = MagicSerializer.Deserialize(str, "Spell")
    if spellCopy == nil then
      error("test failed - MagicSerializer")
    end
    if spellCopy:GetBaseID() ~= spells[i]:GetBaseID() then
      error("test failed - MagicSerializer " .. spellCopy:GetBaseID() .. " ~= " .. spells[i]:GetBaseID())
    end
    local str2 = MagicSerializer.Serialize(spellCopy)
    if str2 ~= str then
      error("test failed - MagicSerializer: " .. str2 .. " ~= " .. str)
    end
    local expectedIden = "Spell_" .. i
    if spellCopy:GetIdentifier() ~= expectedIden then
      error("test failed - MagicSerializer " .. spellCopy:GetIdentifier() .. " ~= " .. expectedIden)
    end
    local r1 = MagicSerializer.Deserialize(str, "Spell")
    local r2 = MagicSerializer.Deserialize(str, "Spell")
    if r1:GetIdentifier() ~= r2:GetIdentifier() then
      error("test failed - MagicSerializer " .. r1:GetIdentifier() .. " ~= " .. r2:GetIdentifier())
    end
  end
end

return MagicSerializer
