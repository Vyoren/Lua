worlds = {"name world"}
breakBlocks = {242, 226, 202}
----- ===== Script below, don't touch ==== ----
worldCount = 1
blacklisted = {}

function isActive()
  return getBot().status == BotStatus.online
end

function checkBlocks()
  local count = 0
  blacklisted = {}
  for _, tile in pairs(getTilesSafe()) do
    for _, blacklist in pairs(breakBlocks) do
      if tile.fg == blacklist or tile.bg == blacklist then
        if getBot():isInTile(tile.x, tile.y - 1) or #getBot():getPath(tile.x, tile.y - 1) > 0 then
            count = count + 1
            table.insert(blacklisted, tile)
        end
      end
    end
  end
  return count == 0
end

function breakBlacklist()
  for _, tile in pairs(blacklisted) do
    if (getTile(tile.x, tile.y).fg == tile.fg and tile.fg ~= 0) or (getTile(tile.x, tile.y).bg == tile.bg and tile.bg ~= 0) then
      while not getBot():isInTile(tile.x, tile.y - 1) and #getBot():getPath(tile.x, tile.y - 1) > 0 and isActive() do
        getBot():findPath(tile.x, tile.y - 1)
        sleep(150)
      end
      while (getTile(tile.x, tile.y).fg == tile.fg and tile.fg ~= 0) or (getTile(tile.x, tile.y).bg == tile.bg and tile.bg ~= 0) and getBot():isInTile(tile.x, tile.y - 1) and isActive() do
        sleep(200)
        getBot():hit(tile.x, tile.y)
      end
    end
  end
end

while true do
  while not getBot():isInWorld(string.upper(worlds[worldCount])) and isActive() do
    getBot():warp(string.upper(worlds[worldCount]))
    sleep(6000)
  end
  if not checkBlocks() and isActive() then
    breakBlacklist()
  elseif checkBlocks() and isActive() then
    worldCount = worldCount + 1
    print(worldCount, #worlds)
    if worldCount > #worlds then
      print("Reached final world, stopping script.")
      getBot():warp("EXIT")
      getBot():stopScript()
    end
  else
    print("Failed to check blocks in worlds... Waiting until bot is online.")
    while not isActive() do
      sleep(500)
    end
  end
end