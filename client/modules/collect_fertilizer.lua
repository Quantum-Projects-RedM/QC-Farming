local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()
---------------------------------------------
-- Target for gathering fertilizers
---------------------------------------------
CreateThread(function()
    exports['rsg-target']:AddTargetModel(Config.FertilizerProps, {
        options = {
            {
                type = 'client',
                event = 'qc-farming:client:collectfertilizer',
                icon = 'far fa-eye',
                label = locale('gathering_fert_target'),
                distance = 2
            }
        }
    })
end)

---------------------------------------------
-- gathering fertilizer
---------------------------------------------
RegisterNetEvent('qc-farming:client:collectfertilizer', function()
    local ped = PlayerPedId()  -- Retrieve the ped
    local hasItem = RSGCore.Functions.HasItem('bucket', 1)
    if not hasItem then
        -- Notification that the player does not have a bucket
        TriggerEvent('qc-farming:Notify', '~#ff0000~'..locale('error'), locale('need_bucket_collect_fetilizer'), 2000) --title, text, time
        return
    end
    if hasItem then
        -- Notification that the player begins with the collection of fertilizers
        TriggerEvent('qc-farming:Notify', '~#00ff00~'..locale('success'), locale('collecting_fertilizer'), 5000) --title, text, time
        --clean the previous animation
        ClearPedTasks(ped)
        -- We create a shovel and join it with a hand
        RequestModel("p_shovel02x")  -- Shovel model
        while not HasModelLoaded("p_shovel02x") do
            Wait(1)
        end
        local boneIndex = GetEntityBoneIndexByName(ped, "SKEL_R_Hand")  -- Players' hand
        shovelObject = CreateObject(GetHashKey("p_shovel02x"), GetEntityCoords(ped), true, true, true)
        SetEntityCoords(shovelObject, GetEntityCoords(ped))
        AttachEntityToEntity(shovelObject, ped, boneIndex, 0.0, -0.19, -0.089, 274.1899, 483.89, 378.40, true, true, false, true, 1, true)

        -- We are launching the animation to collect fertilizers
        RequestAnimDict("amb_work@world_human_gravedig@working@male_b@base")
        while not HasAnimDictLoaded("amb_work@world_human_gravedig@working@male_b@base") do
            Wait(100)
        end
        TaskPlayAnim(ped, "amb_work@world_human_gravedig@working@male_b@base", "base", 3.0, 3.0, -1, 1, 0, false, false, false)
        -- We start the light effect around the facility (if necessary)
        local pos = GetEntityCoords(ped)
        local fertilizer = GetClosestObjectOfType(pos, 2.5, Config.FertilizerProps[1], false, false, false)
        if fertilizer then
            local fertilizerCoords = GetEntityCoords(fertilizer)
            SetEntityCoordsNoOffset(fertilizer, fertilizerCoords.x, fertilizerCoords.y, fertilizerCoords.z + 0.1, false, false, false)  -- We lift an object for the effect
        end
        -- Progress bar for gathering fertilizers
        LocalPlayer.state:set('inv_busy', true, true)
        lib.progressBar({
            duration = 7000,--10000
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disableControl = true,
            disable = {
                move = true,
                mouse = true,
            },
            label = locale('gathering_fertilizer'),
        })
        -- Let's clean the animation after the collection has been completed
        ClearPedTasks(ped)
        DeleteObject(shovelObject)  -- Wiping a shovel after completion

        -- Notification that the process is completed
        TriggerEvent('qc-farming:Notify', '~#00ccff~'..locale('finished'), locale('youve_got_bucketful_fertilizer'), 5000) --title, text, time

        -- We'll give a player full of bucket
        LocalPlayer.state:set('inv_busy', false, true)
        TriggerServerEvent('qc-farming:server:giveitem', 'fertilizer', 1)
       -- We remove the light effect (if used)
if fertilizer then
    DeleteEntity(fertilizer)  -- We wipe the facility (fertilizer)
end

    end
end)
