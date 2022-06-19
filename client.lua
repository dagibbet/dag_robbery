local safe = { 
"P_BANK_SAFE_R",
"S_VAULT_SML_R_VAL_BENT01X", 
"S_VAULT_MED_R_VAL_BENT01X",
"S_VAULT_SML_L_VAL01X",
"P_BANK_SAFE_MED_L", 
"P_GEN_SAFE01", 
"S_SAFE03X", 
"S_SAFE02X", 
"S_SAFE01X", 
"P_SAFETYDEPOSITBOX01X", 
"P_SAFENBD02X", 
"P_SAFENBD01X", 
"P_SAFEBLA01X", 
"P_SAFE01",
"P_SAFE_SER", 
"P_GEN_SAFE02", 
"P_GEN_SAFE01", 
"P_DOORSAFE_H", 
"P_SAINTDENISTOP01X", 
"P_DEPOSITBOXSET01X", 
"P_DEPOSITBOXGROUP02X", 
"P_DEPOSITBOXGROUP01X", 
"P_TNT_TRAINROBBERY_01X", 
"P_CS_TRAINCRATETNT01X", 
"P_CS_TRAINCRATETNT02X",
"S_COACHROBBERY01BX", 
"S_COACHROBBERY01X", 
"S_DOORROBBERY01X", 
"S_DOORROBBERY02X", 
"S_DOORROBBERY03X", 
"S_DOORROBBERY04X", 
"S_DOORROBBERY05X", 
"S_DOORROBBERY06X", 
"S_DOORROBBERY07X", 
"S_DOORROBBERY08X", 
"S_LOOTABLEBEDCHEST_A", 
"S_LOOTABLEBEDCHEST_B", 
"S_LOOTABLEBEDCHEST_C", 
"S_LOOTABLEBEDCHEST_D", 
"S_LOOTABLEBEDCHEST", 
"S_RUSTEDCHEST01X",
"S_MISCCHEST_LOOT_D", 
"P_ADL_CHESTLRG01X", 
"P_CHEST_LRG", 
"P_CHEST_MED", 
"P_CHEST01X", 
"P_CHEST02X", 
"P_CHEST03X", 
"P_SDTHEATER_CHEST01X", 
"P_WEDDINGCHEST01X", 
"S_ARTHURCHEST01X", 
"S_CRAFTEDARTHURCHEST01X", 
"S_CVAN_CHEST01", 
"S_CVAN_CHEST02", 
"S_LOOTABLEBIGNARROWMISCCHEST", 
"S_LOOTABLEBIGMISCCHEST", 
"S_LOOTABLEBIGBLUECHEST03X", 
"S_LOOTABLEBIGBLUECHEST02X", 
"S_LOOTABLEBIGBLUECHEST01X", 
"p_trunk01x",
"sr_start",
}

local isRobbing = false

local bankVaultDoors = {}
local safeLocs = {}

local worldSafes = {}

 -- Inits 
Citizen.CreateThread(function()
	while true do
		for _,doorID in pairs(bankVaultDoors) do
			if doorID.doors then
				for k,v in pairs(doorID.doors) do
					if not v.object or not DoesEntityExist(v.object) then
						local shapeTest = StartShapeTestBox(v.objCoords, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, true, 16)
						local rtnVal, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTest)
						v.object = entityHit
					end
				end
			else
				if not doorID.object or not DoesEntityExist(doorID.object) then
					local shapeTest = StartShapeTestBox(vector3(doorID.x, doorID.y, doorID.z), 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, true, 16)
					local rtnVal, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTest)
					doorID.object = entityHit
				end
			end
			if doorID.locked then
				if Citizen.InvokeNative(0x160AA1B32F6139B8, doorID.doorhash) ~= 3 then
					Citizen.InvokeNative(0xD99229FE93B46286, doorID.doorhash,1,1,0,0,0,0)
					Citizen.InvokeNative(0x6BAB9442830C7F53, doorID.doorhash, 3)
				end
				local current = GetEntityRotation(doorID.object).z - doorID.objYaw
				if doorID.objYaw and current > 0.5 or current < -0.5 then
					SetEntityRotation(doorID.object, 0.0, 0.0, doorID.objYaw, 2, true)
				end
				FreezeEntityPosition(doorID.object,true)
			else
				if Citizen.InvokeNative(0x160AA1B32F6139B8, doorID.doorhash) ~= false then
					Citizen.InvokeNative(0xD99229FE93B46286, doorID.doorhash,1,1,0,0,0,0)
					Citizen.InvokeNative(0x6BAB9442830C7F53, doorID.doorhash, 0)
				end
				FreezeEntityPosition(doorID.object,false)
			end
		end

		Citizen.Wait(1000)
	end
end)


AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	TriggerServerEvent('dag_robbery:server:setup')
end)

RegisterNetEvent('dag_robbery:client:setup')
AddEventHandler('dag_robbery:client:setup', function(dlocs, slocs, wsafes)
	bankVaultDoors = dlocs
	safeLocs = slocs
	worldSafes = wsafes
end)

--- functions

function GetCurrentTownName()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local town_hash = Citizen.InvokeNative(0x43AD8FC02B429D33, pedCoords ,1)
    if town_hash == GetHashKey("Valentine") then
        return "Valentine"
    elseif town_hash == GetHashKey("Blackwater") then
        return "Blackwater"
    elseif town_hash == GetHashKey("StDenis") then
        return "Saint Denis"
	elseif town_hash == GetHashKey("Rhodes") then
        return "Rhodes"
	elseif town_hash == GetHashKey("Annesburg") then
        return "Annesburg"
    else
        return ""
    end
end

-- Set state for a door
RegisterNetEvent('dag_robbery:client:setState')
AddEventHandler('dag_robbery:client:setState', function(doorID, state)
	bankVaultDoors[doorID].locked = state
end)

RegisterNetEvent('dag_robbery:client:useLockPick')
AddEventHandler('dag_robbery:client:useLockPick', function()
	local opened = false
	local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
	for key, value in pairs(safe) do
		local safe = DoesObjectOfTypeExistAtCoords(x, y, z, 1.0, GetHashKey(value), true)		
		if safe then			
			for i, sobj in pairs(safeLocs) do
				local dist = GetDistanceBetweenCoords(x, y, z, sobj.x, sobj.y, sobj.z, 0)
				if dist < 0.4 then 
					isRobbing = true
					opened = sobj.opened
					TriggerServerEvent('dag_robbery:server:UpdateOpened', i)
					if opened == false then	-- minigame would go here			
						TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), -1, true, false, false, false)
						exports['qbr-core']:Progressbar("safe", "Opening..", RobberyConfig.SafeOpenTime, false, true, {
							disableMovement = true,
							disableCarMovement = false,
							disableMouse = false,
							disableCombat = true,
						}, {}, {}, {}, function() -- Done
							TriggerServerEvent("dag_robbery:server:robberycomplete")				
						end)
					ClearPedTasks(PlayerPedId())
					else
						exports['qbr-core']:Notify(9, 'Already been opened.', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
					end
				end
			end
			if isRobbing == false then  -- world safe (non bank vault)
				local canOpen = true
				
				local entityHit = GetClosestObjectOfType(x, y, z, 2.0, GetHashKey(value), false)
				
				for i, sobj in pairs(worldSafes) do	
					if sobj.obj == entityHit then
						canOpen = false
					end
				end
				if canOpen then 
					TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), -1, true, false, false, false)
					-- minigame would go here	
					exports["memorygame"]:thermiteminigame(12, 3, 3, 10, --numRight, numWrong, displayTime, allowedTime
						function() -- success
							exports['qbr-core']:Progressbar("safe", "Opening..", RobberyConfig.SafeOpenTime, false, true, {
								disableMovement = true,
								disableCarMovement = false,
								disableMouse = false,
								disableCombat = true,
							}, {}, {}, {}, function() -- Done
								cords = GetEntityCoords(PlayerPedId())
								worldSafes[#worldSafes+1] = {obj = entityHit}
								TriggerServerEvent("dag_robbery:server:worldSafecomplete", vector3(x,y,z), entityHit)
								ClearPedTasks(PlayerPedId())								
							end)
						end,
						function() -- failure
							TriggerServerEvent('qbr-doorlock:removeitem', "lockpick")
							ClearPedTasks(PlayerPedId())
					end)
					-- end minigame
					ClearPedTasks(PlayerPedId())
				else
						exports['qbr-core']:Notify(9, 'Its empty.', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
				end
			end
		end
	end
	if isRobbing == false then
		-- door check
		
	end
	isRobbing = false
end)

RegisterNetEvent('dag_robbery:client:updateOpenedList')
AddEventHandler('dag_robbery:client:updateOpenedList', function(safeObject)
	safeLocs[safeObject].opened = true
end)

RegisterNetEvent('dag_robbery:client:placeDynamite')
AddEventHandler('dag_robbery:client:placeDynamite', function()
	local player = PlayerPedId()
    local Coords = GetEntityCoords(player)
	local nearVaultDoor = false
	for k,loc in pairs(bankVaultDoors) do
		local dist = GetDistanceBetweenCoords(loc.x, loc.y, loc.z, Coords.x, Coords.y, Coords.z, 0)		
		if 1.0 > dist and isRobbing == false then
			nearVaultDoor = true
			isRobbing = true
			BlowDynamite(loc.x, loc.y, loc.z, loc, k)
		end
	end
	if nearVaultDoor == false then
		BlowDynamite(Coords.x, Coords.y, Coords.z, -1, -1)
	end
end)


function BlowDynamite(dx, dy, dz, doorhash, k)
			
	local playerPed = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
	itemDynamiteprop = CreateObject(GetHashKey('p_dynamite01x'), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(itemDynamiteprop, playerPed, GetPedBoneIndex(playerPed, 54565), 0.06, 0.0, 0.06, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
	SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"),true)
	Citizen.Wait(700)
	TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), RobberyConfig.DynamitePlaceTime, true, false, false, false)
			
	exports['qbr-core']:Progressbar("dynamite", "Placing Dynamite", RobberyConfig.DynamitePlaceTime, false, true, {
				disableMovement = true,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = true,
			}, {}, {}, {}, function() -- Done
				DetachEntity(itemDynamiteprop)
				TriggerEvent('dag_robbery:client:startFuse', dx, dy, dz, doorhash, k )
	end)		
	ClearPedTasks(playerPed)
		
end

RegisterNetEvent('dag_robbery:client:startFuse')
AddEventHandler('dag_robbery:client:startFuse', function(dx, dy, dz, doorhash, k)
	exports['qbr-core']:Progressbar("dynamite", "Fuse Burning..", RobberyConfig.DynamiteFuseTime, false, true, {
		disableMovement = false,
		disableCarMovement = false,
		disableMouse = false,
		disableCombat = false,
	}, {}, {}, {}, function() -- Done
		AddExplosion(dx, dy, dz, 25 , 5000.0 ,true , false , 27)						
		if doorhash ~= -1 then -- bank vault door
			TriggerServerEvent('dag_robbery:server:updateState', k, false, function(cb) end) -- unlock vault door
			-- Alert system - Replace if you use something different
			TriggerServerEvent('dag_robbery:server:lawAlert', "Explosion reported, check nearest tip line for info")
			local data = {}
			local townname = GetCurrentTownName()
			data.recipient = "ANON"
			data.sender = "Citizen"
			data.subject = "Bank Robbery"
			data.message = "Bank Robbery in "..townname
			data.postoffice = townname
			data.system = true
			TriggerServerEvent('scf_telegram:SendTelegram', data)
			-- end alert system

		end
	end)
end)

RegisterNetEvent('dag_robbery:client:lawAlert')
AddEventHandler('dag_robbery:client:lawAlert', function(alert)
	local job = exports['qbr-core']:GetPlayerData().job.name
	
	if job == RobberyConfig.LawmanJob then
		exports['qbr-core']:Notify(9, alert, 5000, 0, 'inventory_items', 'provision_sheriff_star', 'COLOR_WHITE')
	end
end)
