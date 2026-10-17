bot = getBot()

-- KONFIGURASI
gautWorld = "NAMA WORLD GAUT"   -- world tempat gaut (bot ke sini dulu)
gautDoor  = "DOOR ID WORLD GAUT"   -- door ID world gaut
storage   = "WORLD U"   -- world storage (tujuan drop)
storageid = "DOOR ID "   -- door ID world storage
dropX, dropY = nil, nil -- posisi drop di world storage (koordinat findPath, 0-based); nil = tidak pindah

-- item ID tile gaut -> nama dialog mesin (ganti ID kalau beda)
dialogOf = {
  [6946] = "itemsucker_seed",   -- Gaia
  [6948] = "itemsucker_block",  -- UT
}

blockID  = 4584
seedID   = blockID + 1  -- jangan diubah
retrieveCount = 200     -- jumlah diminta per mesin (kalau stok mesin < ini, hasilnya bisa 0 utk item itu -- normal, tetep lanjut ke drop)
errorRetryDelay = 10000 -- jeda kalau siklus error/exception (ms)
noItemCooldown = 60000  -- kalau hasil retrieve BENERAN 0 semua (block+0 DAN seed+0, gak ada progress sama
                         -- sekali), berarti mesin belum sempat ngisi -- tunggu segini (ms) sebelum coba lagi.
                         -- Kalau salah satu item masih dapet (mis. "block+0 | seed+200"), TIDAK nunggu,
                         -- langsung lanjut ke drop kayak biasa. Naikkan angka ini kalau masih sering +0/+0.

-- set true sementara buat debug: nge-print semua dialog/packet mentah dari server
debugRawDialog = false

function glog(msg)
  print("[GAUT] " .. tostring(msg))
end

if debugRawDialog then
  addEvent(Event.variantlist, function(variant, netid)
    local ok0, name = pcall(function() return variant:get(0):getString() end)
    if not ok0 then return end
    if name:lower():find("dialog") or name:lower():find("console") then
      local ok1, txt = pcall(function() return variant:get(1):getString() end)
      if ok1 then
        glog("RAW >> [" .. name .. "] " .. tostring(txt))
      end
    end
  end)
end

-- hitung item di inventory; tidak pernah melempar error
function countItem(id)
  local tries = {
    function() return bot:getInventory():findItem(id) end,
    function() return bot:getInventory():getItemCount(id) end,
    function() local it = bot:getInventory():getItem(id); return it.count or it.amount end,
  }
  for _, f in ipairs(tries) do
    local ok, n = pcall(f)
    if ok and type(n) == "number" then return n end
  end
  return 0
end

function warpTo(name, door)
  for i = 1, 5 do
    bot:warp(name, door)
    sleep(5000)
    if bot:isInWorld(name) then return true end
  end
  return false
end

-- ambil isi mesin gaut: wrench, dialog retrieve, dialog jumlah
function ambilDariMesin(tile, dialog)
  bot:findPath(tile.x, tile.y - 1)   -- berdiri tepat di atas mesin
  sleep(1000)
  bot:wrench(tile.x, tile.y)         -- koordinat absolut; kalau relatif, ganti (0, 1)
  sleep(2000)
  bot:sendPacket(2, "action|dialog_return\ndialog_name|" .. dialog ..
    "\ntilex|" .. tile.x ..
    "\ntiley|" .. tile.y ..
    "\nbuttonClicked|retrieveitem" ..
    "\nchk_enablesucking|1")
  sleep(3000)
  bot:sendPacket(2, "action|dialog_return\ndialog_name|itemremovedfromsucker" ..
    "\ntilex|" .. tile.x ..
    "\ntiley|" .. tile.y ..
    "\nitemtoremove|" .. retrieveCount)
  sleep(3000)
end

-- kumpulkan semua mesin gaut di world sekarang, lalu ambil isinya satu per satu.
-- catatan: kalau stok mesin < retrieveCount, hasil retrieve utk item itu bisa +0 --
-- itu normal (bukan gagal/error), lanjut aja ke drop apapun yang berhasil didapat.
-- return: gainedBlock, gainedSeed (angka, bisa 0) -- atau nil kalau gak ada mesin ditemukan sama sekali.
function ambilSemuaMesin()
  local machines = {}
  for _, tile in pairs(bot:getWorld():getTiles()) do
    local dialog = dialogOf[tile.fg]
    if dialog then
      machines[#machines + 1] = { tile = tile, dialog = dialog }
    end
  end
  glog("mesin gaut ditemukan: " .. #machines)
  if #machines == 0 then
    glog("tidak ada tile gaut di world ini, cek gautWorld dan isi dialogOf")
    return nil
  end

  local b0, s0 = countItem(blockID), countItem(seedID)
  for _, m in ipairs(machines) do
    glog("ambil dari " .. m.dialog .. " di " .. m.tile.x .. "," .. m.tile.y)
    ambilDariMesin(m.tile, m.dialog)
  end
  local gainedBlock = countItem(blockID) - b0
  local gainedSeed  = countItem(seedID) - s0
  glog("hasil retrieve | block +" .. gainedBlock .. " | seed +" .. gainedSeed)
  return gainedBlock, gainedSeed
end

-- drop lewat paket drop langsung (tidak tergantung bot:drop)
function dropItem(id)
  local n = countItem(id)
  if n <= 0 then return end
  for i = 1, 5 do
    bot:sendPacket(2, "action|drop\nitemID|" .. id)
    sleep(1500)
    bot:sendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|" .. id ..
      "\ncount|" .. n)
    sleep(3000)
    if countItem(id) < n then break end
    pcall(function() bot:moveRight() end) -- drop gagal, geser lalu coba lagi
    sleep(1500)
  end
end

function kirimKeStorage()
  glog("warp ke world storage: " .. storage)
  if not warpTo(storage, storageid) then
    glog("gagal warp ke world storage, cek storage/storageid")
    return
  end
  if dropX then
    bot:findPath(dropX, dropY)
    sleep(1000)
  end
  local b, s = countItem(blockID), countItem(seedID)
  dropItem(blockID)
  pcall(function() bot:moveRight() end)
  sleep(1500)
  dropItem(seedID)
  local sisaBlock, sisaSeed = countItem(blockID), countItem(seedID)
  glog("drop selesai | block " .. b .. " | seed " .. s ..
       " | sisa " .. sisaBlock .. " block, " .. sisaSeed .. " seed")

  if sisaBlock > 0 or sisaSeed > 0 then
    glog("PERHATIAN: masih ada sisa item di inventory (storage penuh / drop gagal sebagian)")
  end
end

-- satu putaran penuh: warp gaut -> ambil (apa adanya) -> warp storage -> drop
-- dipanggil terus-menerus tanpa jeda oleh main() -- warp balik ke gaut otomatis
-- kejadian di awal putaran berikutnya (lewat warpTo di sini).
function siklus()
  glog("siklus mulai | warp ke world gaut: " .. gautWorld)
  if not warpTo(gautWorld, gautDoor) then
    glog("gagal warp ke world gaut, cek gautWorld/gautDoor")
    return
  end

  local gainedBlock, gainedSeed = ambilSemuaMesin() -- lanjut walau "block +0 | seed +200" dsb, itu normal
  if gainedBlock == nil then return end -- gak ada mesin ditemukan, jangan lanjut drop

  kirimKeStorage()

  if gainedBlock == 0 and gainedSeed == 0 then
    -- beneran gak ada progress sama sekali -> mesin kemungkinan belum sempat ngisi,
    -- tunggu dulu biar gak spam wrench sia-sia tiap beberapa detik
    glog("gak ada item baru (block +0 | seed +0), tunggu " .. (noItemCooldown / 1000) ..
         " detik sebelum coba lagi")
    sleep(noItemCooldown)
  end
end

function main()
  if gautWorld == "X" or storage == "X" then
    glog("Isi dulu gautWorld dan storage di bagian konfigurasi")
    return
  end
  glog("mode continuous aktif: ambil -> drop -> balik -> ulang, tanpa jeda interval")
  while true do
    local ok, err = pcall(siklus)
    if not ok then
      glog("ERROR: " .. tostring(err))
      sleep(errorRetryDelay)
    end
    -- sukses: TIDAK ada sleep di sini, langsung lanjut ke putaran berikutnya
  end
end

main()
