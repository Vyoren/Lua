local bot = getBot()

if bot == nil then
    print("Bot not found")
    return
end

local TARGET_ID  = 518
local MAX_TRIES  = 60   -- 60 x 500ms = maksimal 30 detik
local bot        = getBot()

bot.collect_range = 4

-- tunggu sampai bot benar-benar masuk world
local waited = 0
while not bot:isInWorld() and waited < 10 do
    sleep(500)
    waited = waited + 1
end
if not bot:isInWorld() then
    print("Bot not in world")
    return
end

-- hitung item target yang masih ada di world (fix #3 & #5)
local function countTarget()
    local n = 0
    for _, obj in pairs(getObjects()) do
        if obj.id == TARGET_ID then n = n + (obj.count or 1) end
    end
    return n
end

-- fix #1, #2, #4: loop collect sampai habis ATAU timeout
for i = 1, MAX_TRIES do
    if not bot:isInWorld() then
        print("Bot kicked out of world")
        return
    end

local before = countTarget()
    if before == 0 then break end -- sudah bersih

bot:collectByID(TARGET_ID)
    sleep(500) -- kasih waktu collect jalan

-- kalau count gak turun, kemungkinan item di luar range
    if countTarget() >= before then
        print("Item tidak turun — cek collect_range atau posisi bot")
    end
end

print("Done. Sisa item " .. TARGET_ID .. " di world: " .. countTarget() .. "x")
