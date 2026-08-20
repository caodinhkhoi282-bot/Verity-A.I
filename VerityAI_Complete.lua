-- ============================================================
-- VERITY AI V5.0 - FULL LOCAL (GỘP 1 FILE)
-- ============================================================

-- ============================================================
-- PHẦN 1: VOICE RECORDER
-- ============================================================
local VoiceRecorder = {}
VoiceRecorder.__index = VoiceRecorder

local CONFIG = { RECORD_DURATION = 3 }
local SAMPLE_TEXTS = {
    "bay 80", "bay 50", "dừng bay", "tăng tốc 20", "giảm tốc 10",
    "nhảy lên", "ngồi xuống", "đứng lên", "dịch chuyển 0 50 0",
    "phép thuật", "tính 2 + 3 * 4", "xin chào verity", "cảm ơn bạn",
    "tôi buồn", "tôi vui", "trạng thái", "giúp tôi với"
}

function VoiceRecorder.new()
    local self = setmetatable({}, VoiceRecorder)
    self.isRecording = false
    return self
end

function VoiceRecorder:startRecording(callback)
    if self.isRecording then return end
    self.isRecording = true
    print("[Voice] Đang ghi âm... (giả lập)")
    task.wait(CONFIG.RECORD_DURATION)
    self.isRecording = false
    local text = SAMPLE_TEXTS[math.random(#SAMPLE_TEXTS)]
    if callback then callback(text) end
    return text
end

-- ============================================================
-- PHẦN 2: SPEECH TO TEXT
-- ============================================================
local SpeechToText = {}
SpeechToText.__index = SpeechToText

function SpeechToText.new()
    return setmetatable({}, SpeechToText)
end

function SpeechToText:convert(text)
    return string.lower(text)
end

-- ============================================================
-- PHẦN 3: COMMAND PROCESSOR
-- ============================================================
local CommandProcessor = {}
CommandProcessor.__index = CommandProcessor

local COMMANDS = {
    fly = {
        keywords = {"bay", "fly"},
        action = function(args)
            local speed = tonumber(args[1]) or 50
            return { action = "fly", speed = speed, message = "🛫 Bay " .. speed .. " km/h", emotion = "HAPPY" }
        end
    },
    stop = {
        keywords = {"dừng", "stop"},
        action = function()
            return { action = "stop", message = "🛑 Đã dừng", emotion = "NORMAL" }
        end
    },
    jump = {
        keywords = {"nhảy", "jump"},
        action = function()
            return { action = "jump", message = "🦘 Nhảy lên!", emotion = "EXCITED" }
        end
    },
    sit = {
        keywords = {"ngồi", "sit"},
        action = function()
            return { action = "sit", message = "🪑 Ngồi xuống", emotion = "NORMAL" }
        end
    },
    stand = {
        keywords = {"đứng", "stand"},
        action = function()
            return { action = "stand", message = "🧍 Đứng lên", emotion = "NORMAL" }
        end
    },
    effect = {
        keywords = {"phép thuật", "effect"},
        action = function()
            return { action = "effect", message = "✨ Phép thuật!", emotion = "EXCITED" }
        end
    },
    math = {
        keywords = {"tính", "math"},
        action = function(args)
            local expr = table.concat(args, " ")
            local success, result = pcall(function() return loadstring("return " .. expr)() end)
            if success and result then
                return { action = "chat", message = "🧮 Kết quả: " .. tostring(result), emotion = "HAPPY" }
            end
            return { action = "chat", message = "🤔 Không hiểu phép toán!", emotion = "CONFUSED" }
        end
    },
    help = {
        keywords = {"giúp", "help"},
        action = function()
            return { action = "chat", message = "📖 Lệnh: bay, dừng, nhảy, ngồi, đứng, phép thuật, tính, trạng thái", emotion = "NORMAL" }
        end
    },
    status = {
        keywords = {"trạng thái", "status"},
        action = function()
            return { action = "chat", message = "📊 Trạng thái: Verity đang hoạt động!", emotion = "NORMAL" }
        end
    }
}

local RESPONSES = {
    greeting = {
        keywords = {"xin chào", "hello", "hi"},
        replies = {"👋 Xin chào!", "❤️ Chào bạn!", "🌟 Chào mừng!"},
        emotion = "HAPPY"
    },
    thank = {
        keywords = {"cảm ơn", "thank"},
        replies = {"❤️ Không có gì!", "💖 Cảm ơn bạn!"},
        emotion = "HAPPY"
    }
}

function CommandProcessor.new()
    return setmetatable({ commands = COMMANDS, responses = RESPONSES }, CommandProcessor)
end

function CommandProcessor:process(text)
    local lower = string.lower(text)
    for _, cmd in pairs(self.commands) do
        for _, kw in ipairs(cmd.keywords) do
            if string.find(lower, kw) then
                local args = {}
                for word in string.gmatch(text, "%S+") do table.insert(args, word) end
                table.remove(args, 1)
                return cmd.action(args)
            end
        end
    end
    for _, resp in pairs(self.responses) do
        for _, kw in ipairs(resp.keywords) do
            if string.find(lower, kw) then
                return { action = "chat", message = resp.replies[math.random(#resp.replies)], emotion = resp.emotion }
            end
        end
    end
    return { action = "chat", message = "🤔 Tôi không hiểu!", emotion = "CONFUSED" }
end

-- ============================================================
-- PHẦN 4: ACTION EXECUTOR
-- ============================================================
local ActionExecutor = {}
ActionExecutor.__index = ActionExecutor

function ActionExecutor.new()
    local self = setmetatable({}, ActionExecutor)
    self.isFlying = false
    self.flySpeed = 0
    return self
end

function ActionExecutor:execute(action)
    if not action then return end
    print("[Executor] Hành động:", action.action, action.speed or "")
    if action.action == "fly" then
        self.isFlying = true
        self.flySpeed = action.speed or 50
    elseif action.action == "stop" then
        self.isFlying = false
        self.flySpeed = 0
    elseif action.action == "jump" then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
        end
    elseif action.action == "sit" then
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.Sit = true end
    elseif action.action == "stand" then
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.Sit = false end
    elseif action.action == "effect" then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Head") then
            local p = Instance.new("ParticleEmitter")
            p.Parent = char.Head
            p.Texture = "rbxassetid://10747310929"
            task.wait(1.5)
            p:Destroy()
        end
    end
    return true
end

-- ============================================================
-- PHẦN 5: RESPONSE MANAGER
-- ============================================================
local ResponseManager = {}
ResponseManager.__index = ResponseManager

function ResponseManager.new()
    local self = setmetatable({}, ResponseManager)
    self.queue = {}
    self.isProcessing = false
    return self
end

function ResponseManager:addResponse(data)
    if not data or not data.message then return end
    table.insert(self.queue, data)
    if not self.isProcessing then self:processQueue() end
end

function ResponseManager:processQueue()
    if #self.queue == 0 then self.isProcessing = false return end
    self.isProcessing = true
    local data = table.remove(self.queue, 1)
    print("[Verity] " .. data.message)
    -- Hiển thị UI (nếu có)
    task.wait(data.duration or 2)
    self.isProcessing = false
    self:processQueue()
end

-- ============================================================
-- PHẦN 6: EMOTION ENGINE
-- ============================================================
local EmotionEngine = {}
EmotionEngine.__index = EmotionEngine

function EmotionEngine.new()
    local self = setmetatable({}, EmotionEngine)
    self.current = "NORMAL"
    return self
end

function EmotionEngine:setEmotion(emotion)
    self.current = emotion or "NORMAL"
    print("[Emotion] " .. self.current)
end

-- ============================================================
-- PHẦN 7: UI MANAGER
-- ============================================================
local UIManager = {}
UIManager.__index = UIManager

function UIManager.new()
    local self = setmetatable({}, UIManager)
    self.callbacks = {}
    print("[UI] Đã tạo (giao diện console)")
    return self
end

function UIManager:onRecord(cb) self.callbacks.record = cb end
function UIManager:onFly(cb) self.callbacks.fly = cb end
function UIManager:onStatus(cb) self.callbacks.status = cb end
function UIManager:onClose(cb) self.callbacks.close = cb end

function UIManager:setFlyButtonState(state) print("[UI] Bay:", state and "ON" or "OFF") end

-- ============================================================
-- PHẦN 8: MAIN
-- ============================================================
local player = game.Players.LocalPlayer

-- Khởi tạo
local voice = VoiceRecorder.new()
local stt = SpeechToText.new()
local cmdProc = CommandProcessor.new()
local executor = ActionExecutor.new()
local respMgr = ResponseManager.new()
local emotion = EmotionEngine.new()
local ui = UIManager.new()

-- Xử lý ghi âm
ui:onRecord(function()
    voice:startRecording(function(text)
        respMgr:addResponse({ message = "🎤 Tôi nghe: " .. text, duration = 1.5 })
        local result = cmdProc:process(text)
        executor:execute(result)
        emotion:setEmotion(result.emotion)
        respMgr:addResponse({ message = result.message, duration = 2 })
    end)
end)

-- Xử lý bay
ui:onFly(function()
    if executor.isFlying then
        executor:execute({ action = "stop" })
        respMgr:addResponse({ message = "🛑 Dừng bay", duration = 1.5 })
    else
        executor:execute({ action = "fly", speed = 50 })
        respMgr:addResponse({ message = "🛫 Bay 50 km/h", duration = 1.5 })
    end
    ui:setFlyButtonState(executor.isFlying)
end)

-- Trạng thái
ui:onStatus(function()
    respMgr:addResponse({ message = "📊 Verity đang chạy!", duration = 2 })
end)

-- Chat
player.Chatted:Connect(function(msg)
    if string.find(string.lower(msg), "verity") or string.find(string.lower(msg), "hey") then
        local result = cmdProc:process(msg)
        executor:execute(result)
        emotion:setEmotion(result.emotion)
        respMgr:addResponse({ message = result.message, duration = 2 })
    end
end)

-- Thông báo
respMgr:addResponse({ message = "👋 Xin chào! Tôi là Verity V5.0", duration = 3 })
respMgr:addResponse({ message = "💬 Gõ 'verity' hoặc nhấn MIC để trò chuyện", duration = 3 })

print("✅ Verity AI đã sẵn sàng!")
