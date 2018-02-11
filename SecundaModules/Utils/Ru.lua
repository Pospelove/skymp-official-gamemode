ru = function(str)
	local cyr  = "����������������������������������������������������������������"
	for i = 1, string.len(cyr) do
		str = string.gsub(str, stringx.at(cyr, i), "<cy:" .. tostring(i) .. ">")
	end
	return str
end
if ru "���" ~= "<cy:16><cy:31><cy:15>" then error("test failed - ru()") end

deru = function(str)
	local cyr  = "����������������������������������������������������������������"
	for i = 1, string.len(cyr) do
		str = string.gsub(str, "<cy:" .. tostring(i) .. ">", stringx.at(cyr, i))
	end
	return str
end
if deru "<cy:16><cy:31><cy:15>" ~= "���" then error("test failed - deru()") end

isru = function(str)
	return ru(str) ~= deru(str)
end
if not isru "����-�����-����" then error("test failed - isru()") end
if isru "yamashi for president" then error("test failed - isru()") end
if not isru "Kek�" then error("test failed - isru()") end


return {}
