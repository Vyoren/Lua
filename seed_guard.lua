local SEED_ID = 4584
local bot = getBot()

-- return true kalau masih ada seed di world, false kalau habis
local function hasSeed()
    local world = bot:getWorld()
    if world == nil then return false end

for _, obj in pairs(world:getObjects()) do
        if obj.id == SEED_ID and (obj.count or 1) > 0 then
            return true
        end
    end
    return false
end

-- loop monitor (fix #3): cek berkala sampai seed habis
while true do
    if hasSeed() then
        print("Have seed")
    else
        bot.auto_plant.enabled = false
        print("No more seed in world")
        break
    end
    sleep(1000)
end
