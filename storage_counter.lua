local retCount = nil

local function hookContain(v, netid)
    if v:get(0):getString() ~= "OnDialogRequest" then return end
    local dialog = v:get(1):getString():lower()
    if dialog:find("contains") then
        -- "contains.-(%d+)" tahan sama color code/backtick di antara kata dan angka
        retCount = tonumber(dialog:match("contains.-(%d+)"))
        unlistenEvents()
    end
end

local function checkContain(x, y)
    retCount = nil              -- fix #3: reset tiap kali cek
    addEvent(Event.variantlist, hookContain)
    bot:wrench(x, y)
    listenEvents(3)
    removeEvent(Event.variantlist)
    return retCount             -- balikin nilai, jangan lewat global mentah-mentah
end

-- pemakaian:
local count = checkContain(12, 34)
if count == nil then
    print("Dialog gak kebaca — coba lagi / cek koordinat storage")
else
    print("Storage contains: " .. count)
    -- pakai count ini buat retrieve, misal: retrieve sebanyak count (bukan count+1)
end
