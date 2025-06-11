Config = Config or {}
Config.FarmPlants = {}
---------------------------------------------
-- plant seed settings
---------------------------------------------
Config.ForwardDistance   = 2.0
Config.PromptGroupName   = 'You a farmer?'
Config.PromptCancelName  = 'Cancel'
Config.PromptPlaceName   = 'Place seedling'
Config.PromptRotateLeft  = 'Rotate left'
Config.PromptRotateRight = 'Rotate Right'

---------------------------------
-- notify settings
---------------------------------
Config.Notify = function (Title, Text, Time)-- Custom Notify Exports here
    lib.notify({ title = Title, description = Text, type = 'info', duration = Time })
end
---------------------------------
-- npc settings
---------------------------------
Config.DistanceSpawn = 20.0
Config.FadeIn = true

---------------------------------
-- general settings
---------------------------------
Config.RestrictTowns = false -- Will there be limited planting in cities (if set to False, players can plant anywhere, including cities)
Config.GrowthTimer = 1000 -- 60000 = Every 1 minute /to test 1000 = 1 second (time between each plant growth check, it is set to 1 second to test this here)
Config.DeadPlantTime = 60 * 60 * 96 -- Time until the plant dies and removed from the database (eg 60 *60 *24 for 1 day, 60 *60 *48 in 2 days, 60 *60 *72 in 3 days)
Config.StartingThirst = 25.0 -- The initial percentage of thirsty plants (initial value for the thirst level, here is 75%)
Config.StartingHunger = 10.0 -- The initial percentage of the plant hunger (the initial value for the hunger level, is 75% here)
Config.HungerIncrease = 50.0 -- the amount of hunger increase when the plant is poured (increases the hunger level by 25% each time the plant gets water)
Config.ThirstIncrease = 50.0 -- The amount of thirst increase when fertilizer is used (increases thirst level by 25% each time the fertilizer is used)
Config.Degrade = {min = 0.0002, max = 0.0005} -- Minimum and maximum reduction of plant quality over time (lesson of quality 3 to 5)
Config.QualityDegrade = {min = 0.005, max = 0.010} -- Minimum and maximum decrease of the quality of the plant (decline of quality from 8 to 12)
Config.GrowthIncrease = {min = 10, max = 20} -- How much the plant will grow on each cycle (growing between 10 and 20 units per cycle)
Config.MaxPlantCount = 100 -- The maximum number of plants that a player can have at any time (a maximum of 40 plants)
Config.CollectWaterTime = 10000 -- Time set to collect water (water collection lasts 10 seconds)
Config.CollectPooTime = 3000 -- Time set for fertilizer collection (fertilizer collection lasts 3 seconds)

---------------------------------
-- farm plants
---------------------------------
Config.FarmItems = {
    
    {
        planttype = 'wheat',  -- Plant type, in this case 'wheat'. This item defines the type of plant used in the game or application.
        item = 'wheat',  -- The name of the item associated with the plant, in this case wheat. This may be an ITEM identifier used or gives a player.
        seed = 'wheatseed',  -- The name of the seed used to plant this plant. In this case, it is 'wheatseed'. This may be an ITEM identifier used or gives a player.
        hash = 'CRP_WHEAT_DRY_AA_SIM', -- The hash of the plant model, which is used to identify the plant in the game or application. In this case, it is 'crp_wheat_dry_aa_sim'.
        label = 'Wheat',  -- A label or label used to display the plant name, which is displayed in this case as "WHEAT" (wheat).
         -- REWARD SETTINGS (Reward Settings)
        poorRewardMin = 5,  -- The minimum prize that player can get for poor plant quality. In this case, a minimum 1 unit.
        poorRewardMax = 10,  -- The maximum award that a player can get for the poor quality of the plant. In this case, a maximum of 2 units.
        goodRewardMin = 15,  -- Minimum reward for good quality plants. In this case, minimum 3 units.
        goodRewardMax = 20,  -- Maximum reward for good plant quality. In this case, a maximum of 10 units.   
        exellentRewardMin = 25,  -- Minimum reward for excellent plant quality. In this case, a minimum of 5 units.
        exellentRewardMax = 30,  -- Maximum reward for excellent quality plants. In this case, a maximum of 6 units.
    },
    {
        planttype = 'apple',
        item = 'apple',
        seed = 'appleseed',
        hash = 'P_TREE_ORANGE_01', 
        label = 'Apple',
        -- reward settings
        poorRewardMin = 5,
        poorRewardMax = 10, -- Added: Correct Max
        goodRewardMin = 15,
        goodRewardMax = 20,
        exellentRewardMin = 25,
        exellentRewardMax = 30,
    },
    
    {
        planttype = 'corn',
        item = 'corn',
        seed = 'cornseed',
        hash = 'CRP_CORNSTALKS_AB_SIM',
        label = 'Corn',
        -- reward settings
        poorRewardMin = 5,
        poorRewardMax= 10,
        goodRewardMin = 15,
        goodRewardMax = 20,
        exellentRewardMin = 25,
        exellentRewardMax = 30,
    },
    {
        planttype = 'sugar',
        item = 'sugar',
        seed = 'sugarseed',
        hash = 'CRP_SUGARCANE_AC_SIM',
        label =  'Sugar',
        -- reward settings
        poorRewardMin = 5,
        poorRewardMax = 10,
        goodRewardMin = 15,
        goodRewardMax = 20,
        exellentRewardMin = 25,
        exellentRewardMax = 30,
    },
    {
        planttype = 'tobacco',
        item = 'tobacco',
        seed = 'tabaccoseed',
        hash = 'CRP_TOBACCOPLANT_BC_SIM', 
        label = 'Tobacco',
        -- reward settings
        poorRewardMin = 5,
        poorRewardMax = 10,
        goodRewardMin = 15,
        goodRewardMax = 20,
        exellentRewardMin = 25,
        exellentRewardMax = 30,
    },
    {
        planttype = 'carrot',
        item = 'carrot',
        seed = 'carrotseed',
        hash = 'CRP_CARROTS_AA_SIM',
        label = 'Carrot',
        -- reward settings
        poorRewardMin = 5,
        poorRewardMax = 10,
        goodRewardMin = 15,
        goodRewardMax = 20,
        exellentRewardMin = 25,
        exellentRewardMax = 30,
    },
    {
        planttype = 'tomato',
        item = 'tomato',
        seed = 'tomatoseed',
        hash = 'CRP_TOMATOES_AA_SIM',
        label = 'Tomato',
        -- reward settings
        poorRewardMin = 5,
        poorRewardMax = 10,
        goodRewardMin = 15,
        goodRewardMax = 20,
        exellentRewardMin = 25,
        exellentRewardMax = 30,
    },
    {
        planttype = 'broccoli',
        item = 'broccoli',
        seed = 'broccoliseed',
        hash = 'CRP_BROCCOLI_AA_SIM',
        label = 'Broccoli',
        -- reward settings
        poorRewardMin = 5,
        poorRewardMax = 10,
        goodRewardMin = 15,
        goodRewardMax = 20,
        exellentRewardMin = 25,
        exellentRewardMax = 30,
    },
    {
        planttype = 'potato',
        item = 'potato',
        seed = 'potatoseed',
        hash = 'CRP_POTATOES_AA_SIM',
        label = 'Potato',
        -- reward settings
        poorRewardMin = 5,
        poorRewardMax = 10,
        goodRewardMin = 15,
        goodRewardMax = 20,
        exellentRewardMin = 25,
        exellentRewardMax = 30,
    },
    {
        planttype = 'artichoke',
        item = 'artichoke',
        seed = 'artichokeseed',
        hash = 'CRP_ARTICHOKE_AA_SIM',
        label = 'Artichoke',
        -- reward settings
        poorRewardMin = 5,
        poorRewardMax = 10,
        goodRewardMin = 15,
        goodRewardMax = 20,
        exellentRewardMin = 25,
        exellentRewardMax = 30,
    },

    {
        planttype = 'malina',
        item = 'malina',
        seed = 'malinaseed',
        hash = 'CRP_BERRY_AA_SIM', -- This is a placeholder hash, replace it with the actual model hash for malina
        label = 'Malina',
        -- reward settings
        poorRewardMin = 5,
        poorRewardMax = 10,
        goodRewardMin = 15,
        goodRewardMax = 20,
        exellentRewardMin = 25,
        exellentRewardMax = 30,
    },
}

---------------------------------
-- blip settings
---------------------------------
Config.Blip = {
    blipName = 'Farm Store', -- Translate to your language
    blipSprite = 'blip_summer_horse', -- Config.blip.blip sprite
    blipScale = 0.2 -- Config.blip.blip scale
}

---------------------------------
-- farm shop
---------------------------------
Config.FarmShop = {
     [1] = { name = 'carrotseed',    price = 0.10, amount = 100000,  info = {}, type = 'item', slot = 1, },
     [2] = { name = 'cornseed',      price = 0.10, amount = 100000,  info = {}, type = 'item', slot = 2, },
     [3] = { name = 'sugarseed',     price = 0.10, amount = 100000,  info = {}, type = 'item', slot = 3, },
     [4] = { name = 'tomatoseed',    price = 0.10, amount = 100000,  info = {}, type = 'item', slot = 4, },
     [5] = { name = 'broccoliseed',  price = 0.10, amount = 100000,  info = {}, type = 'item', slot = 5, },
     [6] = { name = 'potatoseed',    price = 0.10, amount = 100000,  info = {}, type = 'item', slot = 6, },
     [7] = { name = 'artichokeseed', price = 0.10, amount = 100000,  info = {}, type = 'item', slot = 7, },
     [8] = { name = 'bucket',        price = 5,   amount = 10000,   info = {}, type = 'item', slot = 8, },
}

---------------------------------
-- farm shop locations
---------------------------------
Config.FarmShopLocations = {
   { 
        name = 'PoApoteka (Valantine)',
        prompt = 'val-farmshop',
        coords = vector3(-231.9709, 644.5262, 113.3582),
        showblip = true,
        npcmodel = `a_m_m_valfarmer_01`,
        npccoords = vector4(-231.9709, 644.5262, 113.3582, 310.3258),
    },
    
    { 
        name = 'Poljoapoteka2',
        prompt = 'val-farmshop',
        coords = vector3(-841.5115, -1366.1421, 43.6815),
        showblip = true,
        npcmodel = `a_m_m_valfarmer_01`,
        npccoords = vector4(-841.5115, -1366.1421, 43.6815, 87.3671),
    },
    { 
        name = 'Poljoapoteka3',
        prompt = 'val-farmshop',
        coords = vector3(2808.6726, -1281.5323, 47.0885),
        showblip = true,
        npcmodel = `a_m_m_valfarmer_01`,
        npccoords = vector4(2808.6726, -1281.5323, 47.0885, 318.5407),
    },
  
}

---------------------------------
-- water props
---------------------------------
Config.WaterProps = {
    `p_watertrough01x`,
    `p_watertroughsml01x`,
    `p_watertrough01x_new`,
    `p_watertrough02x`,
    `p_watertrough03x`,
    `p_barrel_wash01x`,
    `p_barrelhalf02x`
}

---------------------------------
-- fertilizer props
---------------------------------
Config.FertilizerProps = {
    `p_horsepoop02x`,
    `p_horsepoop03x`,
    `new_p_horsepoop02x_static`,
    `p_poop01x`,
    `p_poop02x`,
    `p_poopile01x`,
    `p_sheeppoop01`,
    `p_sheeppoop02x`,
    `p_sheeppoop03x`,
    `p_wolfpoop01x`,
    `p_wolfpoop02x`,
    `p_wolfpoop03x`,
    `s_horsepoop01x`,
    `s_horsepoop02x`,
    `s_horsepoop03x`,
    `mp007_p_mp_horsepoop03x`,
}
