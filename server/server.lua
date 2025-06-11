local RSGCore = exports['rsg-core']:GetCoreObject()
local PlantsLoaded = false
local CollectedFertilizer = {}
lib.locale()

for k, v in pairs(Config.FarmItems) do
    RSGCore.Functions.CreateUseableItem(v.seed, function(source)
        local src = source
        TriggerClientEvent('qc-farming:client:preplantseed', src, v.planttype, v.hash, v.seed)
    end)
end

---------------------------------------------
-- get plant data
---------------------------------------------
RSGCore.Functions.CreateCallback('qc-farming:server:getplantdata', function(source, cb, plantid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    MySQL.query('SELECT * FROM qc_fplants WHERE plantid = ?', { plantid }, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

-----------------------------------------------------------------------

-- remove seed item
RegisterServerEvent('qc-farming:server:removeitem')
AddEventHandler('qc-farming:server:removeitem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove', amount)
end)

-----------------------------------------------------------------------

-- update plant data
CreateThread(function()
    while true do
        Wait(5000)

        if PlantsLoaded then
            TriggerClientEvent('qc-farming:client:updatePlantData', -1, Config.FarmPlants)
        end
    end
end)

CreateThread(function()
    TriggerEvent('qc-farming:server:getPlants')
    PlantsLoaded = true
end)

RegisterServerEvent('qc-farming:server:savePlant')
AddEventHandler('qc-farming:server:savePlant', function(data, plantId, citizenid)
    local datas = json.encode(data)

    MySQL.Async.execute('INSERT INTO qc_fplants (properties, plantid, citizenid) VALUES (@properties, @plantid, @citizenid)',
    {
        ['@properties'] = datas,
        ['@plantid'] = plantId,
        ['@citizenid'] = citizenid
    })
end)

-- plant seed
RegisterServerEvent('qc-farming:server:plantnewseed')
AddEventHandler('qc-farming:server:plantnewseed', function(outputitem, prophash, position, heading)
    local src = source
    local plantId = math.random(111111, 999999)
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    local SeedData =
    {
        id = plantId,
        planttype = outputitem,
        x = position.x,
        y = position.y,
        z = position.z,
        h = heading,
        hunger = Config.StartingHunger,
        thirst = Config.StartingThirst,
        growth = 0.0,
        quality = 100.0,
        grace = true,
        hash = prophash,
        beingHarvested = false,
        planter = Player.PlayerData.citizenid,
        planttime = os.time()
    }

    local PlantCount = 0

    for _, v in pairs(Config.FarmPlants) do
        if v.planter == Player.PlayerData.citizenid then
            PlantCount = PlantCount + 1
        end
    end

    if PlantCount >= Config.MaxPlantCount then
        TriggerClientEvent('qc-farming:Notify', '~#E4080A~'..locale('error'), locale('you_already_have_plants_down'), 2000) --title, text, time
    else
        table.insert(Config.FarmPlants, SeedData)
        TriggerEvent('qc-farming:server:savePlant', SeedData, plantId, citizenid)
        TriggerEvent('qc-farming:server:updatePlants')
    end
end)

-- check plant
RegisterServerEvent('qc-farming:server:plantHasBeenHarvested')
AddEventHandler('qc-farming:server:plantHasBeenHarvested', function(plantId)
    for _, v in pairs(Config.FarmPlants) do
        if v.id == plantId then
            v.beingHarvested = true
        end
    end
    TriggerEvent('qc-farming:server:updatePlants')
end)

-- distory plant (police)
RegisterServerEvent('qc-farming:server:destroyPlant')
AddEventHandler('qc-farming:server:destroyPlant', function(plantId)
    local src = source

    for k, v in pairs(Config.FarmPlants) do
        if v.id == plantId then
            table.remove(Config.FarmPlants, k)
        end
    end

    TriggerClientEvent('qc-farming:client:removePlantObject', -1, plantId)
    TriggerEvent('qc-farming:server:PlantRemoved', plantId)
    TriggerEvent('qc-farming:server:updatePlants')
    TriggerClientEvent('qc-farming:Notify', '~#7DDA58~'..locale('success'), locale('you_distroyed_the_plant'), 2000) --title, text, time
end)

-- harvest plant and give reward
RegisterServerEvent('qc-farming:server:harvestPlant')
AddEventHandler('qc-farming:server:harvestPlant', function(plantId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local poorAmount = 0
    local goodAmount = 0
    local exellentAmount = 0
    local poorQuality = false
    local goodQuality = false
    local exellentQuality = false
    local hasFound = false
    local label = nil
    local item = nil

    for k, v in pairs(Config.FarmPlants) do
        if v.id == plantId then
            for y = 1, #Config.FarmItems do
                if v.planttype == Config.FarmItems[y].planttype then
                    label = Config.FarmItems[y].label
                    item = Config.FarmItems[y].item
                    poorAmount = math.random(Config.FarmItems[y].poorRewardMin, Config.FarmItems[y].poorRewardMax)
                    goodAmount = math.random(Config.FarmItems[y].goodRewardMin, Config.FarmItems[y].goodRewardMax)
                    exellentAmount = math.random(Config.FarmItems[y].exellentRewardMin, Config.FarmItems[y].exellentRewardMax)
                    local quality = math.ceil(v.quality)
                    hasFound = true

                    table.remove(Config.FarmPlants, k)

                    if quality > 0 and quality <= 25 then -- Poor
                        poorQuality = true
                    elseif quality >= 25 and quality <= 75 then -- Good
                        goodQuality = true
                    elseif quality >= 75 then -- Excellent
                        exellentQuality = true
                    end
                end
            end
        end
    end

    -- give rewards
    if not hasFound then return end

    if poorQuality then
        Player.Functions.AddItem(item, poorAmount)
         TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'add', poorAmount)
        TriggerClientEvent('qc-farming:Notify', '~#7DDA58~'..locale('success'), locale('you_harvested_poorly').. poorAmount, 2000) --title, text, time
    elseif goodQuality then
        Player.Functions.AddItem(item, goodAmount)
         TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'add', goodAmount)
        TriggerClientEvent('qc-farming:Notify', '~#7DDA58~'..locale('success'), locale('you_harvested_well').. goodAmount, 2000) --title, text, time
    elseif exellentQuality then
        Player.Functions.AddItem(item, exellentAmount)
         TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'add', exellentAmount)
        TriggerClientEvent('qc-farming:Notify', '~#7DDA58~'..locale('success'), locale('you_harvested_perfectly') .. exellentAmount, 2000) --title, text, time
    else
        print('something went wrong!')
    end

    TriggerClientEvent('qc-farming:client:removePlantObject', -1, plantId)
    TriggerEvent('qc-farming:server:PlantRemoved', plantId)
    TriggerEvent('qc-farming:server:updatePlants')
end)

RegisterServerEvent('qc-farming:server:updatePlants')
AddEventHandler('qc-farming:server:updatePlants', function()
    local src = source
    TriggerClientEvent('qc-farming:client:updatePlantData', -1, Config.FarmPlants)
end)

-- water plant
RegisterServerEvent('qc-farming:server:waterPlant')
AddEventHandler('qc-farming:server:waterPlant', function(plantId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    for k, v in pairs(Config.FarmPlants) do
        if v.id == plantId then
            Config.FarmPlants[k].thirst = Config.FarmPlants[k].thirst + Config.ThirstIncrease
            if Config.FarmPlants[k].thirst > 100.0 then
                Config.FarmPlants[k].thirst = 100.0
            end
        end
    end

    if not Player.Functions.RemoveItem('fullbucket', 1) then return end

    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items['fullbucket'], 'remove', 1)
    Player.Functions.AddItem('bucket', 1) --add empty bucket
    TriggerEvent('qc-farming:server:updatePlants')
end)

-- feed plant
RegisterServerEvent('qc-farming:server:feedPlant')
AddEventHandler('qc-farming:server:feedPlant', function(plantId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    for k, v in pairs(Config.FarmPlants) do
        if v.id == plantId then
            Config.FarmPlants[k].hunger = Config.FarmPlants[k].hunger + Config.HungerIncrease

            if Config.FarmPlants[k].hunger > 100.0 then
                Config.FarmPlants[k].hunger = 100.0
            end
        end
    end

    if not Player.Functions.RemoveItem('fertilizer', 1) then return end

    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items['fertilizer'], 'remove', 1)
    TriggerEvent('qc-farming:server:updatePlants')
end)

-- update plant
RegisterServerEvent('qc-farming:server:updateFarmPlants')
AddEventHandler('qc-farming:server:updateFarmPlants', function(id, data)
    local result = MySQL.query.await('SELECT * FROM qc_fplants WHERE plantid = @plantid', { ['@plantid'] = id })

    if not result[1] then return end

    local newData = json.encode(data)
    MySQL.Async.execute('UPDATE qc_fplants SET properties = @properties WHERE plantid = @id', { ['@properties'] = newData, ['@id'] = id })
end)

-- remove plant
RegisterServerEvent('qc-farming:server:PlantRemoved')
AddEventHandler('qc-farming:server:PlantRemoved', function(plantId)
    local result = MySQL.query.await('SELECT * FROM qc_fplants')

    if not result then return end

    for i = 1, #result do
        local plantData = json.decode(result[i].properties)

        if plantData.id == plantId then
            MySQL.Async.execute('DELETE FROM qc_fplants WHERE id = @id', { ['@id'] = result[i].id })
            for k, v in pairs(Config.FarmPlants) do
                if v.id == plantId then
                    table.remove(Config.FarmPlants, k)
                end
            end
        end
    end
end)

-- get plant
RegisterServerEvent('qc-farming:server:getPlants')
AddEventHandler('qc-farming:server:getPlants', function()
    local result = MySQL.query.await('SELECT * FROM qc_fplants')

    if not result[1] then return end

    for i = 1, #result do
        local plantData = json.decode(result[i].properties)
        print('loading '..plantData.planttype..' plant with ID: '..plantData.id)
        table.insert(Config.FarmPlants, plantData)
    end
end)

-- give farmer collected water/fertilizer
RegisterServerEvent('qc-farming:server:giveitem')
AddEventHandler('qc-farming:server:giveitem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, amount)
    if item == 'fullbucket' then
        Player.Functions.RemoveItem('bucket', 1)
    end
     TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'add', amount)
end)

-- We remove the light effect (if used) and inform all clients
RegisterNetEvent('qc-farming:server:deletefertilizer')
AddEventHandler('qc-farming:server:deletefertilizer', function(coords)
    -- We remove an object from the server (if any)
    for i = 1, #CollectedFertilizer do
        local fertilizer = CollectedFertilizer[i]
        if fertilizer == coords then
            table.remove(CollectedFertilizer, i)
            -- We inform all clients to remove the facility
            TriggerClientEvent('qc-farming:client:deletefertilizer', -1, coords)
            break
        end
    end
end)

-- A function checking whether the fertilizer is already collected
RegisterNetEvent('qc-farming:server:collectedfertilizer')
AddEventHandler('qc-farming:server:collectedfertilizer', function(coords)
    local exists = false

    for i = 1, #CollectedFertilizer do
        local fertilizer = CollectedFertilizer[i]
        if fertilizer == coords then
            exists = true
            break
        end
    end

    if not exists then
        CollectedFertilizer[#CollectedFertilizer + 1] = coords
    end
end)

RSGCore.Functions.CreateCallback('qc-farming:server:checkcollectedfertilizer', function(source, cb, coords)
    local exists = false
    for i = 1, #CollectedFertilizer do
        local fertilizer = CollectedFertilizer[i]

        if fertilizer == coords then
            exists = true
            break
        end
    end
    cb(exists)
end)


-- plant timer
CreateThread(function()
    while true do
        Wait(Config.GrowthTimer)

        for i = 1, #Config.FarmPlants do
            if Config.FarmPlants[i].growth < 100 then
                if Config.FarmPlants[i].grace then
                    Config.FarmPlants[i].grace = false
                else
                    Config.FarmPlants[i].thirst = Config.FarmPlants[i].thirst - 1
                    Config.FarmPlants[i].hunger = Config.FarmPlants[i].hunger - 1
                    Config.FarmPlants[i].growth = Config.FarmPlants[i].growth + 1

                    if Config.FarmPlants[i].growth > 100 then
                        Config.FarmPlants[i].growth = 100
                    end

                    if Config.FarmPlants[i].hunger < 0 then
                        Config.FarmPlants[i].hunger = 0
                    end

                    if Config.FarmPlants[i].thirst < 0 then
                        Config.FarmPlants[i].thirst = 0
                    end

                    if Config.FarmPlants[i].quality < 25 then
                        Config.FarmPlants[i].quality = 25
                    end

                    if Config.FarmPlants[i].thirst < 75 or Config.FarmPlants[i].hunger < 75 then
                        Config.FarmPlants[i].quality = Config.FarmPlants[i].quality - 1
                    end
                end
            else
                local untildead = Config.FarmPlants[i].planttime + Config.DeadPlantTime
                local currenttime = os.time()

                if currenttime > untildead then
                    local deadid = Config.FarmPlants[i].id

                    print('Removing Dead Plant with ID '..deadid)

                    TriggerEvent('qc-farming:server:PlantRemoved', deadid)
                end
            end

            TriggerEvent('qc-farming:server:updateFarmPlants', Config.FarmPlants[i].id, Config.FarmPlants[i])
        end

        TriggerEvent('qc-farming:server:updatePlants')
    end
end)

------------------------------------------------------------------------------------------------------


local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/Quantum-Projects-RedM/QC-VersionCheckers/master/QC-Farming.txt', function(err, newestVersion, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
        local resourceName = GetCurrentResourceName()
        local discordLink = GetResourceMetadata(resourceName, 'quantum_discord')

        if not newestVersion then
            print("\n^1[Quantum Projects]^7 Unable to perform version check.\n")
            return
        end

        local isLatestVersion = newestVersion:gsub("%s+", "") == currentVersion:gsub("%s+", "")
        if isLatestVersion then
            print(("^3[Quantum Projects]^7: You are running the latest version of ^2%s^7 (^2%s^7)."):format(resourceName, currentVersion))
        else
            print("\n^6========================================^7")
            print("^3[Quantum Projects]^7 Version Checker")
            print("")
            print(("^3Version Check^7:\n ^2Current^7: %s\n ^2Latest^7: %s\n"):format(currentVersion, newestVersion))
            print(("^1You are running an outdated version of %s.\n^6Visit Discord for News: ^4%s^7\n"):format(resourceName, discordLink))
            print("^6========================================^7\n")
        end
    end)
end

CheckVersion()
