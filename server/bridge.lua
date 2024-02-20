local Jbb = {}

function getInstance()
    if Config.framework == "ESX" then
        ESX = exports["es_extended"]:getSharedObject()
        Jbb.isESX = true
    else
        QBCore = exports['qb-core']:GetCoreObject()
        RegisterNetEvent('QBCore:Server:UpdateObject', function()
            if source ~= '' then return false end
            QBCore = exports['qb-core']:GetCoreObject()
        end)
        Jbb.isQB = true
    end

    return Jbb
end
exports("getInstance", getInstance)

function Jbb.CreateCallback(event, callback)
    if Jbb.isESX then 
        ESX.RegisterServerCallback(event, callback)
    elseif Jbb.isQB then
        QBCore.Functions.CreateCallback(event, callback)
    else
        return false
    end
end

function Jbb.GetPlayer(source)
    if Jbb.isESX then 
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.PlayerData = {
            source = source,
            citizenid = xPlayer.getIdentifier(),
            job = {
                name = xPlayer.getJob()?.name or 'unknown'
            },
            charinfo = {
                firstname = xPlayer.getName()
            }
        }
        xPlayer.Functions = {
            AddMoney = function(account, money, _) xPlayer.addAccountMoney(account, money) end,
            RemoveMoney = function(account, money, _) xPlayer.removeAccountMoney(account, money) end,
            GetMoney = function(account) return xPlayer.getAccount(account)?.money end,
        }
        return xPlayer
    elseif Jbb.isQB then
        return QBCore.Functions.GetPlayer(source)
    else
        return false
    end
end

function Jbb.Notify(source, message, genre, time)
    if Jbb.isESX then 
        TriggerClientEvent("esx:showNotification", source, message, genre, time)
    elseif Jbb.isQB then
        QBCore.Functions.Notify(source, message, genre, time)
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

function Jbb.GetJobLabel(job)
    if Jbb.isESX then 
        return ESX.GetJobs()[job]?.label or 'unknown'
    elseif Jbb.isQB then
        return QBCore.Shared.Jobs[job].label
    else
        return false
    end
end

function Jbb.GetItemLabel(item)
    if Jbb.isESX then 
        return ESX.GetItemLabel(item)
    elseif Jbb.isQB then
        return QBCore.Shared.Items[item].label
    else
        return false
    end
end