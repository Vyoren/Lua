local growscan = getBot():getWorld().growscan

if growscan == nil then
    print("Growscan tidak tersedia di world ini")
    return
end

for id, amount in pairs(growscan:getObjects()) do
    print("[" .. id .. "] Found " .. amount .. "x " .. getInfo(id).name .. ".")
end
