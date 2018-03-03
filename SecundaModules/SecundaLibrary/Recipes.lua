Recipes = {}

local gRaw = dsres.recipes
local gRecipes = {}
local gHasRecipes = {}
local gKeywordFilters = {}
local gSessionId = {}

function Recipes.Init()
  local count = #gRaw
  print("")
  print("Creating " .. count .. " recipes")

  local clock = GetTickCount()

  for i = 1, count do
    local t = gRaw[i]
    if t ~= nil then
      local workbenchKeyword = t[1]
      local resultIden = t[2]
      local numCreated = t[3]
      local ingredientsMap = t[4]

      if resultIden ~= "" then
        local resultItemType = ItemType.LookupByIdentifier(resultIden)
        if resultItemType == nil then
          print("Recipes: ItemType not found " .. resultIden)
        else
          local recipe = Recipe.Create(workbenchKeyword, resultItemType, numCreated)
          for key, value in pairs(ingredientsMap) do
            recipe:AddItem(ItemTypes.Get(key), value)
          end
          table.insert(gRecipes, recipe)
        end
      end
    end
  end

  print("Done in " .. (GetTickCount() - clock) .. "ms")
end

function Recipes.Require()
  ItemTypes.Require()
  if not Recipes.inited then
    Recipes.Init()
    Recipes.inited = true
  end
end

function Recipes.OnServerInit()
  Recipes.Require()
  return true
end

function Recipes.OnUserSpawn(user)
  return true
end

function Recipes.OnUserConnect(user)
  gSessionId[user:GetID()] = math.random(0, 1000000000)
  if #gKeywordFilters > 10000 then
    print("collecting garbage in Recipes")
    gKeywordFilters = {}
  end
end

function Recipes.SendTo(player, keywordFilter)
  if type(keywordFilter) ~= "string" then
    error("expected string keyword filter")
  end
  gKeywordFilters[keywordFilter] = true
  local k = tostring(keywordFilter) .. tostring(player:GetID()) .. tostring(player:GetName()) .. tostring(gSessionId[player:GetID()])
  if gHasRecipes[k] == true then return end

  SetTimer(1000, function()
    local clock = GetTickCount()
    print ("Sending recipes to " .. tostring(User.Lookup(player:GetID())))
    local numParts = 20
    if keywordFilter == "CraftingCookpot" or keywordFilter == "isCookingSpit" then numParts = 2 end
    local onePartDelayMs = 200
    local ranges = {}
    for part = 1, numParts do
      ranges[part] = {}
      ranges[part].first = (#gRecipes / numParts) * (part - 1) + 1
      ranges[part].second = (#gRecipes / numParts) * (part)
    end
    for part = 1, numParts do
      SetTimer(part * onePartDelayMs, function()
        for i = math.floor(ranges[part].first), math.floor(ranges[part].second) + 1 do
          local r = gRecipes[i]
          if r ~= nil and r:GetWorkbenchKeyword() == keywordFilter then
            player:UpdateRecipeInfo(r)
          end
        end
      end)
    end
    gHasRecipes[k] = true
  end)
end

return Recipes
