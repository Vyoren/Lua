local TARGET_WORLD = "NameWorld"
local DOOR_ID = "12345"
local LOCK_ID = 242

local bot = getBot()

if not bot then return end

while not bot:isInWorld(TARGET_WORLD:upper()) do
    if DOOR_ID ~= "" then
        bot:warp(TARGET_WORLD, DOOR_ID)
    else
        bot:warp(TARGET_WORLD)
    end
    sleep(5000)
end

sleep(1000)

local currentWorld = bot:getWorld()
if currentWorld then
    local objects = currentWorld:getObjects()
    if objects then
        for _, obj in pairs(objects) do
            if obj and obj.id == LOCK_ID then
                local tileX = math.floor(obj.x / 32)
                local tileY = math.floor(obj.y / 32)
                bot:findPath(tileX, tileY)
                break
            end
        end
    end
end