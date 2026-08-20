--[[
    palofsc - 05_ResponseManager.lua
    PHẦN 5: QUẢN LÝ PHẢN HỒI
    - Quản lý hàng đợi phản hồi
    - Hiển thị phản hồi tuần tự
    - Tích hợp với UI Manager
    - Tự động xử lý độ trễ
--]]

-- ============================================================
-- RESPONSE MANAGER MODULE
-- ============================================================

local ResponseManager = {}
ResponseManager.__index = ResponseManager

-- ============================================================
-- TẠO INSTANCE
-- ============================================================

function ResponseManager.new()
    local self = setmetatable({}, ResponseManager)
    
    -- Hàng đợi phản hồi
    self.queue = {}
    self.isProcessing = false
    self.isPaused = false
    
    -- Cấu hình
    self.config = {
        defaultDuration = 3,    -- Thời gian hiển thị mặc định (giây)
        delayBetween = 0.5,     -- Độ trễ giữa các phản hồi (giây)
        maxQueueSize = 50,      -- Giới hạn hàng đợi
        typingSpeed = 0.02      -- Tốc độ đánh chữ (giây/ký tự)
    }
    
    -- Callbacks
    self.onResponse = nil
    self.onQueueEmpty = nil
    self.onError = nil
    
    return self
end

-- ============================================================
-- THÊM PHẢN HỒI VÀO HÀNG ĐỢI
-- ============================================================

function ResponseManager:addResponse(data)
    if not data or not data.message then 
        if self.onError then
            self.onError("Phản hồi không hợp lệ", data)
        end
        return false 
    end
    
    -- Kiểm tra giới hạn hàng đợi
    if #self.queue >= self.config.maxQueueSize then
        if self.onError then
            self.onError("Hàng đợi đã đầy", data)
        end
        return false
    end
    
    -- Tạo phản hồi với cấu hình mặc định
    local response = {
        message = data.message or "",
        emotion = data.emotion or "NORMAL",
        duration = data.duration or self.config.defaultDuration,
        action = data.action,
        priority = data.priority or 0,
        timestamp = os.time()
    }
    
    -- Thêm vào hàng đợi (có ưu tiên)
    if response.priority > 0 then
        -- Chèn vào vị trí phù hợp theo ưu tiên
        local inserted = false
        for i, existing in ipairs(self.queue) do
            if existing.priority < response.priority then
                table.insert(self.queue, i, response)
                inserted = true
                break
            end
        end
        if not inserted then
            table.insert(self.queue, response)
        end
    else
        table.insert(self.queue, response)
    end
    
    -- Bắt đầu xử lý nếu chưa chạy
    if not self.isProcessing then
        self:processQueue()
    end
    
    return true
end

-- ============================================================
-- THÊM NHIỀU PHẢN HỒI
-- ============================================================

function ResponseManager:addResponses(responses)
    if not responses or type(responses) ~= "table" then return false end
    
    for _, response in ipairs(responses) do
        self:addResponse(response)
    end
    return true
end

-- ============================================================
-- XỬ LÝ HÀNG ĐỢI
-- ============================================================

function ResponseManager:processQueue()
    if self.isProcessing or self.isPaused then 
        return 
    end
    
    if #self.queue == 0 then
        self.isProcessing = false
        if self.onQueueEmpty then
            self.onQueueEmpty()
        end
        return
    end
    
    self.isProcessing = true
    
    -- Lấy phản hồi đầu tiên
    local response = table.remove(self.queue, 1)
    
    -- Hiển thị phản hồi
    if self.onResponse then
        self.onResponse(response)
    else
        -- Mặc định: in ra console
        print(string.format("[Response] %s (Emotion: %s)", 
            response.message, response.emotion))
    end
    
    -- Đợi thời gian hiển thị + độ trễ
    local totalWait = response.duration + self.config.delayBetween
    
    -- Nếu có hành động, thực thi
    if response.action then
        -- Action sẽ được xử lý ở nơi khác
        if self.onAction then
            self.onAction(response.action)
        end
    end
    
    -- Đợi rồi xử lý tiếp
    task.wait(totalWait)
    
    self.isProcessing = false
    self:processQueue()
end

-- ============================================================
-- DỪNG/TIẾP TỤC XỬ LÝ
-- ============================================================

function ResponseManager:pause()
    self.isPaused = true
end

function ResponseManager:resume()
    self.isPaused = false
    if not self.isProcessing and #self.queue > 0 then
        self:processQueue()
    end
end

-- ============================================================
-- XÓA HÀNG ĐỢI
-- ============================================================

function ResponseManager:clearQueue()
    local count = #self.queue
    self.queue = {}
    return count
end

-- ============================================================
-- LẤY THÔNG TIN HÀNG ĐỢI
-- ============================================================

function ResponseManager:getQueueSize()
    return #self.queue
end

function ResponseManager:isProcessing()
    return self.isProcessing
end

function ResponseManager:isPaused()
    return self.isPaused
end

function ResponseManager:peekNext()
    if #self.queue > 0 then
        return self.queue[1]
    end
    return nil
end

-- ============================================================
-- CẤU HÌNH
-- ============================================================

function ResponseManager:setConfig(config)
    if not config then return end
    
    for key, value in pairs(config) do
        if self.config[key] ~= nil then
            self.config[key] = value
        end
    end
end

function ResponseManager:getConfig()
    return self.config
end

-- ============================================================
-- ĐĂNG KÝ CALLBACK
-- ============================================================

function ResponseManager:onResponse(callback)
    self.onResponse = callback
end

function ResponseManager:onQueueEmpty(callback)
    self.onQueueEmpty = callback
end

function ResponseManager:onError(callback)
    self.onError = callback
end

function ResponseManager:onAction(callback)
    self.onAction = callback
end

-- ============================================================
-- PHƯƠNG THỨC TIỆN ÍCH
-- ============================================================

-- Thêm phản hồi đơn giản
function ResponseManager:say(message, emotion, duration)
    return self:addResponse({
        message = message,
        emotion = emotion or "NORMAL",
        duration = duration or self.config.defaultDuration
    })
end

-- Thêm phản hồi với hành động
function ResponseManager:sayAndDo(message, action, emotion, duration)
    return self:addResponse({
        message = message,
        action = action,
        emotion = emotion or "NORMAL",
        duration = duration or self.config.defaultDuration
    })
end

-- Thêm phản hồi ưu tiên cao
function ResponseManager:urgent(message, emotion, duration)
    return self:addResponse({
        message = message,
        emotion = emotion or "URGENT",
        duration = duration or self.config.defaultDuration,
        priority = 100
    })
end

-- ============================================================
-- HÀM TIỆN ÍCH CHO UI
-- ============================================================

-- Tạo phản hồi dạng typing
function ResponseManager:createTypingResponse(text, emotion, duration)
    return {
        message = text,
        emotion = emotion or "NORMAL",
        duration = duration or self.config.defaultDuration,
        isTyping = true
    }
end

-- Tạo phản hồi dạng câu hỏi
function ResponseManager:createQuestion(text, options, emotion)
    return {
        message = text,
        emotion = emotion or "NORMAL",
        duration = 5,
        isQuestion = true,
        options = options or {}
    }
end

-- ============================================================
-- TẠO INSTANCE (ALTERNATIVE)
-- ============================================================

function ResponseManager.create()
    return ResponseManager.new()
end

-- ============================================================
-- VÍ DỤ SỬ DỤNG
-- ============================================================

--[[
-- Tạo response manager
local rm = ResponseManager.new()

-- Đăng ký callback
rm:onResponse(function(response)
    print("📝 Phản hồi:", response.message)
    print("😊 Cảm xúc:", response.emotion)
    print("⏱️ Thời gian:", response.duration, "giây")
end)

rm:onQueueEmpty(function()
    print("✅ Hàng đợi đã trống")
end)

-- Thêm phản hồi
rm:say("Xin chào! Tôi là Verity", "HAPPY", 2)
rm:say("Tôi có thể giúp gì cho bạn?", "NORMAL", 3)

-- Phản hồi với hành động
rm:sayAndDo("Đang bay với tốc độ 80 km/h!", 
    {action = "fly", speed = 80}, 
    "HAPPY", 3)

-- Phản hồi ưu tiên cao
rm:urgent("⚠️ Cảnh báo! Quá tốc độ!", "GREEDY", 2)

-- Thêm nhiều phản hồi cùng lúc
rm:addResponses({
    {message = "Đây là tin nhắn 1", emotion = "HAPPY", duration = 1},
    {message = "Đây là tin nhắn 2", emotion = "NORMAL", duration = 1},
    {message = "Đây là tin nhắn 3", emotion = "CONFUSED", duration = 1}
})

-- Xóa hàng đợi
rm:clearQueue()

-- Tạm dừng xử lý
rm:pause()
-- ... sau đó
rm:resume()
--]]

return ResponseManager
