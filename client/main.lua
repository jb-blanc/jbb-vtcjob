Jbb = exports["jbb-vtcjob"]:getInstance()

local courses = {}
local myRate = 0.0
local currentCourse = nil
local currentUiCourse = nil
local onDuty = false

local currentBlip = nil
local driver = nil
local driverBlip = nil
local destinationBlip = nil

-- FUNCTIONS
function GetPlayerVehicleSeatCount()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return -1 end
    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
    if seats < 1 then return -1 end
    return seats - 1
end

function CanStartCourse(cid)
    local playerSeatCount = GetPlayerVehicleSeatCount()
    local coursePeds = courses[cid].pedscount
    if playerSeatCount >= coursePeds then return true end
    Jbb.Notify("Not enough seats in your vehicle", "error", 5000)
    return false
end

local function takePedMugshot(ped)
    local handle = RegisterPedheadshot(ped)
    while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
        Wait(0)
    end
    local txdString = GetPedheadshotTxdString(handle)

    VtcUiUpdateClientInfos(txdString, currentCourse)

    -- Cleanup after yourself!
    UnregisterPedheadshot(handle)
end

local function getSpeed(entity)
    local speed = GetEntitySpeed(entity)
    if Config.VTC.general.speed_unit == "KPH" then
        speed = speed * 3.6
    else
        speed = speed * 2.236936
    end
    return speed
end

local function createPedAt(coords)
    local model = Config.VTC.generator.peds_model[math.random(#(Config.VTC.generator.peds_model))]

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(100)
    end

    local ped = CreatePed(
		0, 
		model,
		coords.x + math.random()*Config.VTC.generator.peds_radius_spawn,
		coords.y + math.random()*Config.VTC.generator.peds_radius_spawn,
		coords.z,
		math.random()*360.0,
		true,
		false
	)
    SetPedRandomComponentVariation(ped, 0)
    SetPedRandomProps(ped)
    return ped
end

local function createBlips(coords, blipName, blipNumber, blipColor, display, scale, shortRange)
    display = display or 4
    scale = scale or 0.60
    shortRange = shortRange or true

    local Blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(Blip, blipNumber)
    SetBlipDisplay(Blip, display)
    SetBlipScale(Blip, scale)
    SetBlipAsShortRange(Blip, shortRange)
    SetBlipColour(Blip, blipColor)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blipName)
    EndTextCommandSetBlipName(Blip)

    return Blip
end

local function getV3ToV2Distance(point1, point2)
    local dx = point2.x - point1.x
    local dy = point2.y - point1.y
    return math.sqrt(dx * dx + dy * dy)
end

local function getGroundZCoordsOrDefault(c, default)
    local z = c.z
    local success, newZ = GetGroundZFor_3dCoord(c.x,c.y,c.z,false)
    if success then return newZ
    else return default or z end
end

local function getModelName(entity)
    local modelHash = GetEntityModel(entity)
    return Config.VTC.hashes[modelHash]
end

local function playSound(sound)
    if not currentCourse then return end
    for _,ped in ipairs(currentCourse.peds) do
        local pedModel = getModelName(ped)

        PlayPedAmbientSpeechWithVoiceNative(ped, sound, pedModel.."_white_full_01", "SPEECH_PARAMS_FORCE_SHOUTED", 0)
        PlayPedAmbientSpeechWithVoiceNative(ped, sound, pedModel.."_black_full_01", "SPEECH_PARAMS_FORCE_SHOUTED", 0)
        PlayPedAmbientSpeechWithVoiceNative(ped, sound, pedModel.."_chinese_full_01", "SPEECH_PARAMS_FORCE_SHOUTED", 0)
        PlayPedAmbientSpeechWithVoiceNative(ped, sound, pedModel.."_white_full_02", "SPEECH_PARAMS_FORCE_SHOUTED", 0)
        PlayPedAmbientSpeechWithVoiceNative(ped, sound, pedModel.."_black_full_02", "SPEECH_PARAMS_FORCE_SHOUTED", 0)
        PlayPedAmbientSpeechWithVoiceNative(ped, sound, pedModel.."_chinese_full_02", "SPEECH_PARAMS_FORCE_SHOUTED", 0)
    end
end

-- FUNCTIONS FOR DRIVER TASK
local function askPedsLeaveVehicle(vehicle)
    if not currentCourse then return false end
    local timeout = 5000
    local allPedsLeaved = false
    local retry = 0
    while currentCourse and retry < 3 and not allPedsLeaved do
        for _,ped in ipairs(currentCourse.peds) do
            TaskLeaveVehicle(ped, vehicle, 1)
            TaskWanderStandard(ped, 10.0, 10)
        end
        

        local timeStart = GetGameTimer()
        while not allPedsLeaved and (GetGameTimer() - timeStart < timeout) do
            allPedsLeaved = true
            for _,ped in ipairs(currentCourse.peds) do
                if IsPedInVehicle(ped,vehicle,false) then
                    allPedsLeaved = false
                end
            end
            Wait(100)
        end
        retry += 1
    end
    
    for i = 0, 5 do
        SetVehicleDoorShut(vehicle, i, true) -- will close all doors from 0-5
    end

    return allPedsLeaved
end

local function setPedsWander(location)
    if not currentCourse then return false end
    for _,ped in ipairs(currentCourse.peds) do
        TaskWanderInArea(ped, location.x, location.y, location.z, 200.0, 10.0, 5)
    end
    Wait(500)
end

local function generateAdditionalRideNeeds()
    if not currentCourse then return end
    local wantMusic = math.random(1,10) > 5
    local station = "WHATEVER"
    if wantMusic then
        --Check if he want's a specific station
        if math.random(1,10) > 5 then
            station = Config.VtcRadio[math.random(1,#(Config.VtcRadio))]
        end
    end
    currentCourse.wantMusic = wantMusic
    currentCourse.radioStation = station
end

local function isClientOkOnMusic(station, radioIndex)
    if not currentCourse then return false end
    if not currentCourse.wantMusic and radioIndex ~= 255 then return false end
    if not currentCourse.wantMusic and radioIndex == 255 then return true end
    if currentCourse.wantMusic and radioIndex == 255 then return false end
    if currentCourse.wantMusic and currentCourse.radioStation == "WHATEVER" then return true end
    if currentCourse.wantMusic and currentCourse.radioStation == station then return true end
    return false
end

local function startSatisfactionThread()
    if not currentCourse then return end
    --GetTimeSincePlayerDroveAgainstTraffic(player)

    currentCourse.satisfaction = 100.0
    local prevBodyHealth = GetVehicleBodyHealth(GetVehiclePedIsIn(PlayerPedId(),false))
    local vehicleBodyHealth = prevBodyHealth
    local isPlayerInVehicle = true

    generateAdditionalRideNeeds()
    takePedMugshot(currentCourse.peds[1])

    CreateThread(function()
        Wait(10000)
        while currentCourse and currentCourse.stage == 2 and currentCourse.satisfaction > 0 do
            local speed = getSpeed(PlayerPedId())
            local vehicle = GetVehiclePedIsIn(PlayerPedId(),false)
            local hasMadeDamage = false

            if vehicle then
                vehicleBodyHealth = GetVehicleBodyHealth(vehicle)
                hasMadeDamage = vehicleBodyHealth < prevBodyHealth
                prevBodyHealth = vehicleBodyHealth
                isPlayerInVehicle = true
            else
                isPlayerInVehicle = false
            end

            local toFast = currentCourse.maxSpeed < 999 and speed > currentCourse.maxSpeed
            local toSlow = currentCourse.minSpeed < 999 and speed < currentCourse.minSpeed
            local musicOk = isClientOkOnMusic(GetPlayerRadioStationName(),GetPlayerRadioStationIndex())

            if toFast then
                currentCourse.satisfaction = currentCourse.satisfaction - Config.VTC.course.malus.to_fast
                playSound("GENERIC_FRIGHTENED_HIGH")
            end
            if toSlow then
                currentCourse.satisfaction = currentCourse.satisfaction - Config.VTC.course.malus.to_slow
                playSound("GENERIC_INSULT_HIGH")
            end
            if hasMadeDamage then 
                currentCourse.satisfaction = currentCourse.satisfaction - Config.VTC.course.malus.damage
                playSound("GENERIC_SHOCKED_HIGH")
            end
            if not isPlayerInVehicle then 
                currentCourse.satisfaction = currentCourse.satisfaction - Config.VTC.course.malus.away
                playSound("GENERIC_INSULT_HIGH")
            end
            if not musicOk then
                currentCourse.satisfaction = currentCourse.satisfaction - Config.VTC.course.malus.music
                playSound("GENERIC_SHOCKED_MED")
            end

            if currentCourse.satisfaction < 0 then currentCourse.satisfaction = 0 end
            
            VtcUiUpdateSatisfaction(currentCourse.satisfaction)

            Wait(Config.VTC.course.malus_interval)
        end
    end)
end

local function createPedsLeavingThread()
    CreateThread(function()
        local allPedsLeaved = false
        while currentCourse and currentCourse.stage == 2 do
            local dist = getV3ToV2Distance(GetEntityCoords(PlayerPedId()), currentCourse.destination)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            
            if dist <= 15.0 and getSpeed(vehicle) < 1.0 then
                
                allPedsLeaved = askPedsLeaveVehicle(vehicle)

                if allPedsLeaved then
                    currentCourse.stage = 3
                end
            end

            Wait(0)
        end

        if currentCourse and allPedsLeaved then 
            RemoveBlip(currentBlip)
            setPedsWander(currentCourse.destination)
            TriggerServerEvent("jbb:vtc:server:finished", currentCourse.id, currentCourse.satisfaction)
        end
    end)
end

local function createPlayerLeavingThread()
    CreateThread(function()
        local serverEventEmitted = false
        while currentCourse and currentCourse.stage == 2 do
            local dist = getV3ToV2Distance(GetEntityCoords(PlayerPedId()), currentCourse.destination)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            
            if dist <= 15.0 and getSpeed(vehicle) < 1.0 then
                if not serverEventEmitted then
                    TriggerServerEvent("jbb:vtc:server:driveratdestination", currentCourse.id)
                    serverEventEmitted = true
                end
                
                local client = currentCourse.player
                if client then
                    local clientVeh = GetVehiclePedIsIn(NetToPed(currentCourse.playerNetId), false)
                    if clientVeh ~= vehicle then
                        currentCourse.stage = 3
                    end
                end
            end
            Wait(1000)
        end

        if currentCourse and currentCourse.stage == 3 then
            RemoveBlip(currentBlip)
            TriggerServerEvent("jbb:vtc:server:finished", currentCourse.id, currentCourse.satisfaction)
        end
    end)
end

local function startDepositListener()
    if not currentCourse then return end

    RemoveBlip(currentBlip)
    currentBlip = createBlips(currentCourse.destination, "VTC Client deposit", 280, 5, 2, 0.7, false)
    SetBlipRouteColour(currentBlip, 5)
    SetBlipRoute(currentBlip, true)
    
    CreateThread(function()
        local colorRed = {r=255,g=0,b=0}
        local colorOrange = {r=255,g=180,b=46}
        local colorGreen = {r=0,g=255,b=0}
        while currentCourse and currentCourse.stage == 2 do
            local c = colorRed
            local dist = getV3ToV2Distance(GetEntityCoords(PlayerPedId()), currentCourse.destination)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            --Trying to fix elevation of marker
            local z = currentCourse.destination.z
            local v3Copy = vector3(currentCourse.destination.x, currentCourse.destination.y, z + 300)
            
            if dist <= 200 then
                z = getGroundZCoordsOrDefault(v3Copy, z)
            end

            if dist <= 15.0 then
                if getSpeed(vehicle) < 1 then
                    c = colorGreen
                else
                    c = colorOrange
                end
            end

            DrawMarker(1, currentCourse.destination.x, currentCourse.destination.y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 30.0, 30.0, 2.0, c.r, c.g, c.b, 96, false, false, 2, nil, nil, false)
            Wait(0)
        end
    end)

    if currentCourse.player then
        createPlayerLeavingThread()
    else
        startSatisfactionThread()
        createPedsLeavingThread()
    end
end

local function createPedsEnteringThread()
    -- peds waiting for going in the car
    CreateThread(function()
        local timeout = 20000
        local seat_index_order = {2,1,0,3,4,5,6}
        local allPedsEntered = false
        
        while currentCourse and currentCourse.stage == 1 do
            local dist = #(GetEntityCoords(PlayerPedId()) - currentCourse.start)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            
            if DoesEntityExist(vehicle) and dist <= 15.0 and getSpeed(vehicle) < 1.0 then
                local retry = 0
                while retry < 3 and not allPedsEntered do
                    for i,ped in ipairs(currentCourse.peds) do
                        ClearPedTasks(ped)
                        Wait(100)
                        TaskEnterVehicle(ped,vehicle,timeout,seat_index_order[i], 2, 1, 0)
                    end

                    local timeStart = GetGameTimer()
                    while not allPedsEntered and (GetGameTimer() - timeStart < timeout) do
                        allPedsEntered = true
                        for _,ped in ipairs(currentCourse.peds) do
                            if not IsPedInVehicle(ped,vehicle,false) then
                                allPedsEntered = false
                            end
                        end
                        Wait(100)
                    end
                    retry += 1
                end

                if allPedsEntered then
                    currentCourse.stage = 2
                end
            end
            Wait(1000)
        end

        if currentCourse and currentCourse.stage == 2 then
            startDepositListener()
        end
    end)
end

local function createPlayerEnteringThread()
    CreateThread(function()
        local serverEventEmitted = false
        while currentCourse and currentCourse.stage == 1 do
            local dist = getV3ToV2Distance(GetEntityCoords(PlayerPedId()),currentCourse.start)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            
            if DoesEntityExist(vehicle) and dist <= 15.0 and getSpeed(vehicle) < 1.0 then
                if not serverEventEmitted then
                    TriggerServerEvent("jbb:vtc:server:driveratpickup", currentCourse.id)
                    serverEventEmitted = true
                end

                local client = currentCourse.player
                if client then
                    local clientVeh = GetVehiclePedIsIn(NetToPed(currentCourse.playerNetId), false)
                    if clientVeh == vehicle then
                        currentCourse.stage = 2
                    end
                end
            end
            Wait(500)
        end

        if currentCourse and currentCourse.stage == 2 then
            TriggerServerEvent("jbb:vtc:server:clientpickedup", currentCourse.id)
            startDepositListener()
        end
    end)
end

local function startPickupListener()
    if not currentCourse then return end

    CreateThread(function()
        local colorRed = {r=255,g=0,b=0}
        local colorOrange = {r=255,g=180,b=46}
        local colorGreen = {r=0,g=255,b=0}
        while currentCourse and currentCourse.stage == 1 do
            local c = colorRed
            local dist = getV3ToV2Distance(GetEntityCoords(PlayerPedId()),currentCourse.start)
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            --Trying to fix elevation of marker
            local z = currentCourse.start.z
            if dist <= 200 then
                z = getGroundZCoordsOrDefault(currentCourse.start, z)
            end

            if dist <= 15.0 then
                if getSpeed(vehicle) < 1 then
                    c = colorGreen
                else
                    c = colorOrange
                end
            end

            DrawMarker(1, currentCourse.start.x, currentCourse.start.y, currentCourse.start.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 30.0, 30.0, 2.0, c.r, c.g, c.b, 96, false, false, 2, nil, nil, false)
            Wait(0)
        end
    end)

    if currentCourse.player then
        createPlayerEnteringThread()
    else
        createPedsEnteringThread()
    end

end

local function createPedCreateThread()
    if not currentCourse then return end

    local pedsCreated = 0
    CreateThread(function()
        while currentCourse and pedsCreated < currentCourse.pedscount do
            local dist = #(GetEntityCoords(PlayerPedId()) - currentCourse.start)
            
            if dist <= 300 then
                local peds = {}
                for i = 1, currentCourse.pedscount, 1 do
                    local ped = createPedAt(currentCourse.start);
                    SetEntityInvincible(ped, true)
                    SetPedConfigFlag(ped, 118, true) -- Disable "panic"
                    SetPedConfigFlag(ped, 119, true) -- Disable "flee"
                    SetPedConfigFlag(ped, 229, true) -- Disable "DisablePanicInVehicle"
                    SetPedConfigFlag(ped, 294, true) -- Disable "DisableShockingEvents"
                    --TaskSetBlockingOfNonTemporaryEvents(ped,true)
                    peds[i] = ped
                    pedsCreated = pedsCreated + 1
                end
                currentCourse.peds = peds
            end
            Wait(0)
        end
    end)
end

local function assignedCourse(course)
    currentCourse = course
    currentUiCourse = TransformCourse(currentCourse)
    currentCourse.stage = 1
    currentBlip = createBlips(currentCourse.start, "VTC Client pickup", 280, 2, 2, 0.7, false)
    SetBlipRouteColour(currentBlip, 2)
    SetBlipRoute(currentBlip, true)

    if not course.player then
        createPedCreateThread()
    end
    startPickupListener()
end

local function jobDone(peds, coords)
    if not currentCourse or currentCourse.player then return end
    
    --removes peds after a while
    local deleted = false
    CreateThread(function()
        while not deleted do
            local dist = #(GetEntityCoords(PlayerPedId()) - coords)
                
            if dist > 400 then
                for _,p in ipairs(peds) do
                    DeleteEntity(p)
                end
                deleted = true
            end
            Wait(0)
        end
    end)
end

local function startDutyThreads()
    CreateThread(function()
        while onDuty do
            if VtcUiIsDisplayed() then
                VtcUiUpdateDistances(TransformCourseDistances(courses))
            end
            Wait(1000)
        end
    end)
end

local function clearDestinationBlip()
    if not destinationBlip then return end
    RemoveBlip(destinationBlip)
    destinationBlip = nil
end

function CancelVTCCourse()
    if not currentCourse then return end
    if not currentCourse.player then
        askPedsLeaveVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
        setPedsWander(GetEntityCoords(PlayerPedId()))
    end
    RemoveBlip(currentBlip)
    TriggerServerEvent("jbb:vtc:server:cancelled", currentCourse.id)
end

-- EVENTS FOR UVERX DRIVER

RegisterNetEvent("jbb:vtc:client:updateRate", function(course, newRate)
    if not onDuty then return end
    if not currentCourse then return end
    myRate = newRate
    VtcUiUpdateRate(myRate)
end)

RegisterNetEvent("jbb:vtc:client:newcourse", function(course)
    if not onDuty then return end
    if not courses[course.id] and myRate>=course.minRate then
        if GetPlayerVehicleSeatCount() < course.pedscount then return end
        courses[course.id] = course
        VtcUiAddCourse(course)
    end
end)

RegisterNetEvent("jbb:vtc:client:delcourse", function(cid)
    if not onDuty then return end
    if courses[cid] then
        courses[cid] = nil
        VtcUiDelCourse(cid)
    end
end)

RegisterNetEvent("jbb:vtc:client:startcourse", function(course)
    if not onDuty then return end
    if  myRate>=course.minRate then
        assignedCourse(course)
        ToggleUiDisplay(false)
        VtcUiUpdateCurrent(currentUiCourse)
        VtcUiShowCurrent(true)
    end
end)

RegisterNetEvent("jbb:vtc:client:jobdone", function(course, newRate)
    if not onDuty then return end
    if not currentCourse then return end
    myRate = newRate
    jobDone(currentCourse.peds, currentCourse.destination)
    currentCourse = nil
    currentUiCourse = nil
    VtcUiUpdateRate(myRate)
    ToggleUiDisplay(true)
    VtcUiShowCurrent(false)
    VtcUiHideClientInfos()
end)

RegisterNetEvent("jbb:vtc:client:jobcancelled", function(course)
    if not onDuty then return end
    if not currentCourse then return end
    jobDone(currentCourse.peds, currentCourse.destination)
    currentCourse = nil
    currentUiCourse = nil
    ToggleUiDisplay(true)
    VtcUiShowCurrent(false)
    VtcUiHideClientInfos()
end)

RegisterNetEvent("jbb:vtc:client:onduty", function(rate)
    if onDuty then return end
    onDuty = true
    myRate = rate
    currentCourse = nil
    currentUiCourse = nil
    startDutyThreads()
    ToggleUiDisplay(true)
    VtcUiUpdateRate(myRate)
    VtcUiShowCurrent(false)
end)

RegisterNetEvent("jbb:vtc:client:offduty", function()
    if not onDuty then return end
    onDuty = false
    myRate = 0.0
    currentCourse = nil
    currentUiCourse = nil
    ToggleUiDisplay(false)
    VtcUiShowCurrent(false)
    VtcUiHideClientInfos()
end)

RegisterCommand('jbb-vtc', function()
    if not currentCourse or not onDuty then ToggleUiDisplay(true) end
    if currentCourse then VTCUiSetFocus(true) end
end)
RegisterKeyMapping('jbb-vtc', 'Open UverX', 'keyboard', 'F5')

-- EVENT FOR PLAYER ASKING A DRIVE
RegisterNetEvent("jbb:vtc:client:timeout", function()
    clearDestinationBlip()
    VtcUiClientTimeout()
    Jbb.Notify("No driver were available", "error", 3000)
end)

AddEventHandler("jbb:vtc:client:registerForDrive", function(data)
    local zPickup = getGroundZCoordsOrDefault(vector3(data.pickup.x, data.pickup.y, 200), data.pickup.z)
    local zDest = getGroundZCoordsOrDefault(vector3(data.destination.x, data.destination.y, 200), data.destination.z)
    data.pickup = vector3(data.pickup.x, data.pickup.y, zPickup)
    data.destination = vector3(data.destination.x, data.destination.y, zDest)
    DeleteWaypoint()
    destinationBlip = createBlips(data.destination, "Destination UverX", 162, 27, 2, 1.0, false)
    TriggerServerEvent("jbb:vtc:server:addPlayerCourse", data)
end)

RegisterNetEvent("jbb:vtc:client:driverassigned", function(data)
    driver = data
    VTCUiDriverFound(driver)
    driverBlip = createBlips(data.coords, ("UverX - %s"):format(driver.name), 782, 69, 2, 0.9, false)
    Jbb.Notify(("UverX : %s is on his way"):format(data.name), "success", 3000)
end)

RegisterNetEvent("jbb:vtc:client:updateDriverPosition", function(coords)
    if not driverBlip or not driver then return end
    driver.coords = coords
    SetBlipCoords(driverBlip, coords.x, coords.y, coords.z)
end)

RegisterNetEvent("jbb:vtc:client:driverhere", function()
    VTCUiDriverHere()
end)

RegisterNetEvent("jbb:vtc:client:driverprogress", function()
    if not driverBlip or not driver then return end
    RemoveBlip(driverBlip)
    driverBlip = nil
    VTCUiDriverProgress()
end)

RegisterNetEvent("jbb:vtc:client:driverarrived", function()
    VTCUiDriverArrived()
end)

RegisterNetEvent("jbb:vtc:client:clientdone", function(infos)
    clearDestinationBlip()
    VtcUiAskRate(infos)
end)

RegisterNetEvent("jbb:vtc:client:clientcancelled", function()
    clearDestinationBlip()
    VTCUiClientReset()
end)

RegisterNetEvent("jbb:vtc:client:notenoughmoney", function(price)
    Jbb.Notify(("You need at least %s on your bank account"):format(tostring(price)), "error", 5000)
    clearDestinationBlip()
    VTCUiClientReset()
end)

AddEventHandler("onResourceStart", function(r)
	if r == GetCurrentResourceName() then
        --loadPedsModelHashes() -- Activate on dev env to generate all peds model hashes
		VTCUiSetFocus(false)
	end
end)
AddEventHandler("onResourceStop", function(r)
	if r == GetCurrentResourceName() then
		VTCUiSetFocus(false)
	end
end)
