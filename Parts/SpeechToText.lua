--[[
    palofsc - 02_SpeechToText.lua
    PHẦN 2: CHUYỂN GIỌNG NÓI THÀNH VĂN BẢN
    - Nhận dạng giọng nói (local - giả lập)
    - Chuyển đổi âm thanh thành văn bản
    - Hỗ trợ tiếng Việt và tiếng Anh
    - Tương thích Delta Executor
--]]

-- ============================================================
-- SPEECH TO TEXT MODULE
-- ============================================================

local SpeechToText = {}
SpeechToText.__index = SpeechToText

-- Cấu hình ngôn ngữ
local CONFIG = {
    LANGUAGE = "vi-VN",  -- vi-VN, en-US, ja-JP, ko-KR
    SAMPLE_RATE = 16000,
    AUTO_DETECT = true
}

-- Từ điển ánh xạ giọng nói -> văn bản (giả lập)
local PHONETIC_MAP = {
    -- Tiếng Việt
    ["bay"] = "bay",
    ["bay mot tram"] = "bay 100",
    ["bay nam muoi"] = "bay 50",
    ["bay tam muoi"] = "bay 80",
    ["dung"] = "dừng",
    ["dung bay"] = "dừng bay",
    ["tang toc"] = "tăng tốc",
    ["giam toc"] = "giảm tốc",
    ["nhay"] = "nhảy",
    ["ngoi"] = "ngồi",
    ["dung"] = "đứng",
    ["dich chuyen"] = "dịch chuyển",
    ["phep thuat"] = "phép thuật",
    ["tinh"] = "tính",
    ["xin chao"] = "xin chào",
    ["cam on"] = "cảm ơn",
    ["toi buon"] = "tôi buồn",
    ["toi vui"] = "tôi vui",
    ["trang thai"] = "trạng thái",
    ["giup"] = "giúp",
    ["ten ban la gi"] = "tên bạn là gì",
    ["ban la ai"] = "bạn là ai",
    ["hoc"] = "học",
    
    -- Tiếng Anh
    ["fly"] = "bay",
    ["fly one hundred"] = "bay 100",
    ["fly fifty"] = "bay 50",
    ["fly eighty"] = "bay 80",
    ["stop"] = "dừng",
    ["stop flying"] = "dừng bay",
    ["speed up"] = "tăng tốc",
    ["slow down"] = "giảm tốc",
    ["jump"] = "nhảy",
    ["sit"] = "ngồi",
    ["stand"] = "đứng",
    ["teleport"] = "dịch chuyển",
    ["magic"] = "phép thuật",
    ["calculate"] = "tính",
    ["hello"] = "xin chào",
    ["thanks"] = "cảm ơn",
    ["i am sad"] = "tôi buồn",
    ["i am happy"] = "tôi vui",
    ["status"] = "trạng thái",
    ["help"] = "giúp",
    ["what is your name"] = "tên bạn là gì",
    ["who are you"] = "bạn là ai",
    ["learn"] = "học"
}

-- ============================================================
-- XỬ LÝ GIỌNG NÓI
-- ============================================================

function SpeechToText:processAudio(audioData)
    -- Mô phỏng xử lý âm thanh
    -- Trong thực tế: giải mã audio, phân tích tần số, nhận dạng
    
    if not audioData then
        return nil, "Không có dữ liệu âm thanh"
    end
    
    -- Giả lập thời gian xử lý
    task.wait(0.3)
    
    -- Kiểm tra dữ liệu (giả lập)
    if type(audioData) == "string" and audioData ~= "" then
        -- Nếu đã là text, chỉ cần chuẩn hóa
        return self:normalizeText(audioData)
    end
    
    -- Mô phỏng nhận diện từ âm thanh
    local detectedText = self:simulateRecognition(audioData)
    
    if detectedText then
        return self:normalizeText(detectedText)
    end
    
    return nil, "Không thể nhận dạng giọng nói"
end

-- ============================================================
-- MÔ PHỎNG NHẬN DIỆN
-- ============================================================

function SpeechToText:simulateRecognition(audioData)
    -- Danh sách các câu nói mẫu
    local samplePhrases = {
        "bay 100", "bay 80", "bay 50", "dừng bay",
        "tăng tốc 20", "giảm tốc 10", "nhảy lên",
        "ngồi xuống", "đứng lên", "dịch chuyển 0 50 0",
        "phép thuật", "tính 2 + 3 * 4", "xin chào verity",
        "cảm ơn bạn", "tôi buồn", "tôi vui",
        "trạng thái", "giúp tôi với", "tên bạn là gì",
        "bạn là ai", "học"
    }
    
    -- Chọn ngẫu nhiên dựa trên dữ liệu đầu vào (giả lập)
    local seed = 0
    if type(audioData) == "table" then
        for i, v in ipairs(audioData) do
            seed = seed + tonumber(v) or 0
        end
    elseif type(audioData) == "number" then
        seed = audioData
    else
        seed = os.time() % 100
    end
    
    local index = (seed % #samplePhrases) + 1
    return samplePhrases[index]
end

-- ============================================================
-- CHUẨN HÓA VĂN BẢN
-- ============================================================

function SpeechToText:normalizeText(text)
    if not text then return "" end
    
    -- Chuyển sang chữ thường
    text = string.lower(text)
    
    -- Xóa dấu câu thừa
    text = string.gsub(text, "[%p]", "")
    
    -- Xóa khoảng trắng thừa
    text = string.gsub(text, "%s+", " ")
    
    -- Trim
    text = string.match(text, "^%s*(.-)%s*$") or text
    
    return text
end

-- ============================================================
-- PHÁT HIỆN NGÔN NGỮ
-- ============================================================

function SpeechToText:detectLanguage(text)
    if not text or text == "" then return "unknown" end
    
    -- Kiểm tra dấu tiếng Việt
    local vietnameseChars = "àáảãạăắằẳẵặâấầẩẫậèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵđ"
    for char in string.gmatch(text, ".") do
        if string.find(vietnameseChars, char) then
            return "vi-VN"
        end
    end
    
    -- Kiểm tra tiếng Anh (mặc định)
    return "en-US"
end

-- ============================================================
-- THÊM TỪ ĐIỂN CÁ NHÂN
-- ============================================================

function SpeechToText:addCustomWord(spoken, written)
    if spoken and written then
        PHONETIC_MAP[spoken] = written
        return true
    end
    return false
end

function SpeechToText:removeCustomWord(spoken)
    if PHONETIC_MAP[spoken] then
        PHONETIC_MAP[spoken] = nil
        return true
    end
    return false
end

-- ============================================================
-- CHUYỂN ĐỔI GIỌNG NÓI -> VĂN BẢN (GIẢ LẬP)
-- ============================================================

function SpeechToText:convert(textOrAudio)
    if type(textOrAudio) == "string" then
        -- Nếu đã là text, chuẩn hóa và trả về
        return self:normalizeText(textOrAudio)
    end
    
    -- Nếu là dữ liệu audio, mô phỏng nhận dạng
    return self:simulateRecognition(textOrAudio)
end

-- ============================================================
-- API TÍCH HỢP VOICE RECORDER
-- ============================================================

function SpeechToText:processWithRecorder(recorder, callback)
    if not recorder then
        if callback then callback(nil, "Không có recorder") end
        return
    end
    
    -- Bắt đầu ghi âm
    recorder:startRecording(function(audio, status)
        if audio then
            -- Chuyển giọng nói thành văn bản
            local text = self:convert(audio)
            if callback then callback(text, "Thành công") end
        else
            if callback then callback(nil, status) end
        end
    end)
end

-- ============================================================
-- TẠO INSTANCE
-- ============================================================

function SpeechToText.new(config)
    local self = setmetatable({}, SpeechToText)
    
    if config then
        for key, value in pairs(config) do
            CONFIG[key] = value
        end
    end
    
    return self
end

-- ============================================================
-- VÍ DỤ SỬ DỤNG
-- ============================================================

--[[
-- Tạo instance với cấu hình
local stt = SpeechToText.new({
    LANGUAGE = "vi-VN",
    AUTO_DETECT = true
})

-- Chuyển đổi text
local text = stt:convert("Xin chào Verity")
print("Kết quả:", text)  -- "xin chao verity"

-- Chuyển đổi từ audio (giả lập)
local audioData = {1, 2, 3, 4, 5}  -- Dữ liệu audio giả
local result = stt:processAudio(audioData)
print("Nhận diện:", result)

-- Kết hợp với VoiceRecorder
local recorder = VoiceRecorder.new()
stt:processWithRecorder(recorder, function(text, status)
    if text then
        print("🎤 Bạn nói:", text)
    else
        print("❌", status)
    end
end)
--]]

return SpeechToText
