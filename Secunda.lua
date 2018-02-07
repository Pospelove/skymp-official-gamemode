-- Secunda.lua
--[[
Copyright (C) 2018, Sirius
All rights reserved.
--]]

class = require "pl/class"
stringx = require "pl/stringx"
pretty = require "pl/pretty"
url = require "pl/url"
tablex = require "pl/tablex"
json = require "json/json"
sha256 = require "sha256/sha256"

dsres = require "data/dsres"

Secunda = {}
Secunda.sName = "Secunda"
Secunda.sVersion = "0.5.3"
Secunda.sAuthor = "Pospelov"

print ""
print("----------------------- " .. Secunda.sName .. " " .. Secunda.sVersion ..  " -----------------------")
print ""
print "Preparing to start"
print ""

function Secunda.ShouldRunTests()
	return "you must"
end

function Secunda.ShouldTestPerfomance()
	return "yes"
end

function Secunda.LoadModules()
	Secunda.tModules = {}
	print "Loading modules ... "

	local iTotalModules = 0

	local LoadModulesFromDir = function(sDir)
		print("Reading directory " .. "'" .. sDir .. "'")
		local sDirFullName = GetCurrentDirectory() .. "/gamemodes/" .. sDir;
		local i = 1
		local iNumLoaded = 0
		local sFileName = "nil"
		while sFileName ~= "" do
			local bSuccess, result = pcall(function()
				return require(sDir .. "/" .. sFileName:gsub(".lua", ""))
			end)
			if bSuccess then
				print("Loaded " .. "'" .. sFileName .. "'")
				table.insert(Secunda.tModules, result)
				iNumLoaded = iNumLoaded + 1
			else
				local sError = result
				local bNoSuchFile = (sError:gsub("no file", "") ~= sError)
				if bNoSuchFile == false then
					print(sError)
					print("Unable to load  " .. "'" .. sFileName .. "'")
				end
			end
			sFileName = GetNthFileInDirectory(sDirFullName, i)
			i = i + 1
		end
		return iNumLoaded
	end

	-- Do not change load order of dirs without reason
	local tDirectories = {
		"SecundaModules",
		"SecundaModules/Utils",
		"SecundaModules/SecundaLibrary", -- Is dependent of Utils
		"SecundaModules/Experimental",
		"SecundaModules/Systems" -- Is dependent of SecundaLibrary
	}
	for i, sDir in ipairs(tDirectories) do
		local iNumModules = LoadModulesFromDir(sDir)
		if iNumModules == 0 then
			print "No modules in directory"
		end
		iTotalModules = iTotalModules + iNumModules
	end
	print("Loaded " .. iTotalModules .. (iTotalModules == 1 and " module" or " modules"))
	print ""
end

function Secunda.GetModules()
	return Secunda.tModules
end

function Secunda.SetMeta()
	local SecundaMeta = {}
	SecundaMeta["__index"] = function(self, sKey)
		local value = rawget(self, sKey)
		if value == nil then
			return function(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
				local bSuccess = true
				local tModules = Secunda.GetModules()
				for i = 1, #tModules do
					local f = tModules[i][sKey]
					if type(f) == "function" then
						bSuccess = f(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) and bSuccess
					end
				end
				return bSuccess
			end
		end
		return value
	end
	setmetatable(Secunda, SecundaMeta)
end

function Secunda.Hook()
	local tStandard = {
		"OnServerInit",
		"OnServerExit",
		"OnPlayerConnect",
		"OnPlayerDisconnect",
		"OnPlayerSpawn",
		"OnPlayerUpdate",
		"OnPlayerDying",
		"OnPlayerDeath",
		"OnPlayerChatInput",
		"OnPlayerDialogResponse",
		"OnPlayerCharacterCreated",
		"OnPlayerActivateObject",
		"OnPlayerActivatePlayer",
		"OnPlayerHitObject",
		"OnPlayerHitPlayer",
		"OnPlayerDataSearchResult",
		"OnWayPointCreate",
		"OnPlayerLearnEffect"
	}
	for i = 1, #tStandard do
		_G[tStandard[i]] = Secunda[tStandard[i]]
	end
end

Secunda.LoadModules()
Secunda.SetMeta()
Secunda.Hook()

if Secunda.ShouldRunTests() then
	SetTimer(1, function()
		print ""
		print "Running tests..."

		Secunda.RunTests()
		print "Done"
	end)
	if Secunda.ShouldTestPerfomance() then
		SetTimer(1000, function()
			print ""
			print "Testing perfomance..."
			Secunda.TestPerfomance()
			print "Done"
		end)
	end
end

SetTimer(1000, function()
	print ""
	print "Secunda is still alive"
end)
