local RSGCore = exports['rsg-core']:GetCoreObject()
local isBusy = false
local SpawnedPlants = {}
local HarvestedPlants = {}
local canHarvest = true
lib.locale()
---------------------------------------------
-- spawn plants and setup target
---------------------------------------------
CreateThread(function()
    while true do
        Wait(150)
        local pos = GetEntityCoords(cache.ped)
        local InRange = false
        for i = 1, #Config.FarmPlants do
            local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.FarmPlants[i].x, Config.FarmPlants[i].y, Config.FarmPlants[i].z, true)
            if dist >= 50.0 then goto continue end
            local hasSpawned = false
            InRange = true
            for z = 1, #SpawnedPlants do
                local p = SpawnedPlants[z]

                if p.id == Config.FarmPlants[i].id then
                    hasSpawned = true
                end
            end
            if hasSpawned then goto continue end
            local planthash = Config.FarmPlants[i].hash
            local phash = GetHashKey(planthash)
            local data = {}
            while not HasModelLoaded(phash) do
                Wait(10)
                RequestModel(phash)
            end
            RequestModel(phash)
            data.id = Config.FarmPlants[i].id
            data.obj = CreateObject(phash, Config.FarmPlants[i].x, Config.FarmPlants[i].y, Config.FarmPlants[i].z, false, false, false)
            SetEntityHeading(data.obj, Config.FarmPlants[i].h)
            SetEntityAsMissionEntity(data.obj, true)
            PlaceObjectOnGroundProperly(data.obj)
            Wait(1000)
            FreezeEntityPosition(data.obj, true)
            SetModelAsNoLongerNeeded(data.obj)
            local veg_modifier_sphere = 0
                if veg_modifier_sphere == nil or veg_modifier_sphere == 0 then
                    local veg_radius = 3.0
                    local veg_Flags =  1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256
                    local veg_ModType = 1
                    veg_modifier_sphere = Citizen.InvokeNative(0xFA50F79257745E74, Config.FarmPlants[i].x, Config.FarmPlants[i].y, Config.FarmPlants[i].z, veg_radius, veg_ModType, veg_Flags, 0)
                else
                    Citizen.InvokeNative(0x9CF1836C03FB67A2, Citizen.PointerValueIntInitialized(veg_modifier_sphere), 0)
                    veg_modifier_sphere = 0
                end
            SpawnedPlants[#SpawnedPlants + 1] = data
            hasSpawned = false
            -- create target for the entity
            exports['rsg-target']:AddTargetEntity(data.obj, {
                options = {
                    {
                        type = 'client',
                        event = 'qc-farming:client:plantmenu',
                        icon = 'fa-solid fa-seedling',
                        label = 'Status of the plant',
                        action = function()
                            TriggerEvent('qc-farming:client:plantmenu', data.id)
                        end
                    },
                },
                distance = 3
            })
            -- end of target

            ::continue::
        end

        if not InRange then
            Wait(5000)
        end
    end
end)

RegisterNetEvent('qc-farming:Notify', function(Title, Text, Time)
    Config.Notify(Title, Text, Time)
end)

---------------------------------------------
-- plant menu
---------------------------------------------
RegisterNetEvent('qc-farming:client:plantmenu', function(id)
    RSGCore.Functions.TriggerCallback('qc-farming:server:getplantdata', function(result)
        local plantdata = json.decode(result[1].properties)

        -- Indicator colors
        local hungerColorScheme = 'green'
        if plantdata.hunger <= 50 and plantdata.hunger > 10 then hungerColorScheme = 'yellow' end
        if plantdata.hunger <= 10 then hungerColorScheme = 'red' end

        local thirstColorScheme = 'green'
        if plantdata.thirst <= 50 and plantdata.thirst > 10 then thirstColorScheme = 'yellow' end
        if plantdata.thirst <= 10 then thirstColorScheme = 'red' end

        local qualityColorScheme = 'green'
        if plantdata.quality <= 50 and plantdata.quality > 10 then qualityColorScheme = 'yellow' end
        if plantdata.quality <= 10 then qualityColorScheme = 'red' end

        -- Send data in Nui
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openPlantMenu",
            data = {
                id = plantdata.id,
                growth = plantdata.growth,
                quality = plantdata.quality,
                hunger = plantdata.hunger,
                thirst = plantdata.thirst,
                hungerColor = hungerColorScheme,
                thirstColor = thirstColorScheme,
                qualityColor = qualityColorScheme
            }
        })
    end, id)
end)

-- NUI feedback (add below menu)
RegisterNUICallback("closePlantMenu", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("waterPlant", function(data, cb)
    TriggerEvent('qc-farming:client:waterplant', { plantid = data.plantid })
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("feedPlant", function(data, cb)
    TriggerEvent('qc-farming:client:feedplant', { plantid = data.plantid })
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("harvestPlant", function(data, cb)
    TriggerEvent('qc-farming:client:harvestplant', { plantid = data.plantid, growth = data.growth })
    SetNuiFocus(false, false)
    cb("ok")
end)

---------------------------------------------
-- water plant
---------------------------------------------
RegisterNetEvent('qc-farming:client:waterplant', function(data)

    local hasItem = RSGCore.Functions.HasItem('fullbucket', 1)

    if hasItem and not isBusy then
        isBusy = true
        LocalPlayer.state:set("inv_busy", true, true)
        FreezeEntityPosition(cache.ped, true)
        Citizen.InvokeNative(0x5AD23D40115353AC, cache.ped, entity, -1)
        TaskStartScenarioInPlace(cache.ped, `WORLD_HUMAN_BUCKET_POUR_LOW`, 0, true)
        Wait(10000)
        ClearPedTasks(cache.ped)
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
        FreezeEntityPosition(cache.ped, false)
        TriggerServerEvent('qc-farming:server:waterPlant', data.plantid)
        LocalPlayer.state:set("inv_busy", false, true)
        isBusy = false
    else
        TriggerEvent('qc-farming:Notify', '~#ff0000~'..locale('error'), locale('you_need_full_bucket_water'), 2000) --title, text, time
    end

end)


---------------------------------------------
-- feed plants
---------------------------------------------
RegisterNetEvent('qc-farming:client:feedplant', function(data)

    local hasItem1 = RSGCore.Functions.HasItem('bucket', 1)
    local hasItem2 = RSGCore.Functions.HasItem('fertilizer', 1)

    if hasItem1 and hasItem2 and not isBusy then
        isBusy = true
        LocalPlayer.state:set("inv_busy", true, true)
        FreezeEntityPosition(cache.ped, true)
        Citizen.InvokeNative(0x5AD23D40115353AC, cache.ped, entity, -1)
        TaskStartScenarioInPlace(cache.ped, `WORLD_HUMAN_FEED_PIGS`, 0, true)
        Wait(14000)
        ClearPedTasks(cache.ped)
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
        FreezeEntityPosition(cache.ped, false)
        TriggerServerEvent('qc-farming:server:feedPlant', data.plantid)
        LocalPlayer.state:set("inv_busy", false, true)
        isBusy = false
    else
        TriggerEvent('qc-farming:Notify', '~#ff0000~'..locale('error'), locale('need_water_fertilizer'), 2000) --title, text, time
    end

end)


---------------------------------------------
-- Harvest Plants
---------------------------------------------
RegisterNetEvent('qc-farming:client:harvestplant', function(data)

    if data.growth < 70 then
        TriggerEvent('qc-farming:Notify', '~#ff0000~'..locale('error'), locale('plant_not_grown'), 2000) --title, text, time
        return
    end

    if not isBusy then
        isBusy = true
        LocalPlayer.state:set("inv_busy", true, true)
        table.insert(HarvestedPlants, data.plantid)
        TriggerServerEvent('qc-farming:server:plantHasBeenHarvested', data.plantid)

        -- Launching animation
        DoAnim(cache.ped, 15000)

        Wait(15000) -- The duration of animation
        
        ClearPedTasks(cache.ped)
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
        FreezeEntityPosition(cache.ped, false)

        TriggerServerEvent('qc-farming:server:harvestPlant', data.plantid)
        LocalPlayer.state:set("inv_busy", false, true)
        isBusy = false
        canHarvest = true
    end

end)

-- Function for animation of a plant harvest (15 seconds)
function DoAnim(PedID, duration)
    ClearPedTasks(PedID)
    SetCurrentPedWeapon(PedID, `WEAPON_UNARMED`, true)

    local animDict = "mech_pickup@plant@berries"
    local animName = "base"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(0) end
    
    TaskPlayAnim(PedID, animDict, animName, 1.0, 0.5, duration, 1, 0.0, false, false, false)
end



---------------------------------------------
-- update plant data
---------------------------------------------
RegisterNetEvent('qc-farming:client:updatePlantData')
AddEventHandler('qc-farming:client:updatePlantData', function(data)
    Config.FarmPlants = data
end)

---------------------------------------------
-- plant seeds
---------------------------------------------
RegisterNetEvent('qc-farming:client:plantnewseed')
AddEventHandler('qc-farming:client:plantnewseed', function(outputitem, inputitem, PropHash, pPos, heading)

    local pos = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 1.0, 0.0)

    if Config.RestrictTowns then
        if CanPlantSeedHere(pos) and not IsPedInAnyVehicle(cache.ped, false) and not isBusy then
            isBusy = true
            LocalPlayer.state:set("inv_busy", true, true)
            local anim1 = `WORLD_HUMAN_FARMER_RAKE`
            local anim2 = `WORLD_HUMAN_FARMER_WEEDING`

            FreezeEntityPosition(cache.ped, true)

            if not IsPedMale(cache.ped) then
                anim1 = `WORLD_HUMAN_CROUCH_INSPECT`
                anim2 = `WORLD_HUMAN_CROUCH_INSPECT`
            end

            TaskStartScenarioInPlace(cache.ped, anim1, 0, true)
            Wait(10000)
            ClearPedTasks(cache.ped)
            SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
            TaskStartScenarioInPlace(cache.ped, anim2, 0, true)
            Wait(20000)
            ClearPedTasks(cache.ped)
            SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
            FreezeEntityPosition(cache.ped, false)
            TriggerServerEvent('qc-farming:server:removeitem', inputitem, 1)
            TriggerServerEvent('qc-farming:server:plantnewseed', outputitem, PropHash, pPos, heading)
            LocalPlayer.state:set("inv_busy", false, true)
            isBusy = false
            return
        end
        TriggerEvent('qc-farming:Notify', '~#ff0000~'..locale('error'), locale('cant_plant_here'), 2000) --title, text, time
    else
        if not IsPedInAnyVehicle(cache.ped, false) and not isBusy then
            isBusy = true
            LocalPlayer.state:set("inv_busy", true, true)
            local anim1 = `WORLD_HUMAN_FARMER_RAKE`
            local anim2 = `WORLD_HUMAN_FARMER_WEEDING`

            FreezeEntityPosition(cache.ped, true)

            if not IsPedMale(cache.ped) then
                anim1 = `WORLD_HUMAN_CROUCH_INSPECT`
                anim2 = `WORLD_HUMAN_CROUCH_INSPECT`
            end

            TaskStartScenarioInPlace(cache.ped, anim1, 0, true)
            Wait(10000)
            ClearPedTasks(cache.ped)
            SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
            TaskStartScenarioInPlace(cache.ped, anim2, 0, true)
            Wait(20000)
            ClearPedTasks(cache.ped)
            SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
            FreezeEntityPosition(cache.ped, false)
            TriggerServerEvent('qc-farming:server:removeitem', inputitem, 1)
            TriggerServerEvent('qc-farming:server:plantnewseed', outputitem, PropHash, pPos, heading)
            LocalPlayer.state:set("inv_busy", false, true)
            isBusy = false
            return
        end
    end

end)


---------------------------------------------
-- can plant here function
---------------------------------------------
function CanPlantSeedHere(pos)
    local canPlant = true

    local ZoneTypeId = 1
    local x,y,z =  table.unpack(GetEntityCoords(cache.ped))
    local town = Citizen.InvokeNative(0x43AD8FC02B429D33, x,y,z, ZoneTypeId)
    if town ~= false then
        canPlant = false
    end

    for i = 1, #Config.FarmPlants do
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.FarmPlants[i].x, Config.FarmPlants[i].y, Config.FarmPlants[i].z, true) < 1.3 then
            canPlant = false
        end
    end
    
    return canPlant
end

---------------------------------------------
-- farm shop blips
---------------------------------------------
CreateThread(function()
    for _,v in pairs(Config.FarmShopLocations) do
        if v.showblip then
            local FarmShopBlip = BlipAddForCoords(1664425300, v.coords)
            SetBlipSprite(FarmShopBlip, joaat(Config.Blip.blipSprite), true)
            SetBlipScale(FarmShopBlip, Config.Blip.blipScale)
            SetBlipName(FarmShopBlip, Config.Blip.blipName)
        end
    end
end)

---------------------------------------------
-- open farm shop
---------------------------------------------
Citizen.CreateThread(function()
    for farmshop, v in pairs(Config.FarmShopLocations) do
        -- Creating prompt to open the shop
        exports['rsg-core']:createPrompt(v.name, v.coords, 0xF3830D8E, Lang:t('menu.open') .. " " .. v.name, {
            type = 'client',
            event = 'qc-farming:client:OpenFarmShop',
        })

        -- Adding the Ballet if enabled
        if v.showblip then
            local FarmShopBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords)
            SetBlipSprite(FarmShopBlip, GetHashKey(Config.Blip.blipSprite), true)
            SetBlipScale(FarmShopBlip, Config.Blip.blipScale)
            Citizen.InvokeNative(0x9CB1A1623062F402, FarmShopBlip, Config.Blip.blipName)
        end

        -- Marker display if enabled
        if v.showmarker then
            Citizen.CreateThread(function()
                while true do
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x07DCE236, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 215, 0, 155, false, false, false, 1, false, false, false)
                    Wait(0)
                end
            end)
        end
    end
end)

RegisterNetEvent('qc-farming:client:OpenFarmShop')
AddEventHandler('qc-farming:client:OpenFarmShop', function()
    TriggerServerEvent('rsg-shops:server:openstore', 'farmer', 'farmer', 'Farmer')
end)

---------------------------------------------
-- remove plant object
---------------------------------------------
RegisterNetEvent('qc-farming:client:removePlantObject')
AddEventHandler('qc-farming:client:removePlantObject', function(plant)
    for i = 1, #SpawnedPlants do
        local o = SpawnedPlants[i]

        if o.id == plant then
            SetEntityAsMissionEntity(o.obj, false)
            FreezeEntityPosition(o.obj, false)
            DeleteObject(o.obj)
        end
    end
end)

---------------------------------------------
-- cleanup
---------------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for i = 1, #SpawnedPlants do
        local plants = SpawnedPlants[i].obj

        SetEntityAsMissionEntity(plants, false)
        FreezeEntityPosition(plants, false)
        DeleteObject(plants)
    end
end)
