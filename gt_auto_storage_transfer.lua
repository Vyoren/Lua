items = {100, 200, 300}

storages = {
  "STORAGE100|DOOR1",
  "STORAGE200|DOOR2",
  "STORAGE300|DOOR3",
}

worlds = {
  "WORLD1|idDoor1",
  "WORLD2|idDoor2",
  "WORLD3|idDoor3",
}

loopMode = true

log = getBot():getLog()
takeObj = 1
worldSort = 1
getBot().auto_transfer.enabled = true

function seperate(s)
  local sep = s:match("[|:]") -- ambil separator pertama (| atau :)
  if not sep then return { name = string.upper(s), id = "" } end
  return {
    name = string.upper(s:match("(.-)" .. sep)),
    id   = s:match(sep .. "(.+)"),
  }
end

function getCurrentWorld()   return seperate(worlds[worldSort])  end
function getCurrentStorage() return seperate(storages[takeObj])  end

-- fix #2: hitung di world DAN di inventory
function countItem(id)
  local total = 0
  for _, obj in pairs(getObjects()) do
    if obj.id == id then total = total + (obj.count or 1) end
  end
  for _, inv in pairs(getBot():getInventory()) do
    if inv.id == id then total = total + (inv.count or 1) end
  end
  return total
end

-- fix minor: return false kalau sudah selesai semua (loopMode = false)
function nextItem()
  if takeObj < #items then
    takeObj = takeObj + 1
  else
    takeObj = 1
    if worldSort < #worlds then
      worldSort = worldSort + 1
    elseif loopMode then
      worldSort = 1
    else
      return false
    end
  end
  return true
end

function checkWorld()
  local w  = getCurrentWorld()
  local st = getCurrentStorage()

getBot().auto_transfer.input  = w.name .. "|" .. w.id
  getBot().auto_transfer.output = st.name .. "|" .. st.id
  getBot().auto_transfer.itemid = items[takeObj]

local n = countItem(items[takeObj])
  log:append(("[%d/%d] %s -> %s : %dx"):format(
    worldSort, #worlds, getInfo(items[takeObj]).name, st.name, n))

if n == 0 then return nextItem() end
  return true
end

while true do
  local w = getCurrentWorld()

-- fix #1 & #3: tunggu BENAR-BENAR masuk world sebelum count
  if not getBot():isInWorld(w.name) then
    getBot():warp(w.name)
    while not getBot():isInWorld(w.name) do sleep(500) end
    sleep(1000) -- kasih waktu objek world load
  end

if not checkWorld() then break end -- selesai semua kalau loopMode = false

sleep(1500)
end
