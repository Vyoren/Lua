--[[
  FarmChecker v2
  ------------------------------
  Fungsi  : Otomatis memeriksa isi farm dari daftar world (farmlist),
            menghitung jumlah tile item tertentu (idList) yang dapat
            diakses (accessible), lalu menyimpan hasilnya ke farmList.txt.
  Fitur   : - Auto-warp dengan validasi world (exact match)
            - Deteksi world nuked / kunci level
            - Deteksi ID pintu salah (format: "world|id")
            - Anti infinite-loop (batas percobaan warp)
            - Hanya menghitung tile yang punya akses
  Output  : farmList.txt
  Catatan : Isi farmlist dan idList sebelum menjalankan.
]]
farmlist = {
  -- isi daftar world, contoh: "TARGETWORLD" atau "TARGETWORLD|ID"
}

idList = {
  3005
}

nuked = false
t = 0

addEvent(Event.variantlist, function(variant, netid)
  if variant:get(0):getString() == "OnConsoleMessage" then
    local msg = variant:get(1):getString():lower()
    if msg:find("inaccessible") or msg:find("level ") then
      nuked = true
      if farmlist[t] then                              -- FIX #1: guard nil
        writeFile("(Nuked or Level higher) " .. farmlist[t])
      end
    end
  end
end)

function checkItems(id)
  local count = 0
  for _, tile in pairs(getTiles()) do
    if tile.fg == id and hasAccess(tile.x, tile.y) > 0 then
      count = count + 1
    end
  end
  return count
end

openedBefore = false
function writeFile(text)
  if not openedBefore then
    openedBefore = true
    return write("farmList.txt", text)
  end
  append("farmList.txt", text)
end

-- ambil nama world saja dari entry "world" / "world|id"
local function worldNameOf(entry)
  return entry:match("^(.-)|") or entry
end

for i = 1, #farmlist do
  t = i
  nuked = false                                        -- FIX #5: reset per iterasi
  local entry = farmlist[i]
  local worldName = worldNameOf(entry):lower()
  local hasID = entry:find("|", 1, true) ~= nil

-- Loop 1: warp sampai BENAR-BENAR berada di world tujuan (exact match)
  local tries = 0
  while not nuked and getBot():getWorld().name:lower() ~= worldName do
    if tries >= 30 then                                -- FIX #3: anti infinite loop
      nuked = true
      writeFile("(Stuck warp / gagal masuk) " .. entry)
      break
    end
    getBot():warp(entry)
    listenEvents(8)
    tries = tries + 1
  end

-- Loop 2: kalau pakai ID, cek tidak mendarat di main door (fg 6)
  if hasID and not nuked then
    local idChecked = 0
    while getTile(getBot().x, getBot().y).fg == 6 and not nuked do
      if idChecked >= 10 then                          -- FIX #4: cek dulu, baru warp
        nuked = true
        writeFile("(Wrong ID?) " .. entry)
        break
      end
      getBot():warp(entry)
      listenEvents(8)
      idChecked = idChecked + 1
    end
  end

-- Hitung & log hasil
  if getBot():isInWorld() and not nuked then
    local data = ""                                    -- FIX #5: lokal
    for q = 1, #idList do
      data = data .. string.format("Name : %s , Count : %s\n",
        getInfo(idList[q]).name, checkItems(idList[q]))
    end
    writeFile(string.format("World Name : %s\nData : \n%s", entry, data))
  end
end
