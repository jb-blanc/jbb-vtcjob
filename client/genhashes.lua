local pedsNameLoaded = false


-- Function to generate ped model hashes to be easily retrieved for playing sounds
local function loadPedsModelHashes()
    if pedsNameLoaded then return end
    CreateThread(function()
        local strHashes = ""
        for _,modelHash in ipairs(Config.VTC.generator.peds_model) do
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Wait(0)
            end
            local e = CreatePed(1, modelHash, 0.0, 0.0, 0.0, 0.0, false, false)
            local entityModel = GetEntityModel(e)
            DeleteEntity(e)
            -- when done using the model
            SetModelAsNoLongerNeeded(modelHash)
            strHashes = strHashes .. '['..tostring(entityModel)..'] = "'..modelHash..'",\n'
        end
        pedsNameLoaded = true
        TriggerServerEvent("jbb:vtc:server:filehashes", strHashes)
    end)
end

RegisterCommand('jbb-genhashes', function()
    loadPedsModelHashes()
end)
