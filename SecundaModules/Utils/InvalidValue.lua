InvalidValue = class()

local gInvalidValueKey = [[
DIJAOISJDOIAJSDIOJASDOIJASD
BNNIJASPDKJPAOSDKOAKSDOKPAS
DOIJAOLISJDOAIFBNNLAMCQQDSA
YYRHYRHJRJFJFJHJOHJGGGWGWJW
SKKDJSHJAJAUDJSAJHYDAWKAUJK
AOSJDAJSDIJASDOAJSDAIJDAIJA
EYYUYQDASMNCGEKFHSKFGEKJDKJ
DIJAOISJDOIAJSDIOJASDOIJASD
GGWIJASPDKJPAOSDKOAKSDOKQDA
IAJJAOLISJDOAIFBNNLAMCGJFJH
]]

function InvalidValue:_init()
  self[gInvalidValueKey] = true
end

function IsInvalidValue(someValue)
  return someValue[gInvalidValueKey] == true
end

function InvalidValue.RunTests()
  if not IsInvalidValue(InvalidValue()) then
    error "test failed - Invalid value is not invalid value"
  end
end

return InvalidValue
