Magic2 = {}

local gRaw = dsres.magic
local gMagic = {}
local gNumIdensUse = {}
local gMagicByID = {}

function Magic2.Lookup(key)
  if type(key) == "string" then
    local res = Magic.LookupByIdentifier(key)
    if not res then res = Magic.LookupByIdentifier("Spell " ..key) end
    if not res then res = Magic.LookupByIdentifier("Enchantment " ..key) end
    return res
  elseif type(key) == "number" then
    return gMagicByID[key]
  end
end

function Magic2.Init()
  local count = #gRaw
  print("")
  print("Creating " .. count .. " magic")

  local clock = GetTickCount()

  for i = 1, count do
    local t = gRaw[i]
    if t ~= nil then
      local type = t[1] -- "Spell" / "Enchantment"
      local iden = t[2]
      local formID = t[3]
      local cost = t[4]
      local effectItems = {}
      local j = 5
      while t[j] ~= nil do
        table.insert(effectItems, t[j])
        j = j + 1
      end

      if gNumIdensUse[iden] == nil then
        gNumIdensUse[iden] = 0
      end
      local iden_ = type .. " " .. iden
      if gNumIdensUse[iden] > 0 then
        iden_ = iden .. tostring(gNumIdensUse[iden])
      end
      local magic = Magic.Create(type, iden_, formID, cost)
      if magic == nil then
        print ("Unable to create Magic " .. string.format("%X", formID))
      else
        for i = 1, #effectItems do
          local formID = effectItems[i][1]
          local mag = effectItems[i][2]
          local dur = effectItems[i][3]
          local area = effectItems[i][4]
          local mgef = Effects.Lookup(formID)
          if mgef == nil then
            -- ...
          else
            magic:AddEffect(mgef, mag, dur, area)
          end
        end
        gMagicByID[formID] = magic
      end
      gNumIdensUse[iden] = gNumIdensUse[iden] + 1
    end
  end

  print("Done in " .. (GetTickCount() - clock) .. "ms")
end

function Magic2.Require()
  --if 1 then return end
  Effects.Require()
  if not Magic2.inited then
    Magic2.Init()
    Magic2.inited = true
  end
end

function Magic2.GetAny()
  for k, v in pairs(gMagicByID) do return v end
end

function Magic2.TestPerfomance()

  local FormatTime = function(clock, numCalls)
    local ms = ((GetTickCount() - clock) / numCalls)
    local perSec = math.floor(1 / ms * 1000)
    return ms  .. "ms " .. "(" .. perSec .. " per sec)"
  end

  local clock = GetTickCount()
  local numCalls = 10000
  local anyIden = Magic2.GetAny():GetIdentifier()
  for i = 1, numCalls do
    local itemType = Magic.LookupByIdentifier(anyIden)
  end
  print("Magic.LookupByIdentifier() = " .. FormatTime(clock, numCalls))
end

function ItemTypes.Require()
  Effects.Require()
  Magic2.Require()
  if not ItemTypes.inited then
    ItemTypes.Init()
    ItemTypes.inited = true
  end
end

return Magic2
