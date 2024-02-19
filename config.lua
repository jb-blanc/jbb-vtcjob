Config = Config or {}
Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

Config.framework = 'ESX' -- ESX or QBCore

Config.VTC = {
    general = {
        speed_unit = "MPH",                 --can be KPH or MPH (this will affect min/max speed constraint)
        job_required = nil,                 --The needed job for being a VTC driver (nil means no job)
        item_required = nil,                --The needed item for being a VTC driver (nil means no item)
    },
    course = {
        availability_time_npc = 10000,      --Number of milliseconds after a NPC Course will be remove from list
        availability_time_player = 20000,   --Number of milliseconds after a Player Course will be remove from list
        malus_interval = 100,               --Calculation ticks for malus (milliseconds)
        malus = {
            to_fast=0.05,    --Malus for overspeeding
            to_slow=0.05,    --Malus for underspeeding
            away=0.1,        --Malus when driver is out from the car
            damage=2.0,      --Malus during car damage
            music=0.1,       --Malus for wrong music needs
        }
    },
    generator = {
        min_wait_time = 3000,               --Min time before the next NPC course generation
        max_wait_time = 15000,              --Max time before the next NPC course generation
        peds_radius_spawn = 3,              --Radius for NPC peds to spawn around the location
        max_number_of_ped = 3,              --Max number of Peds generated for 1 course
        money_per_meter = 0.5,              --Money gained per meters in the course
        min_distance = 500,                 --Minimum distance between the pickup location and destination
        range_min_maxspeed = 80,            --Minimum Max Speed for max speed constraint on NPC courses
        range_max_maxspeed = 120,           --Maximum Max Speed for max speed constraint on NPC courses
        range_min_minspeed = 20,            --Minimum Min Speed for min speed constraint on NPC courses
        range_max_minspeed = 50,            --Maximum Min Speed for min speed constraint on NPC courses
        -- List of peds model used for spawning NPCs
        --Be careful : If you add new peds, you need to generate the peds hashes list (see the doc)
        peds_model = {
            'a_f_m_skidrow_01',
            'a_f_m_soucentmc_01',
            'a_f_m_soucent_01',
            'a_f_m_soucent_02',
            'a_f_m_tourist_01',
            'a_f_m_trampbeac_01',
            'a_f_m_tramp_01',
            'a_f_o_genstreet_01',
            'a_f_o_indian_01',
            'a_f_o_ktown_01',
            'a_f_o_salton_01',
            'a_f_o_soucent_01',
            'a_f_o_soucent_02',
            'a_f_y_beach_01',
            'a_f_y_bevhills_01',
            'a_f_y_bevhills_02',
            'a_f_y_bevhills_03',
            'a_f_y_bevhills_04',
            'a_f_y_business_01',
            'a_f_y_business_02',
            'a_f_y_business_03',
            'a_f_y_business_04',
            'a_f_y_eastsa_01',
            'a_f_y_eastsa_02',
            'a_f_y_eastsa_03',
            'a_f_y_epsilon_01',
            'a_f_y_fitness_01',
            'a_f_y_fitness_02',
            'a_f_y_genhot_01',
            'a_f_y_golfer_01',
            'a_f_y_hiker_01',
            'a_f_y_hipster_01',
            'a_f_y_hipster_02',
            'a_f_y_hipster_03',
            'a_f_y_hipster_04',
            'a_f_y_indian_01',
            'a_f_y_juggalo_01',
            'a_f_y_runner_01',
            'a_f_y_rurmeth_01',
            'a_f_y_scdressy_01',
            'a_f_y_skater_01',
            'a_f_y_soucent_01',
            'a_f_y_soucent_02',
            'a_f_y_soucent_03',
            'a_f_y_tennis_01',
            'a_f_y_tourist_01',
            'a_f_y_tourist_02',
            'a_f_y_vinewood_01',
            'a_f_y_vinewood_02',
            'a_f_y_vinewood_03',
            'a_f_y_vinewood_04',
            'a_f_y_yoga_01',
            'g_f_y_ballas_01',
            'ig_barry',
            'ig_bestmen',
            'ig_beverly',
            'ig_car3guy1',
            'ig_car3guy2',
            'ig_casey',
            'ig_chef',
            'ig_chengsr',
            'ig_chrisformage',
            'ig_clay',
            'ig_claypain',
            'ig_cletus',
            'ig_dale',
            'ig_dreyfuss',
            'ig_fbisuit_01',
            'ig_floyd',
            'ig_groom',
            'ig_hao',
            'ig_hunter',
            'csb_prolsec',
            'ig_joeminuteman',
            'ig_josef',
            'ig_josh',
            'ig_lamardavis',
            'ig_lazlow',
            'ig_lestercrest',
            'ig_lifeinvad_01',
            'ig_lifeinvad_02',
            'ig_manuel',
            'ig_milton',
            'ig_mrk',
            'ig_nervousron',
            'ig_nigel',
            'ig_old_man1a',
            'ig_old_man2',
            'ig_oneil',
            'ig_orleans',
            'ig_ortega',
            'ig_paper',
            'ig_priest',
            'ig_prolsec_02',
            'ig_ramp_gang',
            'ig_ramp_hic',
            'ig_ramp_hipster',
            'ig_ramp_mex',
            'ig_roccopelosi',
            'ig_russiandrunk',
            'ig_siemonyetarian',
            'ig_solomon',
            'ig_stevehains',
            'ig_stretch',
            'ig_talina',
            'ig_taocheng',
            'ig_taostranslator',
            'ig_tenniscoach',
            'ig_terry',
            'ig_tomepsilon',
            'ig_tylerdix',
            'ig_wade',
            'ig_zimbor',
            's_m_m_paramedic_01',
            'a_m_m_afriamer_01',
            'a_m_m_beach_01',
            'a_m_m_beach_02',
            'a_m_m_bevhills_01',
            'a_m_m_bevhills_02',
            'a_m_m_business_01',
            'a_m_m_eastsa_01',
            'a_m_m_eastsa_02',
            'a_m_m_farmer_01',
            'a_m_m_fatlatin_01',
            'a_m_m_genfat_01',
            'a_m_m_genfat_02',
            'a_m_m_golfer_01',
            'a_m_m_hasjew_01',
            'a_m_m_hillbilly_01',
            'a_m_m_hillbilly_02',
            'a_m_m_indian_01',
            'a_m_m_ktown_01',
            'a_m_m_malibu_01',
            'a_m_m_mexcntry_01',
            'a_m_m_mexlabor_01',
            'a_m_m_og_boss_01',
            'a_m_m_paparazzi_01',
            'a_m_m_polynesian_01',
            'a_m_m_prolhost_01',
            'a_m_m_rurmeth_01',
        },
    },
    player = {
        commission = 0.3                    --Percentage of money that will be earned by the player for a course (NPC or Player). 0.3 = 30%
    }
}

-- List of allowed pickup and destination coords
Config.VTCLocations = {
    -- VESPUCCI / LA PUERTA
    vector3(-715.72, -1295.26, 5.1), -- LMYS / La puerta
    vector3(-1080.98, -1045.28, 2.15), -- Vespucci canal
    vector3(-1213.1772, -1449.3197, 4.3811), -- Aguja Street / Vespucci
    vector3(-1047.5337, -1393.7178, 5.4238), -- La SPADA Restaurant

    -- AIRPORT
    vector3(-1035.44, -2736.82, 20.17), -- Airport top
    vector3(-1027.91, -2732.69, 13.76), -- Airport bottom
    vector3(-1081.73, -2694.02, 13.76), -- Airport bottom 2

    -- DEL PERRO
    vector3(-1631.79, -1003.3, 13.04), -- DEL PERRO PIER
    vector3(-1381.1434, -579.5643, 29.6755), -- Bahama Mamas
    vector3(-1293.2860, -693.8397, 24.5255), -- Dyonisa / Astro theaters
    vector3(-1274.5585, -424.7415, 33.6803), -- Elgin House
    vector3(-1848.0984, -360.2483, 48.9368), -- Von Crastenburg

    -- ROCKFORD HILLS
    vector3(-853.5187, 158.5385, 64.7753), -- Michael's House
    vector3(-972.5626, 180.4684, 63.8513), -- House

    -- VINEWOOD HILLS / RICHMAN
    vector3(-342.27, 659.36, 168), -- House
    vector3(-613.8535, 679.9258, 149.1435), -- House
    vector3(-577.5768, 503.5571, 104.9357), -- House

    -- VINEWOOD WEST
    vector3(-559.7600, 271.6943, 82.5603), -- Tequi-la-la
    vector3(-398.4605, 208.2122, 82.9767), -- Hornbills
    vector3(-17.1060, 168.5050, 95.0352), -- Elgin HOUSE

    -- VINEWOOD DOWNTOWN
    vector3(321.2547, 167.8950, 103.2453), -- Doppler Cinema
    vector3(339.0360, 42.6671, 90.2346), -- Calisto Apartments

    -- VINEWOOD EAST
    vector3(923.48, 47.54, 81.11), -- Casino entrance
    vector3(735.1063, 196.0226, 84.9001), -- CNT
    vector3(580.6810, 35.5975, 92.1260), -- LSPD

    -- MIRROR PARK
    vector3(1258.92, -602.64, 69.0), -- House
    vector3(1239.5020, -371.1143, 68.6414), -- Horny's
    vector3(1382.1263, -580.9047, 73.9288), -- House
    vector3(1167.7576, -643.6456, 61.8536), -- Park

    -- LITTLE SEOUL
    vector3(-752.0211, -704.1246, 29.3051), -- Church
    vector3(-557.5195, -643.1522, 32.7910), -- Betsy O'Neil
    vector3(-622.8898, -946.1826, 21.2964), -- Weazel News

    -- ELYSIAN ISLAND / BANNING
    vector3(787.36, -2975.04, 6.04), -- Jetsam terminal

    -- CYPRESS FLATS
    vector3(922.8884, -2471.0330, 28.1474), -- Cypress Wharehouse
    vector3(859.9199, -2088.9666, 29.8066), -- NightClub

    -- EL BURRO HEIGHTS
    vector3(1292.4294, -1734.2399, 52.8993), -- in front of Lester House
    vector3(1739.0699, -1631.2025, 111.9897), -- Oil place

    -- LA MESA / MURRIETA HEIGHTS
    vector3(802.1053, -996.2895, 25.6982), -- 127 - Transfer & Storage Co.
    vector3(762.3206, -818.1512, 25.8549), -- VIDEOGEDDON
    vector3(716.7092, -1070.2611, 21.8086), -- Los Santos Customs
    vector3(812.7603, -1289.4860, 25.8382), -- La Mesa P.D.

    -- MISSION ROW / LEGION SQUARE / PILLBOX HILL / TEXTILE CITY
    vector3(-110.04, -609.51, 36.28), -- Arcadius business center
    vector3(-50.7323, -791.7473, 43.7745), -- Maze Bank Tower
    vector3(142.3055, -949.4949, 29.2873), -- Legion square
    vector3(451.8902, -687.2945, 27.7046), -- Simmet Alley
    vector3(433.8731, -629.5891, 28.2771), -- Dashound bus

    -- STRAWBERRY / CHAMBERLAIN HILLS / DAVIS / RANCHO
    vector3(-234.7687, -2048.4209, 27.3091), -- Maze Bank Arena
    
    -- ALTA / BURTON / HAWIKC
    vector3(306.39, -234.31, 54.07), -- Motel Alta
    vector3(245.48, -378.46, 44.49), -- Occupation avenue / Alta
    vector3(58.47, -278.59, 47.46), -- Motel TV-Rhones / Occupation avenue

    -- BANHAM CANYON / PACIFIC BLUFFS / CHUMASH
    vector3(-3021.04, 84.29, 11.67), -- PACIFIC BLUFFS
    vector3(-3172.58, 1294.82, 14.28), -- CHUMASH Yellow House
    vector3(-2294.3435, 374.0099, 174.6016), -- KO RTZ

    -- GREAT CHAPARRAL
    vector3(-253.31, 2190.21, 130.11), -- Wood house

    -- HARMONY / GRAND SENORA DESERT
    vector3(734.4, 2523.83, 73.23), -- REBEL Radio station
    vector3(1138.1610, 2676.9414, 37.6905), -- Motor Motel
    vector3(569.1762, 2739.6667, 41.7028), -- Animal Ark

    --GRAPESEED / MOUNT GORDO
    vector3(1684.41, 4787.57, 41.94), -- Wonderama arcade
    vector3(3324.34, 5158.19, 18.41), -- Lighthouse
    vector3(2091.5601, 4758.4927, 41.1087), --McKenzie Field
    vector3(1774.7518, 4583.2290, 37.1585), -- Alamo Fruit Market
    vector3(2054.9871, 5009.1729, 40.5398), -- Union Grain

    -- SANDY SHORES
    vector3(1753.5072, 3293.1519, 40.6197), -- Airfield
    vector3(1688.3401, 3576.6826, 35.0422), -- Fire station
    vector3(1732.6763, 3844.9126, 34.3694), -- Patterson house
    vector3(1960.3052, 3835.1396, 31.6799), -- Bar
    vector3(1409.9612, 3603.2412, 34.4866), -- Liquor ACE

    -- PALETO BAY
    vector3(-12.43, 6648.38, 31.07), -- house
    vector3(-427.02, 6027.99, 31.49), -- Paleto bay sheriff office
    vector3(-53.2049, 6523.8340, 30.9881), -- Willy's supermarket
    vector3(-229.0478, 6438.9243, 30.7011), -- house
    vector3(-337.5426, 6158.3120, 30.9891), -- church
    vector3(-702.0356, 5805.8979, 16.7860), -- Bayview Lodge

    -- MONT CHILIAD / PALETO FOREST
    vector3(-565.4891, 5378.9839, 69.6957), -- Wood Company
    vector3(-1031.51, 4932.85, 203.04), -- Altruist Cannibal Camp

    -- TONGVA HILLS
    vector3(-1905.15, 2064.89, 140.84), -- Vineward
    vector3(-2552.5005, 1909.3124, 168.3700), -- Big House

}

-- List of radio used for the radio constraint on NPC courses
Config.VtcRadio = {
    "RADIO_35_DLC_HEI4_MLR",
    "RADIO_37_MOTOMAMI",
    "RADIO_12_REGGAE",
    "RADIO_13_JAZZ",
    "RADIO_14_DANCE_02",
    "RADIO_15_MOTOWN",
    "RADIO_20_THELAB",
    "RADIO_16_SILVERLAKE",
    "RADIO_34_DLC_HEI4_KULT",
    "RADIO_17_FUNK",
    "RADIO_18_90S_ROCK",
    "RADIO_21_DLC_XM17",
    "RADIO_22_DLC_BATTLE_MIX1_RADIO",
    "RADIO_23_DLC_XM19_RADIO",
    "RADIO_01_CLASS_ROCK",
    "RADIO_02_POP",
    "RADIO_03_HIPHOP_NEW",
    "RADIO_04_PUNK",
    "RADIO_06_COUNTRY",
    "RADIO_07_DANCE_01",
    "RADIO_08_MEXICAN",
    "RADIO_09_HIPHOP_OLD",
    -- Disabled because depends on where you are on the map
    --"RADIO_05_TALK_01",
    --"RADIO_11_TALK_02",
}