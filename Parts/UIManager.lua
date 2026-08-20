--[[
    palofsc - 07_UIManager.lua
    PHẦN 7: QUẢN LÝ GIAO DIỆN
    - Tạo và quản lý giao diện Verity
    - Hiển thị hình ảnh, chat bubble, nút bấm
    - Tích hợp với Emotion Engine và Response Manager
--]]

-- ============================================================
-- UI MANAGER MODULE
-- ============================================================

local UIManager = {}
UIManager.__index = UIManager

-- ============================================================
-- BIẾN TOÀN CỤC
-- ============================================================

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local tweenService = game:GetService("TweenService")

-- ============================================================
-- TẠO INSTANCE
-- ============================================================

function UIManager.new(emotionEngine)
    local self = setmetatable({}, UIManager)
    
    -- Tham chiếu
    self.emotionEngine = emotionEngine
    
    -- GUI
    self.gui = nil
    self.mainFrame = nil
    self.verityImage = nil
    self.chatBubble = nil
    self.chatText = nil
    self.statusBar = nil
    
    -- Nút bấm
    self.buttons = {}
    
    -- Trạng thái
    self.isVisible = true
    self.isChatBubbleVisible = false
    self.isDragging = false
    self.dragOffset = nil
    
    -- Cấu hình
    self.config = {
        position = UDim2.new(0, 20, 0, 80),
        size = UDim2.new(0, 220, 0, 280),
        bubbleSize = UDim2.new(0, 240, 0, 80),
        bubbleOffset = UDim2.new(0, 250, 0, 80),
        animationDuration = 0.3
    }
    
    -- Callbacks
    self.onRecord = nil
    self.onFly = nil
    self.onStatus = nil
    self.onClose = nil
    
    -- Tạo GUI
    self:createGUI()
    
    return self
end

-- ============================================================
-- TẠO GUI
-- ============================================================

function UIManager:createGUI()
    -- Xóa GUI cũ nếu có
    if self.gui then
        self.gui:Destroy()
    end
    
    -- Tạo ScreenGui
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "VerityUI"
    self.gui.ResetOnSpawn = false
    self.gui.Parent = playerGui
    
    -- Main Frame
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = self.config.size
    self.mainFrame.Position = self.config.position
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
    self.mainFrame.BackgroundTransparency = 0.15
    self.mainFrame.BorderSizePixel = 2
    self.mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 255)
    self.mainFrame.Parent = self.gui
    
    -- Drag functionality
    self:setupDrag()
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "✨ VERITY AI V5.0"
    title.TextColor3 = Color3.fromRGB(255, 200, 100)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = self.mainFrame
    
    -- Close Button
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -28, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Parent = self.mainFrame
    closeBtn.Image = "rbxassetid://11458268186"
    closeBtn.ScaleType = Enum.ScaleType.Fit
    closeBtn.MouseButton1Click:Connect(function()
        if self.onClose then
            self.onClose()
        end
        self:setVisible(false)
    end)
    
    -- Verity Image
    self.verityImage = Instance.new("ImageLabel")
    self.verityImage.Name = "VerityImage"
    self.verityImage.Size = UDim2.new(0, 170, 0, 150)
    self.verityImage.Position = UDim2.new(0, 25, 0, 30)
    self.verityImage.BackgroundTransparency = 1
    self.verityImage.Parent = self.mainFrame
    self.verityImage.Image = "rbxassetid://137200437629946"
    self.verityImage.ScaleType = Enum.ScaleType.Fit
    
    -- Record Button
    local recordBtn = self:createButton("RecordBtn", UDim2.new(0, 10, 0, 210), UDim2.new(0, 50, 0, 50))
    recordBtn.Image = "rbxassetid://11487267733"
    recordBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    recordBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    recordBtn.MouseButton1Click:Connect(function()
        if self.onRecord then
            self.onRecord()
        end
    end)
    self.buttons.record = recordBtn
    
    -- Fly Button
    local flyBtn = self:createButton("FlyBtn", UDim2.new(0, 70, 0, 210), UDim2.new(0, 50, 0, 50))
    flyBtn.Image = "rbxassetid://11433602885"
    flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 200)
    flyBtn.BorderColor3 = Color3.fromRGB(0, 100, 255)
    flyBtn.MouseButton1Click:Connect(function()
        if self.onFly then
            self.onFly()
        end
    end)
    self.buttons.fly = flyBtn
    
    -- Status Button
    local statusBtn = self:createButton("StatusBtn", UDim2.new(0, 130, 0, 210), UDim2.new(0, 50, 0, 50))
    statusBtn.Image = "rbxassetid://11487369734"
    statusBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    statusBtn.BorderColor3 = Color3.fromRGB(0, 255, 0)
    statusBtn.MouseButton1Click:Connect(function()
        if self.onStatus then
            self.onStatus()
        end
    end)
    self.buttons.status = statusBtn
    
    -- Chat Bubble
    self:createChatBubble()
    
    -- Status Bar
    self.statusBar = Instance.new("TextLabel")
    self.statusBar.Name = "StatusBar"
    self.statusBar.Size = UDim2.new(0, 220, 0, 20)
    self.statusBar.Position = UDim2.new(0, 0, 0, 260)
    self.statusBar.BackgroundTransparency = 0.5
    self.statusBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.statusBar.Text = "🟢 Online - Sẵn sàng"
    self.statusBar.TextColor3 = Color3.fromRGB(0, 255, 0)
    self.statusBar.TextSize = 12
    self.statusBar.Font = Enum.Font.Gotham
    self.statusBar.Parent = self.mainFrame
    
    -- Cập nhật trạng thái cảm xúc
    if self.emotionEngine then
        self:updateEmotion(self.emotionEngine.currentEmotion)
    end
end

-- ============================================================
-- TẠO NÚT BẤM
-- ============================================================

function UIManager:createButton(name, position, size)
    local btn = Instance.new("ImageButton")
    btn.Name = name
    btn.Size = size or UDim2.new(0, 50, 0, 50)
    btn.Position = position or UDim2.new(0, 0, 0, 0)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = self.mainFrame
    btn.ScaleType = Enum.ScaleType.Fit
    return btn
end

-- ============================================================
-- TẠO CHAT BUBBLE
-- ============================================================

function UIManager:createChatBubble()
    self.chatBubble = Instance.new("Frame")
    self.chatBubble.Name = "ChatBubble"
    self.chatBubble.Size = UDim2.new(0, 0, 0, 80)
    self.chatBubble.Position = self.config.bubbleOffset
    self.chatBubble.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
    self.chatBubble.BackgroundTransparency = 0.1
    self.chatBubble.BorderSizePixel = 1
    self.chatBubble.BorderColor3 = Color3.fromRGB(100, 100, 255)
    self.chatBubble.Visible = false
    self.chatBubble.Parent = self.gui
    
    -- Mũi tên chỉ
    local arrow = Instance.new("Frame")
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(0, -10, 0.5, -10)
    arrow.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
    arrow.BorderSizePixel = 0
    arrow.Parent = self.chatBubble
    arrow.Rotation = 45
    
    -- Chat Text
    self.chatText = Instance.new("TextLabel")
    self.chatText.Name = "ChatText"
    self.chatText.Size = UDim2.new(1, -20, 1, -10)
    self.chatText.Position = UDim2.new(0, 10, 0, 5)
    self.chatText.BackgroundTransparency = 1
    self.chatText.Text = ""
    self.chatText.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.chatText.TextSize = 14
    self.chatText.TextWrapped = true
    self.chatText.TextXAlignment = Enum.TextXAlignment.Left
    self.chatText.Parent = self.chatBubble
end

-- ============================================================
-- DRAG FUNCTIONALITY
-- ============================================================

function UIManager:setupDrag()
    local dragging = false
    local dragStart = nil
    local frameStart = nil
    
    self.mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = self.mainFrame.Position
        end
    end)
    
    self.mainFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = frameStart.X.Offset + delta.X
            local newY = frameStart.Y.Offset + delta.Y
            
            -- Giới hạn trong màn hình
            newX = math.max(0, math.min(newX, 500))
            newY = math.max(0, math.min(newY, 300))
            
            self.mainFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    
    self.mainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ============================================================
-- CẬP NHẬT CẢM XÚC
-- ============================================================

function UIManager:updateEmotion(emotion)
    if not self.emotionEngine then return end
    
    local data = self.emotionEngine:getEmotionData(emotion)
    if self.verityImage then
        self.verityImage.Image = "rbxassetid://" .. data.id
    end
    
    if self.mainFrame then
        self.mainFrame.BorderColor3 = data.color
    end
    
    if self.statusBar then
        self.statusBar.Text = data.emoji .. " " .. data.name
        self.statusBar.TextColor3 = data.color
    end
end

-- ============================================================
-- HIỂN THỊ CHAT BUBBLE
-- ============================================================

function UIManager:showChatBubble(text, duration, emotion)
    if not self.chatBubble or not self.chatText then return end
    
    -- Cập nhật văn bản
    self.chatText.Text = text or ""
    
    -- Đổi màu theo cảm xúc
    if emotion and self.emotionEngine then
        local data = self.emotionEngine:getEmotionData(emotion)
        self.chatBubble.BorderColor3 = data.color
    end
    
    -- Hiển thị với animation
    self.chatBubble.Visible = true
    self.chatBubble.Size = UDim2.new(0, 0, 0, 80)
    
    tweenService:Create(self.chatBubble, TweenInfo.new(self.config.animationDuration), {
        Size = self.config.bubbleSize
    }):Play()
    
    self.isChatBubbleVisible = true
    
    -- Tự động ẩn sau thời gian
    if duration then
        task.wait(duration)
        self:hideChatBubble()
    end
end

function UIManager:hideChatBubble()
    if not self.chatBubble then return end
    
    tweenService:Create(self.chatBubble, TweenInfo.new(self.config.animationDuration), {
        Size = UDim2.new(0, 0, 0, 80)
    }):Play()
    
    task.wait(self.config.animationDuration)
    self.chatBubble.Visible = false
    self.isChatBubbleVisible = false
end

-- ============================================================
-- CẬP NHẬT STATUS
-- ============================================================

function UIManager:setStatus(text, color)
    if self.statusBar then
        self.statusBar.Text = text
        if color then
            self.statusBar.TextColor3 = color
        end
    end
end

-- ============================================================
-- HIỂN THỊ/ẨN GUI
-- ============================================================

function UIManager:setVisible(visible)
    self.isVisible = visible
    if self.gui then
        self.gui.Enabled = visible
    end
end

function UIManager:toggleVisible()
    self:setVisible(not self.isVisible)
end

-- ============================================================
-- CẬP NHẬT NÚT BAY
-- ============================================================

function UIManager:setFlyButtonState(isFlying)
    local btn = self.buttons.fly
    if not btn then return end
    
    if isFlying then
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
        btn.Image = "rbxassetid://11433602885"  -- Icon đang bay
    else
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 200)
        btn.BorderColor3 = Color3.fromRGB(0, 100, 255)
        btn.Image = "rbxassetid://11433602885"
    end
end

-- ============================================================
-- ĐĂNG KÝ CALLBACK
-- ============================================================

function UIManager:onRecord(callback)
    self.onRecord = callback
end

function UIManager:onFly(callback)
    self.onFly = callback
end

function UIManager:onStatus(callback)
    self.onStatus = callback
end

function UIManager:onClose(callback)
    self.onClose = callback
end

-- ============================================================
-- CẤU HÌNH
-- ============================================================

function UIManager:setPosition(udim2)
    self.config.position = udim2
    if self.mainFrame then
        self.mainFrame.Position = udim2
    end
end

function UIManager:setSize(udim2)
    self.config.size = udim2
    if self.mainFrame then
        self.mainFrame.Size = udim2
    end
end

-- ============================================================
-- TẠO INSTANCE (ALTERNATIVE)
-- ============================================================

function UIManager.create(emotionEngine)
    return UIManager.new(emotionEngine)
end

-- ============================================================
-- VÍ DỤ SỬ DỤNG
-- ============================================================

--[[
-- Tạo emotion engine và UI manager
local ee = EmotionEngine.new()
local ui = UIManager.new(ee)

-- Đăng ký callbacks
ui:onRecord(function()
    print("🎤 Nút ghi âm được bấm")
end)

ui:onFly(function()
    print("🚀 Nút bay được bấm")
end)

ui:onStatus(function()
    print("📊 Nút trạng thái được bấm")
end)

ui:onClose(function()
    print("❌ Đóng UI")
end)

-- Hiển thị chat bubble
ui:showChatBubble("Xin chào! Tôi là Verity", 3, "HAPPY")

-- Cập nhật trạng thái
ui:setStatus("🟢 Online", Color3.fromRGB(0, 255, 0))

-- Cập nhật cảm xúc
ui:updateEmotion("EXCITED")

-- Ẩn UI
ui:setVisible(false)

-- Sau đó hiện lại
ui:setVisible(true)
--]]

return UIManager
