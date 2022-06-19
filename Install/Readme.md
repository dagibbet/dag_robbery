---------------- Dependencies
	- objectloader - https://github.com/dagibbet/objectloader (allows for loading xml map objects)
	- memorygame - https://github.com/SagginChairLLC/memorygame (simple memory based minigame)
	- scf_telegram - https://github.com/dagibbet/scf_telegram (telegram system)
	- dag_crafting - https://github.com/dagibbet/dag_crafting (to make dynamite) - optional use of other crafting system instead if wanted

---------------- QBR-DOORLOCK (allows lockpicking all locked doors)
---- add to qbr-doorlock/client/main.lua

local doorpickid = 0

RegisterNetEvent('dag_robbery:client:useLockPick')
AddEventHandler('dag_robbery:client:useLockPick', function(item)
	local playerCoords, letSleep = GetEntityCoords(PlayerPedId()), true
	for k,doorID in ipairs(Config.DoorList) do
		local distance = #(playerCoords - doorID.textCoords)

		local maxDistance, displayText = 1.25, Lang:t("info.unlocked")

		if doorID.distance then
			maxDistance = doorID.distance
		end
		if distance < maxDistance then
			if distance < 1.75 then
				doorpickid = k
				exports["memorygame"]:thermiteminigame(10, 3, 3, 10, --numRight, numWrong, displayTime, allowedTime
					function() -- success
						lockpickFinish(true)
					end,
					function() -- failure
						lockpickFinish(false)
				end)
			end
		end
	end
end)


function lockpickFinish(success)
	if success then
		TriggerServerEvent("qbr-doorlock:updatedoorsv", doorpickid, false)	
	else
		TriggerServerEvent('qbr-doorlock:removeitem', "lockpick")        	
	end
end
----------------
---- add to qbr-doorlock/server/main.lua

local sharedItems = exports['qbr-core']:GetItems()

RegisterServerEvent('qbr-doorlock:removeitem')
AddEventHandler('qbr-doorlock:removeitem', function(item)
	local src = source
	local User = exports['qbr-core']:GetPlayer(src)
	User.Functions.RemoveItem(item, 1)
	TriggerClientEvent('inventory:client:ItemBox', src, sharedItems[item], "remove")
end)

----------------
---- edits to qbr-doorlock/config.lua
	- remove vault doors from the qbr-doorlock config
		-- example: 
		-- {
		-- authorizedJobs = { 'police' }, -- Valentine Vault Door
		-- doorid = 576950805,
		-- objCoords  = vector3(-307.76, 766.34, 117.7),
		-- textCoords  = vector3(-306.60, 766.65, 118.70),
		-- objYaw = -170.0,
		-- locked = true,
		-- distance = 3.0
		-- },
	- search for 1462330364 and comment out the block - if exists 
	- search for 576950805 and comment out the block - if exists
	- search for 3483244267 and comment out the block - if exists
	- search for 1751238140 and comment out the block - if exists
	- search for 1321590180 and comment out the block - if exists
	
	

---------------- 

---------------- scf_telegram/server.lua
---- replace (around line 100)
	
	TriggerClientEvent('QBCore:Notify', _source, 9,  "Telegram has been sent free of charge.", 3000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
	
---- with
	
	if data.system == nil then 
		TriggerClientEvent('QBCore:Notify', _source, 9,  "Telegram has been sent free of charge.", 3000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
	end


----------------


