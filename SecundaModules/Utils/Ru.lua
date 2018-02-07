ru = function(str)
	local cyr  = "éöóêåíãøùçõúôûâàïğîëäæıÿ÷ñìèòüáşÉÖÓÊÅÍÃØÙÇÕÚÔÛÂÀÏĞÎËÄÆİß×ÑÌÈÒÜÁŞ"
	for i = 1, string.len(cyr) do
		str = string.gsub(str, stringx.at(cyr, i), "<cy:" .. tostring(i) .. ">")
	end
	return str
end
if ru "àáâ" ~= "<cy:16><cy:31><cy:15>" then error("test failed - ru()") end

deru = function(str)
	local cyr  = "éöóêåíãøùçõúôûâàïğîëäæıÿ÷ñìèòüáşÉÖÓÊÅÍÃØÙÇÕÚÔÛÂÀÏĞÎËÄÆİß×ÑÌÈÒÜÁŞ"
	for i = 1, string.len(cyr) do
		str = string.gsub(str, "<cy:" .. tostring(i) .. ">", stringx.at(cyr, i))
	end
	return str
end
if deru "<cy:16><cy:31><cy:15>" ~= "àáâ" then error("test failed - deru()") end

return {}
