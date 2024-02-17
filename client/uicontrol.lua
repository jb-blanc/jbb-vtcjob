local displayed = false
local hasFocus = false
--UI FUNCTIONS

function TransformCourse(source)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local pickupDist = CalculateTravelDistanceBetweenPoints(
		playerCoords.x,
		playerCoords.y,
		playerCoords.z,
		source.start.x,
		source.start.y,
		source.start.z
	)
    local tripDist = CalculateTravelDistanceBetweenPoints(
		source.destination.x,
		source.destination.y,
		source.destination.z,
		source.start.x,
		source.start.y,
		source.start.z
	)

    if pickupDist >= 100000.0 then
        pickupDist = #(playerCoords - source.start)
    end
    if tripDist >= 100000.0 then
        tripDist = #(source.destination - source.start)
    end

    local streetPick, _ = GetStreetNameAtCoord(source.start.x, source.start.y, source.start.z)
    local streetDest, _ = GetStreetNameAtCoord(source.destination.x, source.destination.y, source.destination.z)
    local streetPickName = GetStreetNameFromHashKey(streetPick)
    local streetDestName = GetStreetNameFromHashKey(streetDest)
    
    local data = {
        id=source.id,
        player=source.player,
        pcount=source.pedscount,
        reward=source.reward,
        distance=tripDist/1000,
        pickDistance=pickupDist/1000,
        pickup=streetPickName,
        destination=streetDestName
    }

    return data
end

function TransformCourseDistances(courses)
    local data = {}
    local playerCoords = GetEntityCoords(PlayerPedId())
    for cid,source in pairs(courses) do
        local pickupDist = CalculateTravelDistanceBetweenPoints(
            playerCoords.x,
            playerCoords.y,
            playerCoords.z,
            source.start.x,
            source.start.y,
            source.start.z
        )

        if pickupDist >= 100000.0 then
            pickupDist = #(playerCoords - source.start)
        end

        data[#data+1] = {
            id=cid,
            pickDistance=pickupDist/1000
        }
    end

    return data
end

function VtcUiIsDisplayed()
    return displayed
end

function AskPlayerForCoords()
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_MP_PAUSE'), false, -1)
    Wait(100)
    PauseMenuceptionGoDeeper(0)
    local cancel = false
    while GetFirstBlipInfoId( 8 ) == 0 and not cancel do
        if IsControlJustPressed(0, 202) or IsControlJustPressed(0, 200)  then -- ESC/BACK
            cancel = true
        end
        Citizen.Wait(10)
    end
    PauseMenuceptionTheKick()
    SetFrontendActive(false)

    if not cancel then 
        local waypointBlip = GetBlipCoords(GetFirstBlipInfoId(8))
        return vector3(waypointBlip.x, waypointBlip.y, waypointBlip.z)
    end
    return nil
end

function VtcUiUpdateCurrent(currentUiCourse)
    SendNUIMessage({
        type = "jbb:vtc:ui:start",
        course = currentUiCourse
    })
end

function VtcUiShow(show)
    SendNUIMessage({
        type = "jbb:vtc:ui:showliste",
        show = show
    })
end

function VtcUiShowCurrent(show)
    SendNUIMessage({
        type = "jbb:vtc:ui:showcurrent",
        show = show
    })
end

function VtcUiAddCourse(course)
    SendNUIMessage({
        type = "jbb:vtc:ui:addcourse",
        course = TransformCourse(course)
    })
end

function VtcUiDelCourse(cid)
    SendNUIMessage({
        type = "jbb:vtc:ui:delcourse",
        cid = cid
    })
end

function VtcUiUpdateSatisfaction(satisfaction)
    SendNUIMessage({
        type = "jbb:vtc:ui:updatesatisfaction",
        satisfaction = satisfaction
    })
end

function VtcUiUpdateDistances(courses)
    SendNUIMessage({
        type = "jbb:vtc:ui:updatedistances",
        courses = courses
    })
end

function VtcUiUpdateRate(rate)
    SendNUIMessage({
        type = "jbb:vtc:ui:updaterate",
        rate = rate
    })
end

function VtcUiClientTimeout()
    SendNUIMessage({
        type = "jbb:vtc:ui:timeout"
    })
end

function ToggleUiDisplay(override)
    displayed = not displayed
    if override ~= nil then displayed = override end
    VTCUiSetFocus(displayed)
    VtcUiShow(displayed)
end

function VTCUiSetFocus(focus)
    hasFocus = focus
    SetNuiFocus(focus, focus)
end

function VTCUiDriverFound(data)
    SendNUIMessage({
        type = "jbb:vtc:ui:driverfound",
        driver = data
    })
end

function VTCUiDriverHere()
    SendNUIMessage({
        type = "jbb:vtc:ui:driverhere"
    })
end

function VTCUiDriverProgress()
    SendNUIMessage({
        type = "jbb:vtc:ui:driverprogress"
    })
end

function VTCUiDriverArrived()
    SendNUIMessage({
        type = "jbb:vtc:ui:driverarrived"
    })
end

function VTCUiClientReset()
    SendNUIMessage({
        type = "jbb:vtc:ui:clientreset"
    })
end

function VtcUiUpdateClientInfos(txdString, course)
    local clientInfos = {}

    if course.minSpeed < 999 then
        clientInfos[#clientInfos+1] = ("I'm in a hurry ! Go at <b>%d</b> %s minimum"):format(course.minSpeed, Config.VTC.general.speed_unit)
    end
    if course.maxSpeed < 999 then
        clientInfos[#clientInfos+1] = ("Please don't go over <b>%d</b> %s"):format(course.maxSpeed, Config.VTC.general.speed_unit)
    end
    if course.wantMusic then
        if course.radioStation == "WHATEVER" then
            clientInfos[#clientInfos+1] = "I need some music !"
        else
            clientInfos[#clientInfos+1] = ("Can you put the station <b>%s</b> ?"):format(GetLabelText(course.radioStation))
        end
    else
        clientInfos[#clientInfos+1] = "I need calm, turn the radio off !"
    end

    -- Send the txdString to NUI
    SendNUIMessage({
        type = 'jbb:vtc:ui:pedmugshot',
        txdString = txdString,
        infos = clientInfos
    })
end

function VtcUiHideClientInfos()
    -- Send the txdString to NUI
    SendNUIMessage({
        type = 'jbb:vtc:ui:hideclientinfos',
        txdString = txdString,
        infos = clientInfos
    })
end
--NUI Callbacks 
RegisterNUICallback('jbb:vtc:client:ui:accept', function(data, cb)
    -- POST data gets parsed as JSON automatically
    local cid = data.cid
    if CanStartCourse(cid) then 
        TriggerServerEvent("jbb:vtc:server:takecourse", cid)
        cb({success=true})
    else
        cb({success=false})
    end
end)

RegisterNUICallback('jbb:vtc:client:ui:cancel', function(data, cb)
    CancelVTCCourse()
    VTCUiSetFocus(false)
    cb(cid)
end)

RegisterNUICallback('jbb:vtc:client:ui:hide', function(data, cb)
    ToggleUiDisplay()
    cb({ok=true})
end)

RegisterNUICallback('jbb:vtc:client:ui:releasefocus', function(data, cb)
    VTCUiSetFocus(false)
    cb({ok=true})
end)

RegisterNUICallback('jbb:vtc:client:ui:askcoords', function(data, cb)
    DeleteWaypoint()
    VTCUiSetFocus(false)
    local coords = AskPlayerForCoords()

    if coords then 
        Wait(10)
        local pickup = GetEntityCoords(PlayerPedId())
        local location,_ = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
        local distance = CalculateTravelDistanceBetweenPoints(pickup.x, pickup.y, pickup.z, coords.x, coords.y, coords.z)
        
        if distance >= 100000.0 then
            distance = #(pickup - coords)
        end

        local price = math.ceil(distance * Config.VTC.generator.money_per_meter)

        cb({
            success = true, 
            pickup = json.decode(json.encode(pickup)),
            destination = json.decode(json.encode(coords)),
            location = location,
            distance = distance,
            price = price,
        })
    else
        cb({success=false})
    end
    VTCUiSetFocus(true)
end)

RegisterNUICallback('jbb:vtc:client:ui:askcourse', function(data, cb)
    TriggerEvent("jbb:vtc:client:registerForDrive", data)
    cb({success=true})
end)

RegisterNUICallback('jbb:vtc:client:ui:changedMode', function(data, cb)
    TriggerServerEvent("jbb:vtc:server:changeDuty", data)
    cb({success=true})
end)