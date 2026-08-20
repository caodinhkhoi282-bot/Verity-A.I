--[[
    palofsc - 01_VoiceRecorder.lua
    PHẦN 1: GHI ÂM GIỌNG NÓI
    - Ghi âm giọng nói từ microphone (giả lập)
    - Hiển thị UI ghi âm với thanh tiến trình
    - Trả về văn bản giả lập từ giọng nói
    - Tương thích Delta Executor
--]]

-- ============================================================
-- VOICE RECORDER MODULE
-- ============================================================

local VoiceRecorder = {}
VoiceRecorder.__index = VoiceRecorder

-- Cấu hình ghi âm
local CONFIG = {
    RECORD_DURATION = 3,  -- Số giây ghi âm
    SAMPLE_RATE = 16000,  -- Tần số lấy mẫu (Hz)
    CHANNELS = 1          -- Mono
}

-- Danh sách các câu nói mẫu (giả lập nhận diện)
local SAMPLE_TEXTS = {
    -- Lệnh bay
    "bay 80",
    "bay 50",
    "bay nhanh lên 100",
    "dừng bay",
    "tăng tốc 20",
    "giảm tốc 10",
    
    -- Lệnh di chuyển
    "nhảy lên",
    "ngồi xuống",
    "đứng lên",
    "dịch chuyển 0 50 0",
    
    -- Lệnh đặc biệt
    "phép thuật",
    "tính 2 + 3 nhân 4",
    "tính 100 chia 4",
    
    -- Hỏi đáp
    "xin chào verity",
    "hello verity",
    "cảm ơn bạn",
    "tôi buồn",
    "tôi vui",
    "trạng thái",
    "giúp tôi với",
    "tên bạn là gì",
    "bạn là ai"
}

-- ============================================================
-- TẠO UI GHI ÂM
-- ============================================================

local function createRecordingUI(parent)
    local frame = Instance.new("Frame")
    frame.Name = "RecordingFrame"
    frame.Size = UDim2.new(0, 350, 0, 150)
    frame.Position = UDim2.new(0.5, -175, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    frame.Parent = parent or playerGui
    
    -- Icon microphone
    local micIcon = Instance.new("ImageLabel")
    micIcon.Size = UDim2.new(0, 50, 0, 50)
    micIcon.Position = UDim2.new(0.5, -25, 0, 10)
    micIcon.BackgroundTransparency = 1
    micIcon.Parent = frame
    micIcon.Image = "rbxassetid://11487267733"
    micIcon.ScaleType = Enum.ScaleType.Fit
    
    -- Text trạng thái
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, 0, 0, 30)
    statusText.Position = UDim2.new(0, 0, 0, 65)
    statusText.BackgroundTransparency = 1
    statusText.Text = "🔴 ĐANG GHI ÂM..."
    statusText.TextColor3 = Color3.fromRGB(255, 0, 0)
    statusText.TextSize = 20
    statusText.Font = Enum.Font.GothamBold
    statusText.Parent = frame
    
    -- Thanh tiến trình
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0.8, 0, 0, 10)
    progressBg.Position = UDim2.new(0.1, 0, 0.75, 0)
    progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    progressBg.Parent = frame
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 0, 10)
    progressBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    progressBar.Parent = progressBg
    
    -- Nút hủy
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 80, 0, 30)
    cancelBtn.Position = UDim2.new(0.5, -40, 0.92, 0)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    cancelBtn.Text = "Hủy"
    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 14
    cancelBtn.Parent = frame
    
    return frame, progressBar, statusText, cancelBtn
end

-- ============================================================
-- HÀM GHI ÂM CHÍNH
-- ============================================================

function VoiceRecorder:startRecording(callback)
    if self.isRecording then 
        if callback then callback(nil, "Đang ghi âm...") end
        return 
    end
    
    self.isRecording = true
    
    -- Tạo UI ghi âm
    local frame, progressBar, statusText, cancelBtn = createRecordingUI()
    
    -- Biến kiểm tra hủy
    local isCancelled = false
    
    cancelBtn.MouseButton1Click:Connect(function()
        isCancelled = true
        self.isRecording = false
        frame:Destroy()
        if callback then callback(nil, "Đã hủy ghi âm") end
    end)
    
    -- Mô phỏng ghi âm với tiến trình
    local startTime = tick()
    local duration = CONFIG.RECORD_DURATION
    
    while self.isRecording and tick() - startTime < duration do
        local progress = (tick() - startTime) / duration
        progressBar.Size = UDim2.new(progress, 0, 0, 10)
        
        -- Hiệu ứng nhấp nháy
        if math.floor(tick() * 3) % 2 == 0 then
            statusText.TextColor3 = Color3.fromRGB(255, 0, 0)
        else
            statusText.TextColor3 = Color3.fromRGB(200, 0, 0)
        end
        
        -- Cập nhật thời gian
        local remaining = math.ceil(duration - (tick() - startTime))
        statusText.Text = "🔴 ĐANG GHI ÂM... " .. remaining .. "s"
        
        task.wait(0.05)
    end
    
    -- Xóa UI
    frame:Destroy()
    self.isRecording = false
    
    -- Kiểm tra nếu bị hủy
    if isCancelled then return end
    
    -- Mô phỏng xử lý âm thanh (chuyển đổi giọng nói thành văn bản)
    statusText.Text = "⏳ Đang xử lý giọng nói..."
    task.wait(0.5)
    
    -- Chọn ngẫu nhiên một câu nói mẫu
    local recognizedText = SAMPLE_TEXTS[math.random(#SAMPLE_TEXTS)]
    
    -- Trả về kết quả
    if callback then
        callback(recognizedText, "Thành công")
    end
    
    return recognizedText
end

-- ============================================================
-- HÀM DỪNG GHI ÂM
-- ============================================================

function VoiceRecorder:stopRecording()
    self.isRecording = false
end

-- ============================================================
-- HÀM KIỂM TRA TRẠNG THÁI
-- ============================================================

function VoiceRecorder:isRecording()
    return self.isRecording
end

-- ============================================================
-- HÀM CẤU HÌNH
-- ============================================================

function VoiceRecorder:setDuration(duration)
    CONFIG.RECORD_DURATION = duration or 3
end

function VoiceRecorder:getDuration()
    return CONFIG.RECORD_DURATION
end

-- ============================================================
-- KHỞI TẠO MODULE
-- ============================================================

function VoiceRecorder.new()
    local self = setmetatable({}, VoiceRecorder)
    self.isRecording = false
    return self
end

-- ============================================================
-- VÍ DỤ SỬ DỤNG
-- ============================================================

--[[
-- Tạo instance
local recorder = VoiceRecorder.new()

-- Bắt đầu ghi âm
recorder:startRecording(function(text, status)
    if text then
        print("🎤 Nhận diện được: " .. text)
        -- Xử lý văn bản ở đây
    else
        print("❌ Lỗi: " .. status)
    end
end)

-- Hoặc dùng cách đơn giản:
local text = recorder:startRecording()
if text then
    print("🎤 Bạn nói: " .. text)
end
--]]

return VoiceRecorder
