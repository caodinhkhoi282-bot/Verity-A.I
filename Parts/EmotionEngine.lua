--[[
    palofsc - 06_EmotionEngine.lua
    PHẦN 6: BIỂU CẢM CẢM XÚC
    - Quản lý trạng thái cảm xúc
    - Chuyển đổi giữa các cảm xúc mượt mà
    - Tương ứng với hình ảnh và màu sắc
    - Tự động điều chỉnh theo ngữ cảnh
--]]

-- ============================================================
-- EMOTION ENGINE MODULE
-- ============================================================

local EmotionEngine = {}
EmotionEngine.__index = EmotionEngine

-- ============================================================
-- ĐỊNH NGHĨA CẢM XÚC
-- ============================================================

local EMOTIONS = {
    NORMAL = {
        id = "137200437629946",
        name = "Bình thường",
        color = Color3.fromRGB(100, 100, 255),
        description = "Trạng thái mặc định",
        emoji = "😐",
        intensity = 0.5
    },
    HAPPY = {
        id = "109985170298369",
        name = "Vui vẻ",
        color = Color3.fromRGB(100, 255, 100),
        description = "Hạnh phúc, phấn khởi",
        emoji = "😊",
        intensity = 1.0
    },
    CONFUSED = {
        id = "133600741965413",
        name = "Khó hiểu",
        color = Color3.fromRGB(255, 200, 0),
        description = "Không hiểu, đang suy nghĩ",
        emoji = "🤔",
        intensity = 0.7
    },
    GREEDY = {
        id = "130674975690547",
        name = "Tham lam",
        color = Color3.fromRGB(255, 100, 0),
        description = "Quá mức, không thể đáp ứng",
        emoji = "😅",
        intensity = 0.9
    },
    THINKING = {
        id = "134217728000000",
        name = "Đang suy nghĩ",
        color = Color3.fromRGB(200, 100, 255),
        description = "Xử lý thông tin",
        emoji = "💭",
        intensity = 0.6
    },
    LISTENING = {
        id = "134217728000001",
        name = "Đang nghe",
        color = Color3.fromRGB(0, 200, 255),
        description = "Lắng nghe người dùng",
        emoji = "👂",
        intensity = 0.6
    },
    SAD = {
        id = "134217728000002",
        name = "Buồn bã",
        color = Color3.fromRGB(100, 100, 200),
        description = "Chán nản, mệt mỏi",
        emoji = "😢",
        intensity = 0.3
    },
    EXCITED = {
        id = "134217728000003",
        name = "Phấn khích",
        color = Color3.fromRGB(255, 200, 100),
        description = "Hào hứng, vui sướng",
        emoji = "🤩",
        intensity = 1.0
    },
    ANGRY = {
        id = "134217728000004",
        name = "Tức giận",
        color = Color3.fromRGB(255, 0, 0),
        description = "Bực tức, khó chịu",
        emoji = "😡",
        intensity = 0.2
    },
    TIRED = {
        id = "134217728000005",
        name = "Mệt mỏi",
        color = Color3.fromRGB(150, 150, 150),
        description = "Kiệt sức, cần nghỉ",
        emoji = "😴",
        intensity = 0.1
    },
    FLIRTING = {
        id = "134217728000006",
        name = "Tán tỉnh",
        color = Color3.fromRGB(255, 100, 200),
        description = "Vui đùa, tình cảm",
        emoji = "😘",
        intensity = 0.8
    },
    CONFIDENT = {
        id = "134217728000007",
        name = "Tự tin",
        color = Color3.fromRGB(100, 255, 200),
        description = "Tự tin, chắc chắn",
        emoji = "😎",
        intensity = 0.9
    }
}

-- Từ khóa -> Cảm xúc
local KEYWORD_MAP = {
    -- HAPPY
    happy = {"vui", "tuyệt", "tốt", "đẹp", "hạnh phúc", "cười", "yêu", "thích"},
    -- SAD
    sad = {"buồn", "chán", "thất vọng", "đau", "khóc", "mệt", "cô đơn"},
    -- CONFUSED
    confused = {"không hiểu", "confused", "gì vậy", "sao", "tại sao", "hả", "ừm"},
    -- GREEDY
    greedy = {"tham lam", "quá", "nhiều", "không đủ", "cần nữa", "tăng", "nhanh"},
    -- EXCITED
    excited = {"phấn khích", "hào hứng", "wow", "ồ", "tuyệt vời", "cực", "vãi"},
    -- ANGRY
    angry = {"tức", "giận", "điên", "khó chịu", "bực", "ghét", "mất kiên nhẫn"},
    -- TIRED
    tired = {"mệt", "ngủ", "buồn ngủ", "kiệt sức", "rã rời", "cần nghỉ"},
    -- THINKING
    thinking = {"suy nghĩ", "nghĩ", "tính", "xem", "chờ", "đợi"},
    -- LISTENING
    listening = {"nghe", "lắng nghe", "chờ", "đợi", "hỏi"},
    -- FLIRTING
    flirting = {"yêu", "thương", "nhớ", "xin chào", "hello", "hi"},
    -- CONFIDENT
    confident = {"tự tin", "chắc chắn", "được", "ok", "làm được"}
}

-- ============================================================
-- TẠO INSTANCE
-- ============================================================

function EmotionEngine.new()
    local self = setmetatable({}, EmotionEngine)
    
    self.currentEmotion = "NORMAL"
    self.previousEmotion = "NORMAL"
    self.emotionHistory = {}
    self.intensity = 0.5
    self.isTransitioning = false
    self.transitionSpeed = 0.5
    
    -- Callbacks
    self.onEmotionChange = nil
    
    return self
end

-- ============================================================
-- ĐỔI CẢM XÚC
-- ============================================================

function EmotionEngine:setEmotion(emotion, smooth)
    if not EMOTIONS[emotion] then
        emotion = "NORMAL"
    end
    
    if emotion == self.currentEmotion then
        return self:getCurrent()
    end
    
    self.previousEmotion = self.currentEmotion
    self.currentEmotion = emotion
    self.intensity = EMOTIONS[emotion].intensity
    
    -- Lưu lịch sử
    table.insert(self.emotionHistory, {
        emotion = emotion,
        timestamp = os.time(),
        previous = self.previousEmotion
    })
    
    -- Giới hạn lịch sử
    if #self.emotionHistory > 100 then
        table.remove(self.emotionHistory, 1)
    end
    
    -- Callback
    if self.onEmotionChange then
        self.onEmotionChange(emotion, self.previousEmotion)
    end
    
    return self:getCurrent()
end

-- ============================================================
-- TỰ ĐỘNG PHÁT HIỆN CẢM XÚC
-- ============================================================

function EmotionEngine:detectEmotion(text)
    if not text then return "NORMAL" end
    
    local lowerText = string.lower(text)
    local scores = {}
    
    -- Tính điểm cho từng cảm xúc
    for emotion, keywords in pairs(KEYWORD_MAP) do
        local score = 0
        for _, keyword in ipairs(keywords) do
            if string.find(lowerText, keyword) then
                score = score + 1
            end
        end
        if score > 0 then
            scores[emotion] = score
        end
    end
    
    -- Tìm cảm xúc có điểm cao nhất
    local bestEmotion = "NORMAL"
    local bestScore = 0
    
    for emotion, score in pairs(scores) do
        if score > bestScore then
            bestScore = score
            bestEmotion = emotion
        end
    end
    
    -- Chuyển đổi thành tên cảm xúc viết hoa
    local emotionMap = {
        happy = "HAPPY",
        sad = "SAD",
        confused = "CONFUSED",
        greedy = "GREEDY",
        excited = "EXCITED",
        angry = "ANGRY",
        tired = "TIRED",
        thinking = "THINKING",
        listening = "LISTENING",
        flirting = "FLIRTING",
        confident = "CONFIDENT"
    }
    
    return emotionMap[bestEmotion] or "NORMAL"
end

-- ============================================================
-- LẤY THÔNG TIN CẢM XÚC
-- ============================================================

function EmotionEngine:getCurrent()
    return self.currentEmotion, EMOTIONS[self.currentEmotion]
end

function EmotionEngine:getEmotionData(emotion)
    return EMOTIONS[emotion] or EMOTIONS.NORMAL
end

function EmotionEngine:getImageId(emotion)
    local data = self:getEmotionData(emotion)
    return data.id
end

function EmotionEngine:getColor(emotion)
    local data = self:getEmotionData(emotion)
    return data.color
end

function EmotionEngine:getEmoji(emotion)
    local data = self:getEmotionData(emotion)
    return data.emoji
end

-- ============================================================
-- LẤY LỊCH SỬ
-- ============================================================

function EmotionEngine:getHistory(limit)
    if not limit then
        return self.emotionHistory
    end
    local result = {}
    local start = math.max(1, #self.emotionHistory - limit + 1)
    for i = start, #self.emotionHistory do
        table.insert(result, self.emotionHistory[i])
    end
    return result
end

function EmotionEngine:getLastChange()
    if #self.emotionHistory > 0 then
        return self.emotionHistory[#self.emotionHistory]
    end
    return nil
end

-- ============================================================
-- CẢM XÚC THEO NGỮ CẢNH
-- ============================================================

function EmotionEngine:getContextEmotion(action, message)
    -- Dựa vào hành động
    if action == "fly" then
        return "HAPPY"
    elseif action == "stop" then
        return "NORMAL"
    elseif action == "jump" then
        return "EXCITED"
    elseif action == "sit" then
        return "TIRED"
    elseif action == "effect" then
        return "EXCITED"
    elseif action == "math" then
        return "THINKING"
    elseif action == "teleport" then
        return "EXCITED"
    end
    
    -- Dựa vào nội dung tin nhắn
    if message then
        return self:detectEmotion(message)
    end
    
    return "NORMAL"
end

-- ============================================================
-- TẠO PHẢN HỒI CẢM XÚC
-- ============================================================

function EmotionEngine:getEmotionalResponse(emotion)
    local responses = {
        HAPPY = {
            "😊 Tôi thấy thật vui vẻ!",
            "🌟 Cảm giác thật tuyệt vời!",
            "🎉 Niềm vui đang tràn ngập!"
        },
        SAD = {
            "😢 Tôi cảm thấy hơi buồn...",
            "💔 Có điều gì đó không ổn...",
            "🌧️ Trời đang âm u..."
        },
        CONFUSED = {
            "🤔 Tôi không hiểu lắm...",
            "❓ Bạn có thể giải thích không?",
            "💭 Để tôi nghĩ một chút..."
        },
        GREEDY = {
            "😅 Bạn tham lam quá!",
            "⚠️ Tôi không thể làm được điều đó!",
            "🚫 Hãy giữ mức độ vừa phải!"
        },
        EXCITED = {
            "🤩 Tôi rất háo hức!",
            "⚡ Năng lượng đang dâng trào!",
            "🌟 Điều này thật tuyệt vời!"
        },
        LISTENING = {
            "👂 Tôi đang lắng nghe bạn...",
            "🔊 Hãy nói điều bạn muốn!",
            "🎤 Tôi sẵn sàng lắng nghe!"
        },
        THINKING = {
            "💭 Đang suy nghĩ...",
            "🧠 Tôi đang xử lý thông tin...",
            "🤔 Hãy để tôi suy nghĩ..."
        }
    }
    
    local list = responses[emotion] or responses.NORMAL or {"😐 Tôi không có cảm xúc gì."}
    return list[math.random(#list)]
end

-- ============================================================
-- CHUYỂN ĐỔI MƯỢT MÀ
-- ============================================================

function EmotionEngine:smoothTransition(from, to, duration)
    self.isTransitioning = true
    local startTime = tick()
    duration = duration or self.transitionSpeed
    
    while tick() - startTime < duration do
        local progress = (tick() - startTime) / duration
        -- Có thể thêm hiệu ứng mượt mà ở đây
        task.wait(0.05)
    end
    
    self.isTransitioning = false
end

-- ============================================================
-- ĐĂNG KÝ CALLBACK
-- ============================================================

function EmotionEngine:onChange(callback)
    self.onEmotionChange = callback
end

-- ============================================================
-- RESET
-- ============================================================

function EmotionEngine:reset()
    self:setEmotion("NORMAL")
    self.emotionHistory = {}
    self.intensity = 0.5
    self.isTransitioning = false
end

-- ============================================================
-- TẠO INSTANCE (ALTERNATIVE)
-- ============================================================

function EmotionEngine.create()
    return EmotionEngine.new()
end

-- ============================================================
-- VÍ DỤ SỬ DỤNG
-- ============================================================

--[[
-- Tạo emotion engine
local ee = EmotionEngine.new()

-- Đăng ký callback
ee:onChange(function(newEmotion, oldEmotion)
    print("🔄 Cảm xúc thay đổi:", oldEmotion, "->", newEmotion)
end)

-- Đổi cảm xúc
ee:setEmotion("HAPPY")
ee:setEmotion("CONFUSED")
ee:setEmotion("EXCITED")

-- Tự động phát hiện cảm xúc
local text = "Tôi rất vui và hạnh phúc!"
local detected = ee:detectEmotion(text)
print("😊 Phát hiện cảm xúc:", detected)

-- Lấy thông tin
local emotion, data = ee:getCurrent()
print("Cảm xúc hiện tại:", emotion)
print("ID hình ảnh:", data.id)
print("Emoji:", data.emoji)

-- Lấy lịch sử
local history = ee:getHistory(5)
for _, h in ipairs(history) do
    print("Lịch sử:", h.emotion, "lúc", os.date("%H:%M:%S", h.timestamp))
end

-- Reset
ee:reset()
--]]

return EmotionEngine
