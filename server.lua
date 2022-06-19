local sharedItems = exports['qbr-core']:GetItems()

local bankVaultDoors = {																		--[doorhash] = {doorhash, doormodel hash, doormodel, x, y, z}
	{x = -817.61, y = -1273.89, z = 42.64, doorhash = 1462330364, locked = true, objYaw = 92.50 }, -- ["blackwater"] = 1692167 p_door_bla_bankvault [1462330364] = {1462330364,570973667,"p_door_bla_bankvault",-817.78656005859,-1274.3852539063,42.662132263184},
	{x = -307.12, y = 766.50, z = 117.76, doorhash = 576950805, locked = true, objYaw = -170.0 }, -- ["valentine"] = 7853575 p_door_val_bankvault [576950805] = {576950805,-765914358,"p_door_val_bankvault",-307.75375366211,766.34899902344,117.7015914917},
	{x = 1282.86, y = -1308.82, z = 76.04, doorhash = 3483244267, locked = true, objYaw = 230.05541992188 }, -- ["rhodes"] = 3120901 p_door_val_bankvault [3483244267] = {3483244267,-765914358,"p_door_val_bankvault",1282.5363769531,-1309.3159179688,76.036422729492},
	{x = 2643.88, y = -1300.48, z = 51.25, doorhash = 1751238140, locked = true, objYaw = 159.90571594238 }, -- ["stdenis"] = 5589766 p_door_val_bankvault02x [1751238140] = {1751238140,-788527275,"p_door_val_bankvault02x",2643.3005371094,-1300.4267578125,51.255825042725},
	{x = 2934.67, y = 1284.58, z = 43.66, doorhash = 1321590180, locked = true, objYaw = -21.96 }, -- ["annesburg"] = [1321590180] = {1321590180,-765914358,"p_door_val_bankvault",2935.2658691406,1284.44140625,43.64567565918},
	
}

local safeLocs = {
		{x = 2936.32, y = 1287.77, z = 43.65, opened = false}, -- annesburg
		{x = 2935.37, y = 1288.19, z = 43.65, opened = false}, -- annesburg
		{x = -309.47, y = 764.90, z = 117.70, opened = false}, -- valentine
		{x = -309.33, y = 763.79, z = 117.70, opened = false}, -- valentine
		{x = -309.20, y = 762.75, z = 117.70, opened = false}, -- valentine
		{x = 1288.37, y = -1313.24, z = 76.04, opened = false}, -- rhodes
		{x = 1288.69, y = -1314.17, z = 76.04, opened = false}, -- rhodes
		{x = 1288.00, y = -1314.98, z = 76.04, opened = false}, -- rhodes
		{x = 1287.30, y = -1315.83, z = 76.04, opened = false}, -- rhodes
		{x = 1286.29, y = -1315.66, z = 76.04, opened = false}, -- rhodes
		{x = -821.35, y = -1274.67, z = 42.64, opened = false}, -- blackwater
		{x = -821.35, y = -1273.54, z = 42.73, opened = false}, -- blackwater
		{x = 2645.57, y = -1305.10, z = 51.25, opened = false}, -- stdenis
		{x = 2645.75, y = -1306.28, z = 51.25, opened = false}, -- stdenis
		{x = 2643.40, y = -1307.35, z = 51.25, opened = false}, -- stdenis
		{x = 2642.29, y = -1305.64, z = 51.25, opened = false}, -- stdenis
		{x = 2641.57, y = -1304.15, z = 51.25, opened = false}, -- stdenis
		{x = 2640.98, y = -1302.69, z = 51.25, opened = false}, -- stdenis
		
}

local worldSafes = {}

local VaultItems = {
	{item = "bankbond", name = "Bank Bond", amountToGive = math.random(1,4)},
    {item = "goldbar", name = "Goldbar", amountToGive = math.random(1,2)},
    {item = "diamond", name = "diamond", amountToGive = math.random(1,4)},
	
}

local WorldSafeItems = {
    {item = "goldbar", name = "Goldbar", amountToGive = math.random(1,2)},
    {item = "diamond", name = "diamond", amountToGive = math.random(1,4)},
	
}


---- Usable items 

exports['qbr-core']:CreateUseableItem("dynamite", function(source, item)
	local dynamite = item
	local _source = source
	local User = exports['qbr-core']:GetPlayer(_source)	
	User.Functions.RemoveItem("dynamite", 1, item.slot)    		
	TriggerClientEvent('dag_robbery:client:placeDynamite', _source)

end)

exports['qbr-core']:CreateUseableItem("lockpick", function(source, item)
	local _source = source
	local User = exports['qbr-core']:GetPlayer(_source)							
	TriggerClientEvent('dag_robbery:client:useLockPick', _source)
end)


-- functions

function WorldSafeLoot(source)
    local Loot = {}
    for k, v in pairs(WorldSafeItems) do 
        table.insert(Loot,v.item)
    end
    if Loot[1] ~= nil then
        local value = math.random(1,#Loot)
        local picked = Loot[value]
        return picked
    end
end

function LootToGive(source)
	local LootsToGive = {}
	for k,v in pairs(VaultItems) do
		table.insert(LootsToGive,v.item)
	end

	if LootsToGive[1] ~= nil then
		local value = math.random(1,#LootsToGive)
		local picked = LootsToGive[value]
		return picked
	end
end

-- events
RegisterServerEvent('dag_robbery:server:setup')
AddEventHandler('dag_robbery:server:setup', function()
	TriggerClientEvent('dag_robbery:client:setup', source, bankVaultDoors, safeLocs, worldSafes)
end)

RegisterServerEvent('dag_robbery:server:UpdateOpened')
AddEventHandler('dag_robbery:server:UpdateOpened', function(safeObject)
	safeLocs[safeObject].opened = true
	TriggerClientEvent('dag_robbery:client:updateOpenedList', -1, safeObject)
end)

RegisterServerEvent('dag_robbery:server:updateState')
AddEventHandler('dag_robbery:server:updateState', function(doorID, state, cb)
    local src = source
	local Player = exports['qbr-core']:GetPlayer(src)
	if type(doorID) ~= 'number' then
			return
	end	

	bankVaultDoors[doorID].locked = state
	TriggerClientEvent('dag_robbery:client:setState', -1, doorID, state)
end)

RegisterServerEvent('dag_robbery:server:robberycomplete')
AddEventHandler('dag_robbery:server:robberycomplete', function()
	local src = source
	local FinalLoot = LootToGive(src)
    local User = exports['qbr-core']:GetPlayer(src)
    local chance = math.random(1,100)
    if chance <= 45 then
        for k,v in pairs(VaultItems) do
			if v.item == FinalLoot then
				--User.Functions.RemoveItem("lockpick", 1)
				User.Functions.AddMoney('cash', math.random(50,200), 'safe_robbery')
				User.Functions.AddItem(FinalLoot, v.amountToGive)
				LootsToGive = {}
				TriggerClientEvent('inventory:client:ItemBox', src, sharedItems[v.item], "add")
			end
		end
	else
		User.Functions.AddMoney('cash', math.random(100,500), 'safe_robbery')
    end
end)

RegisterServerEvent('dag_robbery:server:worldSafecomplete')
AddEventHandler('dag_robbery:server:worldSafecomplete', function(loc, object)
	local src = source
	local FinalLoot = WorldSafeLoot(src)
    local User = exports['qbr-core']:GetPlayer(src)
    local chance = math.random(1,100)
	worldSafes[#worldSafes+1] = {obj = object}
    if chance <= 45 then
        for k,v in pairs(WorldSafeItems) do
			if v.item == FinalLoot then
				--User.Functions.RemoveItem("lockpick", 1)
				User.Functions.AddMoney('cash', math.random(1,200), 'safe_robbery')
				User.Functions.AddItem(FinalLoot, v.amountToGive)
				LootsToGive = {}
				TriggerClientEvent('inventory:client:ItemBox', src, sharedItems[v.item], "add")
			end
		end
	else
		User.Functions.AddMoney('cash', math.random(1,500), 'safe_robbery')
    end
end)

RegisterNetEvent('dag_robbery:server:lawAlert')
AddEventHandler('dag_robbery:server:lawAlert', function(alert)
	local alertText = alert or "Suspicious activity reported. Check nearest tip line."
	TriggerClientEvent('dag_robbery:client:lawAlert', -1, alertText)
end)


