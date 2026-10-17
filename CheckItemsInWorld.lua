itemlist = {3}

function scan(id)
    local total = 0
    for _, obj in pairs(getBot():getWorld():getObjects()) do
        if obj.id == id then
            total = total + obj.count
        end
    end
    print("\n[" .. getInfo(id).name .. "] : " .. total)
end


    for _, id in ipairs(itemlist) do
        scan(id)
    end