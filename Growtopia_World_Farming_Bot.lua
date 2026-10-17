local bot = getBot()
if bot == nil then return end

local rawWorlds = [[
SUKSES:2026
LANCAR:2026
REZEKI:2026
SEMOGA:2026
KUKUKU:2026
GAGAGA:2026
JAJAJAJA:2026
]]

worldList = {}
for line in rawWorlds:gmatch("[^\r\n]+") do
    local name = line:match("^%s*(.-)%s*:") or line:match("^%s*(.-)%s*$")
    if name and name ~= "" then
        table.insert(worldList, name)
    end
end

targetIds = {226, 202, 12, 242}

function isTarget(id)
    for _, tid in ipairs(targetIds) do
        if id == tid then return true end
    end
    return false
end

while true do
    for _, worldName in ipairs(worldList) do
        bot:warp(worldName)
        sleep(4000)

        local tiles = bot:getWorld():getTilesSafe()
        for _, tile in ipairs(tiles) do
            if isTarget(tile.fg) then
                local path = bot:getPath(tile.x, tile.y - 1)
                if path and #path > 0 then
                    bot:findPath(tile.x, tile.y - 1)
                    while isTarget(getTile(tile.x, tile.y).fg) do
                        bot:hit(tile.x, tile.y)
                        sleep(math.random(100, 120))
                    end
                    bot:collect(2)
                end
            end
        end
    end
end