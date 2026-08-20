-- ============================================================
-- VERITY AI - LOADER (Tự động tải tất cả các phần)
-- ============================================================

local function loadModule(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return result
    else
        error("Không thể tải: " .. url)
    end
end

-- Load từng phần
local Parts = {
    "VoiceRecorder",
    "SpeechToText",
    "CommandProcessor",
    "ActionExecutor",
    "ResponseManager",
    "EmotionEngine",
    "UIManager",
    "Main"
}

local Data = {
    "commands",
    "responses"
}

-- Hàm load và thực thi
local function executePart(part)
    local url = "https://raw.githubusercontent.com/caodinhkhoi282-bot/Verity-A.I/main/Parts/" .. part .. ".lua"
    local code = loadModule(url)
    local fn, err = loadstring(code)
    if fn then
        fn()
        print("[Loader] Đã tải: " .. part)
    else
        warn("[Loader] Lỗi tải " .. part .. ": " .. err)
    end
end

local function executeData(part)
    local url = "https://raw.githubusercontent.com/caodinhkhoi282-bot/Verity-A.I/main/Data/" .. part .. ".lua"
    local code = loadModule(url)
    local fn, err = loadstring(code)
    if fn then
        fn()
        print("[Loader] Đã tải: " .. part)
    else
        warn("[Loader] Lỗi tải " .. part .. ": " .. err)
    end
end

-- === THỰC THI ===
print("[Loader] Đang tải Verity AI V5.0...")

-- 1. Tải Data trước
for _, name in ipairs(Data) do
    executeData(name)
end

-- 2. Tải Parts theo thứ tự
for _, name in ipairs(Parts) do
    executePart(name)
end

-- 3. Chạy Main
-- Main đã được load ở cuối, tự động chạy khi khởi tạo
print("[Loader] ✅ Verity AI đã sẵn sàng!")
