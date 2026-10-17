local bot = getBot()

local ITEM_ID = ITEM_ID

local WORLD_TAKE = {
    world = "TAKEWORLD",
    door = "IDDOOR"
}

local WORLD_DROP = {
    world = "DROPWORLD",
    door = "IDDOOR"
}

function main()
    local count = bot:getInventory():findItem(ITEM_ID)

    if count <= 200 then
        bot:warp(WORLD_TAKE.world, WORLD_TAKE.door)
        sleep(3000)

        bot.auto_collect = true

        repeat
            bot:collectByID(ITEM_ID)
            sleep(5000)

            count = bot:getInventory():findItem(ITEM_ID)
        until count >= 200

    else
        bot:warp(WORLD_DROP.world, WORLD_DROP.door)
        sleep(3000)

        bot.auto_collect = false

        repeat
            bot:drop(ITEM_ID, 200)
            sleep(3000)

            bot:moveRight(1)
            sleep(2000)

            count = bot:getInventory():findItem(ITEM_ID)
        until count <= 0
    end
end

while true do
    main()
    sleep(1000)
end