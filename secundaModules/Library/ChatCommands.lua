local ChatCommands = {}

--------------------------------------------------------------------------
-- Example
--------------------------------------------------------------------------

local function Foo()

  -- Command must start with '/'
  local cmdText = "/kick"

  -- Command template is set of argument types
  -- 's' = string
  -- 'i', 'd' = decimal
  -- 'x' = hexadecimal
  -- 'f' = float
  local template = "si"

  -- Tip is command name + arguments
  local tip = "/kick <Player Name> <Reason Code>"

  local onCall = function(player, args)

    -- Player can be nil, table, userdata, etc ONLY if the command is called by script
    -- You don't need to check passed player if the command is NOT called by script
    if player == nil then
      -- ...
    end

    local targetName = args[1] -- It's string
    local reasonCode = args[2] -- It's number
    if targetName ~= nil then -- You can check correctness of input by comparing the first argument with nil
      -- ...
      return true -- Return true to do nothing
    end
    return false -- Return false to send tip
  end

  local kick = Command(cmdText, template, tip, onCall)

  -- Kick 'Mobofilka'
  kick:Call(nil, {"Mobofilka", 134})

  -- Can't be called by player or script after Destroy
  kick:Destroy()

  -- Do nothing
  kick:Call(zenimax, {"Pospelov", 146})

  -- Still work
  local name = kick:GetName() -- "/kick"
  local templ = kick:GetTemplate() -- "si"
  local tip = kick:GetTip() -- <your tip>

end

--------------------------------------------------------------------------

ChatCommands.tCreatedCommands = {}

Command = class()

function Command:_init(sCmdName, sTemplate, sTip, OnCall)
  self.sCmdName = sCmdName
  self.sTemplate = sTemplate
  self.sTip = sTip
  self.OnCall = OnCall
  if type(OnCall) ~= "function" then error("bad callback") end
  if type(sTip) ~= "string" then error("bad tip") end
  if type(sTemplate) ~= "string" then error("bad template") end
  if type(sCmdName) ~= "string" then error("bad cmd name") end
  if ChatCommands.tCreatedCommands[self:GetName()]  == nil then
    ChatCommands.tCreatedCommands[self:GetName()] = self
  else
    error(sCmdName .. " command already exist")
  end
end

function Command:GetName()
  return self.sCmdName
end

function Command:GetTemplate()
  return self.sTemplate
end

function Command:GetTip()
  return self.sTip
end

function Command:Destroy()
  if not self.bIsDestroyed then
    ChatCommands.tCreatedCommands[self:GetName()] = nil
    self.bIsDestroyed = true
  end
end

function Command:Call(uPl, tArguments)
  if not self.bIsDestroyed then
    self.OnCall(uPl, tArguments)
  end
end

local function Parse(tTokens, sTempl)
  local tRealArguments = {}
  if type(sTempl) == "string" then
    for i = 1, #sTempl do
      local sChar = stringx.at(sTempl, i)
      local iTokenIndex = i + 1
      local sToken = tTokens[iTokenIndex]
      if type(sToken) == "string" then
        if sChar == "i" or sChar == "d" or sChar == "x" then
          local iArg = tonumber(sToken, sChar == "x" and 16 or 10)
          if iArg == nil then error("tonumber failed") return nil end
          local bIsFloat = math.floor(iArg) ~= iArg
          if bIsFloat then error("must not be float") return nil end
          table.insert(tRealArguments, iArg)
        elseif sChar == "f" then
          local fArg = tonumber(sToken)
          if fArg == nil then error("tonumber failed") return nil end
          table.insert(tRealArguments, fArg)
        elseif sChar == "s" then
          local sArg = sToken
          table.insert(tRealArguments, sArg)
        end
      end
    end
  end
  return tRealArguments
end

function ChatCommands.OnPlayerChatInput(uPl, sInputText)
  if stringx.startswith(sInputText, "/") then
    local tTokens = stringx.split(sInputText)
    local sCmdText = tTokens[1]
    local tCmd = ChatCommands.tCreatedCommands[sCmdText]
    if tCmd ~= nil then
      local bSuccess = tCmd:Call(uPl, Parse(tTokens, tCmd:GetTemplate()))
      if not bSuccess then
        uPl:SendChatMessage(tCmd:GetTip())
      end
    end
  end
  return true
end

function ChatCommands.RunTests()

  local TestParse = function()
    local tRes = {}

    tRes = Parse({"///", "123", "456.789", "0001"}, "dfs")
    if not (tRes and tRes[1] == 123 and tRes[2] == 456.789 and tRes[3] == "0001") then
      error("test failed")
    end

    tRes = Parse({"///", "DEAD", "E6AC", "FAC"}, "xxx")
    if not (tRes and tRes[1] == 0xDEAD and tRes[2] == 0xE6AC and tRes[3] == 0xFAC) then
      error("test failed")
    end

    tRes = Parse({"///", "-1"}, "f")
    if not (tRes and tRes[1] == -1) then
      error("test failed")
    end

    tRes = Parse({"///"}, "")
    if not (tRes and tRes[1] == nil) then
      error("test failed")
    end
  end

  local TestCall = function()
    local tSomeCmd = {}

    tSomeCmd = Command("///", "", "bla-bla-tip", function(uPl, tArgs)
      return true
    end)
    tSomeCmd:Call(nil, {})
    tSomeCmd:Destroy()

    tSomeCmd = Command("///", "i", "bla-bla-tip", function(uPl, tArgs)
      if tArgs[1] ~= 42 then error("test failed") end
      return true
    end)
    tSomeCmd:Call(nil, {42})
    tSomeCmd:Destroy()

    tSomeCmd = Command("///", "fff", "bla-bla-tip", function(uPl, tArgs)
      if tArgs[1] ~= 123.456 or tArgs[2] ~= -909.909 or tArgs[3] ~= 228.322 then error("test failed") end
      return true
    end)
    tSomeCmd:Call(nil, {123.456, -909.909, 228.322})
    tSomeCmd:Destroy()

    tSomeCmd = Command("///", "f", "bla-bla-tip", function(uPl, tArgs)
      if tArgs == nil or tArgs[1] ~= nil then error("test failed") end
      return true
    end)
    tSomeCmd:Call(nil, Parse("Foo", "f"))
    tSomeCmd:Destroy()
  end

  local TestPlayerCommandInput = function()
    ChatCommands.bSuccessfulTest = false
    local tCmd = Command("/test", "sif", "bla-bla-tip", function(uPl, tArgs)
      if tArgs == nil or tArgs[1] ~= "Skyrim" or tArgs[2] ~= 2028 or tArgs[3] ~= 0.115 then error("test failed") end
      ChatCommands.bSuccessfulTest = true
    end)

    local uZombie = Player.CreateNPC(0xDEAD00)
    ChatCommands.OnPlayerChatInput(uZombie, "/test Skyrim 2028 0.115")

    if not ChatCommands.bSuccessfulTest then
      error("test failed")
    end

    uZombie:Kick()
    ChatCommands.bSuccessfulTest = nil
    tCmd:Destroy()
  end

  local TestCommandDuplicate = function()
    local tCmd = {}
    local bSuccess = pcall(function()
      tCmd = Command("/somecmd", "", "", function() end)
      tCmd = Command("/somecmd", "", "", function() end)
    end)
    tCmd:Destroy()
    if bSuccess then
      error("test failed: commands with same name must not be created")
    end
  end

  TestParse()
  TestCall()
  TestPlayerCommandInput()
  TestCommandDuplicate()
  Foo()
end

return ChatCommands
