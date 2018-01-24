Database = {}

local gClients = {}
local gNumClients = 10
local gQueryForm = "application/x-www-form-urlencoded"
local gQID = 0
local gCallbacksMap = {}
local gResponse = false

function Database.CheckAuth(user, callback)
  Database.Get("/auth/" .. user:GetName()  .. "/" .. user:GetIP(), function(body)
    callback(body == "ok")
  end)
end

function Database.LoadAccount(name, callback)
  Database.Get("/account/" .. name, function(body)
    local t = json.decode(body)
    for key, value in pairs(t) do
      if type(value) == "string" and tonumber(value) ~= nil then
        t[key] = tonumber(value)
      end
    end
    callback(t)
  end)
end

function Database.SaveAccount(t)
  Database.Post("/account", t, function() end)
end

local function GetRandomClient()
  return gClients[math.random(1, gNumClients)]
end

function Database.Post(path, body, callback)
  local bodyStr = ""
  if type(body) == "string" then
    bodyStr = body
  elseif type(body) == "table" then
    for key, value in pairs(body) do
      if string.len(bodyStr) > 0 then bodyStr = bodyStr .. "&" end
      bodyStr = bodyStr .. key .. "=" .. url.quote(tostring(value))
    end
  else
    error("bad request body " .. type(body))
  end
  gQID = gQID + 1
  local cli = GetRandomClient()
  cli:Post(gQID, path, bodyStr, gQueryForm)
  gCallbacksMap[gQID] = callback
end

function Database.Get(path, callback)
  gQID = gQID + 1
  local cli = GetRandomClient()
  cli:Get(gQID, path)
  gCallbacksMap[gQID] = callback
end

function Database.OnServerInit()
  for i = 1, gNumClients do
    local client = HTTPClient(Config.Database["host"], Config.Database["port"])
    table.insert(gClients, client)
  end
  return true
end

function OnHTTPResult(requestID, body, code)
  gCallbacksMap[requestID](body, code)
  gCallbacksMap[requestID] = nil
  return true
end

function Database.RunTests()
  Database.Get("/account/SecundaTest", function(body, status)
    local t = json.decode(body)

    t["testJailTime"] = 3601
    t["testInventory"] = json.encode({
      LongBow = 1,
      IronArrow = 201
    })
    t["testInteger"] = 2330

    Database.Post("/account", t, function(body, status)
      local t = json.decode(body)
      if t.name == "SecundaTest" then
        gResponse = true
      else
        error("wtf wrong name " .. t.name)
      end
    end)
  end)
  Database.Get("/auth/dapoemfdddkeiadkieo/127.0.0.1", function(body, status)
    if body ~= "bad" and body ~= "ok" then error("test failed " .. tostring(body)) end
  end)
  SetTimer(6000, function()
    if gResponse ~= true then
      error("database not working")
    else
      print("")
      print("Database works")
    end
  end)
end

return Database
