FilesList = {}

function FilesList.SaveFileNames(g, fileName)
  local fileNames = {}
  for i = 1, #g do
    local wo = g[i]
    if wo ~= nil then
      local fileName = wo:GetFileName()
      table.insert(fileNames, fileName)
    end
  end
  local str = json.encode(fileNames)
  local file = io.open("files/" .. fileName .. ".json", "w")
  file:write(str)
  io.close(file)
end


function FilesList.LoadFileNames(fileName)
  local jsonPath = "files/" .. fileName .. ".json"
  local file = io.open(jsonPath, "r")
  if file == nil then
    error(jsonPath .. " is missing")
  end
  local str = ""
  for line in file:lines() do
    str = str .. line
  end
  io.close(file)
  return json.decode(str)
end

return FilesList
