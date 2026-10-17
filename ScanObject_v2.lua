local bot = getBot()
local world = bot and bot:getWorld()

if world == nil then
    print("Bot tidak berada di world")
    return
end

for _, obj in pairs(world:getObjects()) do
    print(string.format("Item ID: %d | OID: %d | Count: %d | Position: %d, %d",
        obj.id, obj.oid, obj.count or 1, obj.x, obj.y))
end
