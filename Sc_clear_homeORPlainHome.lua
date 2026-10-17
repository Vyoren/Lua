webhook = ""

function sendWebhook(text)
    webhook = Webhook.new(webhook)
    webhook.username = ":information_source: Logs"
    webhook.content = text
    webhook:send()
end


for _, tile in pairs(getTiles()) do
    if tile.fg == 2 or tile.fg == 4 or tile.fg == 8 or tile.fg == 10 and getBot():getWorld().name:lower() ~= "exit" then
        if #getBot():getPath(tile.x,tile.y-1) then
            getBot():findPath(tile.x,tile.y-1)
            while getTile(tile.x,tile.y).bg ~= 0 and getTile(tile.x,tile.y).fg ~= 8 and getTile(tile.x,tile.y) ~= 3760 do
                getBot():hit(tile.x,tile.y)
                sleep(math.random(100,120))
            end
            while getTile(tile.x,tile.y+1).bg ~= 0 and getTile(tile.x,tile.y+1).fg ~= 8 and getTile(tile.x,tile.y+1) ~= 3760 do
                getBot():hit(tile.x,tile.y+1)
                sleep(math.random(100,120))
            end
        end
    end
if getBot().level == 7 then
getBot():stopScript()
end
end

sendWebhook("Cleared world : " .. getBot():getWorld().name)