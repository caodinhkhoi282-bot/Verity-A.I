--[[
    palofsc - 08_Main.lua
    PHẦN 8: KẾT NỐI TẤT CẢ CÁC PHẦN
    - Khởi tạo tất cả modules
    - Kết nối sự kiện giữa các phần
    - Chạy vòng lặp chính
    - Quản lý luồng xử lý
--]]

-- ============================================================
-- LOAD TẤT CẢ MODULES
-- ============================================================

-- Lấy script parent (trong trường hợp chạy từng file riêng)
local scriptParent = script and script.Parent or nil

-- Hàm load module an toàn
local function safeRequire(moduleName)
    local success, module = pcall(function()
        if scriptParent then
            return require(scriptParent:FindFirstChild(moduleName))
        else
            -- Nếu chạy trong môi trường không có script parent
            return nil
        end
    end)
    if success and module then
        return module
    end
    return nil
end

-- Load các modules (nếu có)
local VoiceRecorder = safeRequire("01_VoiceRecorder") or require(script.Parent["01_VoiceRecorder"])
local SpeechToText = safeRequire("02_SpeechToText") or require(script.Parent["02_SpeechToText"])
local CommandProcessor = safeRequire("03_CommandProcessor") or require(script.Parent["03_CommandProcessor"])
local ActionExecutor = safeRequire("04_ActionExecutor") or require(script.Parent["04_ActionExecutor"])
local ResponseManager = safeRequire("05_ResponseManager") or require(script.Parent["05_ResponseManager"])
local EmotionEngine = safeRequire("06_EmotionEngine") or require(script.Parent["06_EmotionEngine"])
local UIManager = safeRequire("07_UIManager") or require(script.Parent["07_UIManager"])

-- Nếu không load được, in thông báo và dùng code dự phòng
if not VoiceRecorder or not SpeechToText or not CommandProcessor or 
   not ActionExecutor or not ResponseManager or not EmotionEngine or not UIManager then
    print("[Verity] Không thể load tất cả modules. Đang sử dụng chế độ dự phòng...")
end

-- ============================================================
-- MAIN CLASS
-- ============================================================

local VerityAI = {}
VerityAI.__index = VerityAI

function VerityAI.new()
    local self = setmetatable({}, VerityAI)
    
    print("[Verity] Đang khởi tạo Verity AI V5.0...")
    
    -- Khởi tạo các modules
    self.emotionEngine = EmotionEngine and EmotionEngine.new() or nil
    self.commandProcessor = CommandProcessor and CommandProcessor.new() or nil
    self.actionExecutor = ActionExecutor and ActionExecutor.new() or nil
    self.responseManager = ResponseManager and ResponseManager.new() or nil
    self.voiceRecorder = VoiceRecorder and VoiceRecorder.new() or nil
    self.speechToText = SpeechToText and SpeechToText.new() or nil
    self.uiManager = UIManager and UIManager.new(self.emotionEngine) or nil
    
    -- Biến trạng thái
    self.isRunning = true
    self.isProcessing = false
    self.currentMode = "idle"  -- idle, listening, processing, executing
    
    -- Callback chain
    self:setupCallbacks()
    
    print("[Verity] ✅ Khởi tạo thành công!")
    print("[Verity] 🎤 Nhấn MIC để ghi âm")
    print("[Verity] 💬 Gõ 'verity' hoặc 'hey' để chat")
    print("[Verity] 🚀 Nhấn FLY để bật/tắt bay")
    
    return self
end

-- ============================================================
-- THIẾT LẬP CALLBACKS
-- ============================================================

function VerityAI:setupCallbacks()
    -- UI Callbacks
    if self.uiManager then
        -- Nút ghi âm
        self.uiManager:onRecord(function()
            self:startVoiceRecording()
        end)
        
        -- Nút bay
        self.uiManager:onFly(function()
            self:toggleFly()
        end)
        
        -- Nút trạng thái
        self.uiManager:onStatus(function()
            self:showStatus()
        end)
        
        -- Nút đóng
        self.uiManager:onClose(function()
            self:shutdown()
        end)
    end
    
    -- Response Manager Callbacks
    if self.responseManager then
        self.responseManager:onResponse(function(response)
            self:handleResponse(response)
        end)
        
        self.responseManager:onQueueEmpty(function()
            self.currentMode = "idle"
        end)
    end
    
    -- Emotion Engine Callbacks
    if self.emotionEngine then
        self.emotionEngine:onChange(function(newEmotion, oldEmotion)
            if self.uiManager then
                self.uiManager:updateEmotion(newEmotion)
            end
            print("[Verity] Cảm xúc:", oldEmotion, "->", newEmotion)
        end)
    end
    
    -- Action Executor Callbacks (nếu có)
    if self.actionExecutor then
        -- Không có callback đặc biệt
    end
end

-- ============================================================
-- GHI ÂM GIỌNG NÓI
-- ============================================================

function VerityAI:startVoiceRecording()
    if not self.voiceRecorder then
        self:sendResponse("❌ Không có module ghi âm!", "SAD")
        return
    end
    
    if self.currentMode == "listening" then
        return
    end
    
    self.currentMode = "listening"
    self:sendResponse("🎤 Đang ghi âm... Hãy nói điều bạn muốn", "LISTENING", 1)
    
    self.voiceRecorder:startRecording(function(text, status)
        if text then
            self:sendResponse("🎤 Tôi nghe thấy: " .. text, "THINKING", 1.5)
            task.wait(0.5)
            self:processText(text)
        else
            self:sendResponse("❌ Lỗi ghi âm: " .. (status or "Không xác định"), "SAD")
            self.currentMode = "idle"
        end
    end)
end

-- ============================================================
-- XỬ LÝ VĂN BẢN
-- ============================================================

function VerityAI:processText(text)
    if not text or text == "" then
        self:sendResponse("🤔 Bạn có thể nói gì đó không?", "CONFUSED")
        return
    end
    
    self.currentMode = "processing"
    self:sendResponse("💭 Đang xử lý...", "THINKING", 0.8)
    
    -- Tạo context
    local context = {
        isFlying = self.actionExecutor and self.actionExecutor.isFlying or false,
        flySpeed = self.actionExecutor and self.actionExecutor.flySpeed or 0,
        currentEmotion = self.emotionEngine and self.emotionEngine.currentEmotion or "NORMAL",
        maxSpeed = self.actionExecutor and self.actionExecutor.maxSpeed or 100,
        playerName = game.Players.LocalPlayer.Name
    }
    
    -- Xử lý lệnh
    local result = self.commandProcessor and self.commandProcessor:process(text, context) or nil
    
    if result then
        self:executeResult(result)
    else
        self:sendResponse("🤔 Tôi không hiểu. Bạn có thể nói rõ hơn được không?", "CONFUSED")
        self.currentMode = "idle"
    end
end

-- ============================================================
-- THỰC THI KẾT QUẢ
-- ============================================================

function VerityAI:executeResult(result)
    if not result then return end
    
    self.currentMode = "executing"
    
    -- Hiển thị phản hồi
    if result.message then
        self:sendResponse(result.message, result.emotion, 3)
    end
    
    -- Thực thi hành động
    if self.actionExecutor and result.action then
        local success = self.actionExecutor:execute(result)
        if success then
            print("[Verity] ✅ Đã thực thi:", result.action)
        else
            print("[Verity] ❌ Không thể thực thi:", result.action)
        end
    end
    
    -- Cập nhật UI
    if self.uiManager and self.actionExecutor then
        self.uiManager:setFlyButtonState(self.actionExecutor.isFlying)
    end
    
    -- Cập nhật cảm xúc
    if result.emotion and self.emotionEngine then
        self.emotionEngine:setEmotion(result.emotion)
    end
    
    self.currentMode = "idle"
end

-- ============================================================
-- GỬI PHẢN HỒI
-- ============================================================

function VerityAI:sendResponse(message, emotion, duration)
    if self.responseManager then
        self.responseManager:addResponse({
            message = message,
            emotion = emotion or "NORMAL",
            duration = duration or 3
        })
    else
        -- Fallback: hiển thị trực tiếp
        print("[Verity] " .. message)
        if self.uiManager then
            self.uiManager:showChatBubble(message, duration, emotion)
        end
    end
end

-- ============================================================
-- XỬ LÝ PHẢN HỒI
-- ============================================================

function VerityAI:handleResponse(response)
    if not response then return end
    
    -- Hiển thị UI
    if self.uiManager then
        self.uiManager:showChatBubble(response.message, response.duration, response.emotion)
    end
    
    -- Cập nhật cảm xúc
    if response.emotion and self.emotionEngine then
        self.emotionEngine:setEmotion(response.emotion)
    end
    
    -- Nếu có hành động đi kèm
    if response.action and self.actionExecutor then
        self.actionExecutor:execute(response.action)
    end
end

-- ============================================================
-- BẬT/TẮT BAY
-- ============================================================

function VerityAI:toggleFly()
    if not self.actionExecutor then return end
    
    if self.actionExecutor.isFlying then
        self.actionExecutor:execute({action = "stop"})
        self:sendResponse("🛑 Đã dừng bay", "NORMAL", 2)
    else
        self.actionExecutor:execute({action = "fly", speed = 50})
        self:sendResponse("🛫 Đang bay với tốc độ 50 km/h", "HAPPY", 2)
    end
    
    if self.uiManager then
        self.uiManager:setFlyButtonState(self.actionExecutor.isFlying)
    end
end

-- ============================================================
-- HIỂN THỊ TRẠNG THÁI
-- ============================================================

function VerityAI:showStatus()
    local status = "📊 TRẠNG THÁI:\n"
    status = status .. "  • Mode: " .. self.currentMode .. "\n"
    
    if self.actionExecutor then
        status = status .. "  • Bay: " .. (self.actionExecutor.isFlying and "🟢 Bật" or "🔴 Tắt") .. "\n"
        status = status .. "  • Tốc độ: " .. (self.actionExecutor.flySpeed or 0) .. " km/h\n"
    end
    
    if self.emotionEngine then
        status = status .. "  • Cảm xúc: " .. (self.emotionEngine.currentEmotion or "NORMAL") .. "\n"
    end
    
    if self.responseManager then
        status = status .. "  • Hàng đợi: " .. self.responseManager:getQueueSize() .. " phản hồi\n"
    end
    
    status = status .. "  • Người chơi: " .. game.Players.LocalPlayer.Name
    
    self:sendResponse(status, "NORMAL", 5)
end

-- ============================================================
-- XỬ LÝ CHAT TỪ NGƯỜI CHƠI
-- ============================================================

function VerityAI:onChatMessage(message)
    if not message or message == "" then return end
    
    local lowerMsg = string.lower(message)
    
    -- Chỉ xử lý khi có từ khóa gọi
    if not string.find(lowerMsg, "verity") and not string.find(lowerMsg, "hey") then
        return
    end
    
    self:processText(message)
end

-- ============================================================
-- TẮT HỆ THỐNG
-- ============================================================

function VerityAI:shutdown()
    self.isRunning = false
    self:sendResponse("👋 Tạm biệt! Hẹn gặp lại!", "SAD", 2)
    
    if self.uiManager then
        task.wait(2)
        self.uiManager:setVisible(false)
    end
    
    print("[Verity] ✅ Đã tắt hệ thống")
end

-- ============================================================
-- KHỞI CHẠY
-- ============================================================

function VerityAI:start()
    print("[Verity] 🚀 Đang khởi chạy Verity AI V5.0...")
    
    -- Kết nối sự kiện chat
    local player = game.Players.LocalPlayer
    player.Chatted:Connect(function(message)
        self:onChatMessage(message)
    end)
    
    print("[Verity] ✅ Đã sẵn sàng!")
    print("[Verity] 📌 Gõ 'verity' hoặc 'hey' để gọi")
    print("[Verity] 🎤 Nhấn nút MIC để ghi âm")
    print("[Verity] 🚀 Nhấn nút FLY để bay")
    
    -- Hiển thị welcome
    self:sendResponse("👋 Xin chào! Tôi là Verity, trợ lý ảo của bạn!", "HAPPY", 3)
    task.wait(3)
    self:sendResponse("💬 Gõ 'verity' hoặc nhấn MIC để trò chuyện", "NORMAL", 3)
    
    -- Vòng lặp chính (giữ chương trình chạy)
    while self.isRunning do
        task.wait(1)
    end
end

-- ============================================================
-- TẠO INSTANCE
-- ============================================================

function VerityAI.create()
    return VerityAI.new()
end

-- ============================================================
-- CHẠY
-- ============================================================

-- Tạo và chạy Verity AI
local verity = VerityAI.new()
verity:start()

-- ============================================================
-- VÍ DỤ SỬ DỤNG (NẾU CHẠY TỪNG FILE)
-- ============================================================

--[[
-- Nếu bạn muốn chạy từng file riêng, copy code này vào file chính:
local verity = VerityAI.create()
verity:start()

-- Hoặc dùng cách đơn giản:
local ai = VerityAI.new()
ai:start()
--]]

return VerityAI
