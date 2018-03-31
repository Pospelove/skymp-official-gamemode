TimerEx = class()

function TimerEx.Docs()
  return [[
  ----------------------------------------
    checkout TimerEx.RunTests() to learn
           how to use this module
  ----------------------------------------
  ]]
end

function TimerEx:_init(ms, fn)
  self.isKilled = false
  SetTimer(ms, function()
    if not self.isKilled then
      fn()
    end
  end)
end

function TimerEx:Kill()
  self.isKilled = true
end

function TimerEx:Resurrect()
  self.isKilled = false
end

function TimerEx.RunTests()
  local timer = TimerEx(25, function() error("test failed - this timer must be killed") end)
  timer:Kill()
end

return TimerEx
