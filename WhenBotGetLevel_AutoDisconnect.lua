local targetLevel = 12

local bot = getBot()
if bot == nil then
    print("Bot not found")
    return
end

print("Monitoring level... target: " .. targetLevel)

while true do
    local level = bot.level
    if level ~= nil and level >= targetLevel then
        bot.auto_reconnect = false
        bot:disconnect()
        print("Level " .. level .. " tercapai — bot disconnected.")
        break
    end
    sleep(500) -- fix #2: cek lebih sering biar gak kelewat level
end
