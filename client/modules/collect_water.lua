local RSGCore = exports['rsg-core']:GetCoreObject()

---------------------------------------------
-- target to collect water
---------------------------------------------
CreateThread(function()
    exports['rsg-target']:AddTargetModel(Config.WaterProps, {
        options = {
            {
                type = 'client',
                event = 'qc-farming:client:collectwater',
                icon = 'far fa-eye',
                label = locale('gathering_water_target'),
                distance = 1.5
            }
        }
    })
end)

---------------------------------------------
-- water collecting
---------------------------------------------
RegisterNetEvent('qc-farming:client:collectwater', function()
    local ped = PlayerPedId()  -- Retrieve the ped
    local hasItem = RSGCore.Functions.HasItem('bucket', 1)

    if not hasItem then
        -- Notification that the player does not have a bucket
        TriggerEvent('qc-farming:Notify', '~#ff0000~'..locale('error'), locale('you_need_bucket_collect_water'), 2000) --title, text, time
        return
    end

    if hasItem then
        -- Notification that the player begins with the collection of water
        TriggerEvent('qc-farming:Notify', '~#00ff00~'..locale('success'), locale('collecting_water'), 5000) --title, text, timeTriggerClientEvent('qc-farming:Notify', '~#ff0000~'..locale('error'), locale('need_bucket_collect_fetilizer'), 2000) --title, text, time
        -- Let's clean the previous animation
        ClearPedTasks(ped)
        -- We run an animation to collect water
        TaskStartScenarioInPlace(ped, 'WORLD_CAMP_JACK_ES_BUCKET_FILL', 0, true)
        -- Progress bar to collect water
        LocalPlayer.state:set('inv_busy', true, true)
        lib.progressBar({
            duration = 4000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disableControl = true,
            disable = {
                move = true,
                mouse = true,
            },
            label = locale('gathering_water'),
        })
        -- Let's clean the animation after the collection has been completed
        ClearPedTasks(ped)
        -- Notification that the process is completed
        TriggerEvent('qc-farming:Notify', '~#00ccff~'..locale('finished'), locale('youve_got_bucketful_water'), 5000) --title, text, time
        -- We'll give a player full of bucket
        LocalPlayer.state:set('inv_busy', false, true)
        TriggerServerEvent('qc-farming:server:giveitem', 'fullbucket', 1)
    end
end)

