-- ========== CONFIG ==========
FarmsConfig = {
    FarmWorlds = {
        "WORLD1|DOORID1",
        "WORLD2|DOORID2",
        "WORLD3|DOORID3",
        "WORLD4|DOORID4",
        "WORLD5|DOORID5",
        "WORLD6|DOORID6",
    },
    WARP_WAIT = 2000,   -- ms tunggu setelah warp
    LOOP_MODE = true,   -- true = ulangi dari world 1 setelah selesai
}

-- ========== VAR ==========
local bot = getBot()
local worldIndex = 1

-- ========== UTIL ==========
local function parseWorld(entry)
    -- "WORLD1|DOORID" -> { name = "WORLD1", doorId = "DOORID" }
    local name, doorId = entry:match("^(.-)|(.+)$")
    if not name then
        return { name = string.upper(entry), doorId = "" }
    end
    return { name = string.upper(name), doorId = doorId }
end

local function safeWarp(worldName, doorId)
    local ok = pcall(function()
        if doorId and doorId ~= "" then
            bot:warp(worldName, doorId)
        else
            bot:warp(worldName)
        end
    end)

if not ok then
        print("[ERROR] warp() crash untuk world " .. worldName)
        return false
    end

sleep(FarmsConfig.WARP_WAIT)

if not bot:isInWorld(worldName) then
        print("[ERROR] Gagal masuk world " .. worldName)
        return false
    end

print("[OK] Masuk " .. worldName)
    return true
end

-- ========== MAIN LOOP ==========
while true do
    local entry = FarmsConfig.FarmWorlds[worldIndex]
    local world = parseWorld(entry)

local ok = safeWarp(world.name, world.doorId)

if ok then
        -- TODO: taruh aksi farming di sini
        -- (collect, harvest, punch, dll.)
    end

-- pindah ke world berikutnya
    worldIndex = worldIndex + 1
    if worldIndex > #FarmsConfig.FarmWorlds then
        if not FarmsConfig.LOOP_MODE then
            print("Semua world selesai. Stop.")
            break
        end
        worldIndex = 1 -- ulang dari awal
    end
end
