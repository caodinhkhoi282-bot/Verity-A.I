--[[
    palofsc - 04_ActionExecutor.lua
    PHẦN 4: THỰC HIỆN HÀNH ĐỘNG
    - Thực thi các hành động trong game
    - Điều khiển nhân vật (bay, nhảy, ngồi, đứng)
    - Tạo hiệu ứng đặc biệt
    - Quản lý trạng thái bay
--]]

-- ============================================================
-- ACTION EXECUTOR MODULE
-- ============================================================

local ActionExecutor = {}
ActionExecutor.__index = ActionExecutor

-- ============================================================
-- BIẾN TOÀN CỤC
-- ============================================================

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- ============================================================
-- TẠO INSTANCE
-- ============================================================

function ActionExecutor.new()
    local self = setmetatable({}, ActionExecutor)
    
    -- Trạng thái bay
    self.isFlying = false
    self.flySpeed = 0
    self.maxSpeed = 100
    
    -- Trạng thái nhân vật
    self.character = nil
    self.humanoid = nil
    self.rootPart = nil
    
    -- Cập nhật nhân vật
    self:updateCharacter()
    
    -- Kết nối sự kiện
    self:connectEvents()
    
    return self
end

-- ============================================================
-- CẬP NHẬT NHÂN VẬT
-- ============================================================

function ActionExecutor:updateCharacter()
    self.character = player.Character or player.CharacterAdded:Wait()
    if self.character then
        self.humanoid = self.character:FindFirstChild("Humanoid")
        self.rootPart = self.character:FindFirstChild("HumanoidRootPart")
    end
end

-- ============================================================
-- KẾT NỐI SỰ KIỆN
-- ============================================================

function ActionExecutor:connectEvents()
    -- Khi nhân vật mới xuất hiện
    player.CharacterAdded:Connect(function(char)
        self.character = char
        self.humanoid = char:FindFirstChild("Humanoid")
        self.rootPart = char:FindFirstChild("HumanoidRootPart")
    end)
    
    -- Vòng lặp bay
    runService.Heartbeat:Connect(function(deltaTime)
        self:updateFly(deltaTime)
    end)
end

-- ============================================================
-- THỰC HIỆN HÀNH ĐỘNG
-- ============================================================

function ActionExecutor:execute(action)
    if not action then return false end
    
    local act = action.action or "chat"
    local message = action.message or ""
    local emotion = action.emotion or "NORMAL"
    
    -- Cập nhật nhân vật
    self:updateCharacter()
    
    -- Thực thi theo loại hành động
    if act == "fly" then
        return self:actionFly(action)
    elseif act == "stop" then
        return self:actionStop()
    elseif act == "speed_up" then
        return self:actionSpeedUp(action)
    elseif act == "speed_down" then
        return self:actionSpeedDown(action)
    elseif act == "jump" then
        return self:actionJump()
    elseif act == "sit" then
        return self:actionSit()
    elseif act == "stand" then
        return self:actionStand()
    elseif act == "teleport" then
        return self:actionTeleport(action)
    elseif act == "effect" then
        return self:actionEffect(action)
    elseif act == "math" then
        return self:actionMath(action)
    elseif act == "chat" then
        return self:actionChat(action)
    elseif act == "wave" then
        return self:actionWave()
    elseif act == "dance" then
        return self:actionDance()
    else
        -- Hành động không xác định
        print("[Executor] Hành động không xác định:", act)
        return false
    end
end

-- ============================================================
-- HÀNH ĐỘNG CỤ THỂ
-- ============================================================

-- 1. BAY
function ActionExecutor:actionFly(action)
    local speed = action.speed or 50
    speed = math.min(math.max(speed, 1), self.maxSpeed)
    
    self.isFlying = true
    self.flySpeed = speed
    
    print("[Executor] Bay với tốc độ:", speed, "km/h")
    return true
end

-- 2. DỪNG BAY
function ActionExecutor:actionStop()
    self.isFlying = false
    self.flySpeed = 0
    
    if self.rootPart then
        self.rootPart.Velocity = Vector3.new(0, 0, 0)
    end
    
    print("[Executor] Đã dừng bay")
    return true
end

-- 3. TĂNG TỐC
function ActionExecutor:actionSpeedUp(action)
    if not self.isFlying then
        self.isFlying = true
    end
    
    local amount = action.amount or 10
    self.flySpeed = math.min(self.flySpeed + amount, self.maxSpeed)
    
    print("[Executor] Tăng tốc lên:", self.flySpeed, "km/h")
    return true
end

-- 4. GIẢM TỐC
function ActionExecutor:actionSpeedDown(action)
    local amount = action.amount or 10
    self.flySpeed = math.max(self.flySpeed - amount, 0)
    
    if self.flySpeed == 0 and self.isFlying then
        self.isFlying = false
        if self.rootPart then
            self.rootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
    
    print("[Executor] Giảm tốc xuống:", self.flySpeed, "km/h")
    return true
end

-- 5. NHẢY
function ActionExecutor:actionJump()
    if self.rootPart then
        self.rootPart.Velocity = Vector3.new(0, 50, 0)
        print("[Executor] Nhảy lên!")
        return true
    end
    return false
end

-- 6. NGỒI
function ActionExecutor:actionSit()
    if self.humanoid then
        self.humanoid.Sit = true
        print("[Executor] Ngồi xuống")
        return true
    end
    return false
end

-- 7. ĐỨNG
function ActionExecutor:actionStand()
    if self.humanoid then
        self.humanoid.Sit = false
        print("[Executor] Đứng lên")
        return true
    end
    return false
end

-- 8. DỊCH CHUYỂN
function ActionExecutor:actionTeleport(action)
    local pos = action.pos
    if self.rootPart and pos then
        local target = Vector3.new(pos.x or 0, pos.y or 10, pos.z or 0)
        self.rootPart.Position = target
        print("[Executor] Dịch chuyển đến:", target.X, target.Y, target.Z)
        return true
    end
    return false
end

-- 9. HIỆU ỨNG
function ActionExecutor:actionEffect(action)
    self:updateCharacter()
    if not self.character then return false end
    
    -- Tìm head để gắn hiệu ứng
    local head = self.character:FindFirstChild("Head")
    if not head then return false end
    
    -- Tạo hiệu ứng hạt
    local particle = Instance.new("ParticleEmitter")
    particle.Parent = head
    particle.Texture = "rbxassetid://10747310929"
    particle.Rate = 200
    particle.Lifetime = NumberRange.new(1.5)
    particle.SpreadAngle = Vector2.new(360, 360)
    particle.VelocityInheritance = 0.5
    particle.Speed = NumberRange.new(10, 20)
    particle.Size = NumberSequence.new(0.5)
    particle.Transparency = NumberSequence.new(0.5)
    particle.Color = ColorSequence.new(Color3.fromRGB(255, 200, 100))
    
    -- Tạo thêm hiệu ứng ánh sáng
    local light = Instance.new("PointLight")
    light.Parent = head
    light.Color = Color3.fromRGB(255, 200, 100)
    light.Brightness = 5
    light.Range = 20
    
    -- Tự động xóa sau 2 giây
    task.wait(2)
    particle:Destroy()
    light:Destroy()
    
    print("[Executor] Hiệu ứng phép thuật")
    return true
end

-- 10. TOÁN HỌC
function ActionExecutor:actionMath(action)
    if action.result then
        print("[Executor] Kết quả toán học:", action.result)
        return true
    end
    return false
end

-- 11. CHAT
function ActionExecutor:actionChat(action)
    if action.message then
        print("[Executor] Chat:", action.message)
        return true
    end
    return false
end

-- 12. VẪY TAY
function ActionExecutor:actionWave()
    self:updateCharacter()
    if not self.character then return false end
    
    local arm = self.character:FindFirstChild("RightArm")
    if not arm then return false end
    
    -- Animation vẫy tay
    local originalCF = arm.CFrame
    local waveCF = originalCF * CFrame.Angles(0, 0, -math.rad(30))
    
    tweenService:Create(arm, TweenInfo.new(0.2), {
        CFrame = waveCF
    }):Play()
    
    task.wait(0.5)
    
    tweenService:Create(arm, TweenInfo.new(0.2), {
        CFrame = originalCF
    }):Play()
    
    print("[Executor] Vẫy tay chào")
    return true
end

-- 13. NHẢY MÚA
function ActionExecutor:actionDance()
    self:updateCharacter()
    if not self.character then return false end
    
    local animations = {
        function() -- Động tác 1
            if self.rootPart then
                self.rootPart.CFrame = self.rootPart.CFrame * CFrame.Angles(0, 0, math.rad(10))
            end
        end,
        function() -- Động tác 2
            if self.rootPart then
                self.rootPart.CFrame = self.rootPart.CFrame * CFrame.Angles(0, 0, -math.rad(10))
            end
        end,
        function() -- Động tác 3
            if self.rootPart then
                self.rootPart.CFrame = self.rootPart.CFrame * CFrame.Angles(0, math.rad(5), 0)
            end
        end
    }
    
    -- Chạy animation trong 3 giây
    for i = 1, 15 do
        local anim = animations[math.random(#animations)]
        anim()
        task.wait(0.2)
    end
    
    -- Reset về bình thường
    if self.rootPart then
        self.rootPart.CFrame = self.rootPart.CFrame * CFrame.Angles(0, 0, 0)
    end
    
    print("[Executor] Đang nhảy múa!")
    return true
end

-- ============================================================
-- CẬP NHẬT BAY (VÒNG LẶP)
-- ============================================================

function ActionExecutor:updateFly(deltaTime)
    if not self.isFlying then return end
    
    self:updateCharacter()
    if not self.rootPart then return end
    
    -- Lấy camera
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    -- Hướng nhìn
    local lookVector = camera.CFrame.LookVector
    
    -- Tốc độ bay (km/h -> đơn vị game)
    local speed = self.flySpeed * deltaTime * 10
    local velocity = lookVector * speed + Vector3.new(0, 2, 0)
    
    -- Áp dụng vận tốc
    self.rootPart.Velocity = velocity
    
    -- Điều khiển lên/xuống
    if userInputService:IsKeyDown(Enum.KeyCode.Space) then
        self.rootPart.Velocity = self.rootPart.Velocity + Vector3.new(0, speed * 2, 0)
    end
    
    if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        self.rootPart.Velocity = self.rootPart.Velocity - Vector3.new(0, speed * 2, 0)
    end
end

-- ============================================================
-- LẤY TRẠNG THÁI
-- ============================================================

function ActionExecutor:getStatus()
    return {
        isFlying = self.isFlying,
        flySpeed = self.flySpeed,
        maxSpeed = self.maxSpeed,
        character = self.character ~= nil,
        humanoid = self.humanoid ~= nil,
        rootPart = self.rootPart ~= nil
    }
end

-- ============================================================
-- CẤU HÌNH
-- ============================================================

function ActionExecutor:setMaxSpeed(speed)
    self.maxSpeed = math.max(speed, 1)
end

function ActionExecutor:getMaxSpeed()
    return self.maxSpeed
end

-- ============================================================
-- TẠO INSTANCE (ALTERNATIVE)
-- ============================================================

function ActionExecutor.create()
    return ActionExecutor.new()
end

-- ============================================================
-- VÍ DỤ SỬ DỤNG
-- ============================================================

--[[
-- Tạo executor
local executor = ActionExecutor.new()

-- Thực hiện các hành động
executor:execute({
    action = "fly",
    speed = 80,
    message = "🛫 Bay với tốc độ 80 km/h"
})

-- Dừng bay
executor:execute({
    action = "stop",
    message = "🛑 Dừng bay"
})

-- Nhảy
executor:execute({
    action = "jump",
    message = "🦘 Nhảy lên!"
})

-- Hiệu ứng
executor:execute({
    action = "effect",
    message = "✨ Phép thuật!"
})

-- Vẫy tay
executor:execute({
    action = "wave",
    message = "👋 Chào bạn!"
})
--]]

return ActionExecutor
