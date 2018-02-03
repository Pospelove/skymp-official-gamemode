Theme = {
  error = Colors.Get("OrangeRed"),
  success = Colors.Get("LimeGreen"),
  notice = Colors.Get("Gold"),
  info = Colors.Get("SlateGray"),
  sel = Colors.Get("LightBlue"),
  tip = Colors.Get("Silver")
}

function Theme.RunTests()
  if type(Theme.error) ~= "string" or type(Theme.success) ~= "string" or type(Theme.notice) ~= "string" or type(Theme.info) ~= "string" or type(Theme.tip) ~= "string" then
    error "test failed"
  end
end

return Theme
