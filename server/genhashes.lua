
--Saving peds hashes file
RegisterNetEvent('jbb:vtc:server:filehashes', function(strHashes)
    local file = io.open("peds_hashes.txt", "w+")
    file:write(strHashes)
    file:close()
end)
