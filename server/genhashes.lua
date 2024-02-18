local QBCore = exports['qb-core']:GetCoreObject()

--Saving peds hashes file
RegisterNetEvent('jbb:vtc:server:filehashes', function(strHashes)
    local file = io.open("peds_hashes.txt", "w+")
    file:write(strHashes)
    file:close()
    QBCore.Functions.Notify(source, "Ped Hashes generated", "success", 5000)
end)


RegisterNetEvent('QBCore:Server:UpdateObject', function()
	if source ~= '' then return false end
	QBCore = exports['qb-core']:GetCoreObject()
end)