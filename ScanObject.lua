local bot = getBot()
local world = bot:getWorld()

for i, obj in pairs(world:getObjects()) do
    -- obj.id   -> Item ID (e.g., World Lock = 242)
    -- obj.oid  -> Unique Object ID of the dropped item
    -- obj.count-> Item quantity
    -- obj.x, obj.y -> Coordinates
    
    print(string.format("Item ID: %d | Object ID (OID): %d | Count: %d | Position: %d, %d", 
        obj.id, obj.oid, obj.count, obj.x, obj.y))
end
