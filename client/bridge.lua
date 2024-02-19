local Jbb = {}

function getInstance()
    if Config.framework == "ESX" then
        ESX = exports["es_extended"]:getSharedObject()
        Jbb.isESX = true
    else
        QBCore = exports['qb-core']:GetCoreObject()
        RegisterNetEvent('QBCore:Client:UpdateObject', function()
            QBCore = exports['qb-core']:GetCoreObject()
        end)
        Jbb.isQB = true
    end
    return Jbb
end
exports("getInstance", getInstance)

function Jbb.TriggerCallback(event, callback, ...)
    if Jbb.isESX then
        ESX.TriggerServerCallback(event, callback, ...)
    elseif Jbb.isQB then
        QBCore.Functions.TriggerCallback(event, callback, ...)
    else
        return false
    end
end

function Jbb.Notify(message, genre, time)
    if Jbb.isESX then
        ESX.ShowNotification(message, genre, time)
    elseif Jbb.isQB then
        QBCore.Functions.Notify(message, genre, time)
    else
        return false
    end
end

function Jbb.HasItem(source, item, count)
    if Jbb.isESX then 
        local xPlayer = ESX.GetPlayerFromId(source)
        local item = xPlayer.hasItem(item)
        return item and item.count >= count
    elseif Jbb.isQB then
        return QBCore.Functions.HasItem(source, item, count)
    else
        return false
    end
end
