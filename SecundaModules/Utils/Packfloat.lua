
function packfloat(val)
  if val == nil then return nil end
  local res = tostring(val)
  res = res:gsub("%,", "_")
  res = res:gsub("%.", "_")
  return res
end

function unpackfloat(str)
  if str == nil then return nil end
  local s = str:gsub("_", ".")
  local n = tonumber(s)
  if n ~= nil then return n end
  s = str:gsub("_", ",")
  n = tonumber(s)
  return n
end

if packfloat(1.1) ~= "1_1" then error("test failed - packfloat() ") end
if packfloat(-3.4) ~= "-3_4" then error("test failed - packfloat()") end
if packfloat(9) ~= "9" then error("test failed - packfloat()") end
if unpackfloat("1_2") ~= 1.2 then error("test failed - packfloat()") end
if unpackfloat("-1_2") ~= -1.2 then error("test failed - packfloat()") end
if unpackfloat("-1000") ~= -1000 then error("test failed - packfloat()") end
if unpackfloat(packfloat(9.1)) ~= 9.1 then error("test failed - packfloat()") end
if unpackfloat(packfloat(9)) ~= 9 then error("test failed - packfloat()") end

return {}
