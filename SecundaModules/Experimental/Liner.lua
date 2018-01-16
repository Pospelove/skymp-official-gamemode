local Liner = {}

local gLexs = {
  "=", "+", "-", "/", "*", "..", "(", ")", "[", "]", "'", ",", "#", ".", ";", " ",
  "if", "else", "elseif", "end", "return", "while", "do", "for",
  "tostring", "tonumber",
  "a", "b", "c", "d", "e", "f", "g", "h",
  "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"
}
local gLexsSize = #gLexs

math.randomseed(os.time())

function Liner.NewInstance(numLexs)

  local str = ""
  for i = 1, numLexs do
    str = str .. gLexs[math.random(1, gLexsSize)] .. " "
  end
  return str
end

function Liner.RunTests()
  -- ... 
end

return Liner
