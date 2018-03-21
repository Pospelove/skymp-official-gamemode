Loadable = {}

local gCount = {}

function Loadable.Load(loadable, dirName)
  local file = nil
  local suc, errstr = pcall(function()
    local filePath = "files/" .. dirName .. "/" .. loadable:GetFileName() .. ".json"
    file = io.open(filePath, "r")
    if file == nil then
      error("unable to open " .. filePath)
    end
    if not gCount[dirName] then gCount[dirName] = 1 end
    local n = gCount[dirName]
    gCount[dirName] = gCount[dirName] + 1
    print("loading data from " .. filePath .. "[" .. n .. "]")
    local str = ""
    for line in file:lines() do
      str = str .. line
    end
    loadable.data = json.decode(str)
    loadable:_ApplyData()
  end)
  if file ~= nil then
    io.close(file)
  end
  if not suc then
    print("error while loading data from " .. dirName .. "/" .. loadable:GetFileName() .. ".json: " .. errstr)
    print("instance will be deleted")
    loadable:Delete()
  end
end

function Loadable.Save(loadable, dirName)
  loadable:_PrepareDataToSave()
  local filePath = "files/" .. dirName .. "/" .. loadable:GetFileName() .. ".json"
  local file = io.open(filePath, "w")
  if file == nil then
    error("files/" .. dirName .. "/" .. " directory not found")
  end

  local data = ""
  local success, errc = pcall(function() data = json.encode(loadable.data) end)
  if success then
    file:write(data)
    print("saving " .. dirName .. "/" .. loadable:GetFileName() .. ".json")
  else
    error (errc .. "\n\n" .. pretty.write(loadable.data))
  end
  io.close(file)
end

return Loadable
