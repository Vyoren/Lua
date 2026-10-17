local targetLevel = 12

local bot = getBot()
while true do
    if bot.level >= targetLevel then 
        bot.auto_reconnect = false
        bot:disconnect()
        break
    end
    sleep(3000)
end