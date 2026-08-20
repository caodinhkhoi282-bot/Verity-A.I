--[[
    palofsc - 03_CommandProcessor.lua
    PHẦN 3: XỬ LÝ LỆNH
    - Phân tích văn bản từ người dùng
    - Tìm lệnh phù hợp với từ khóa
    - Trích xuất tham số và xử lý
    - Trả về hành động tương ứng
--]]

-- ============================================================
-- COMMAND PROCESSOR MODULE
-- ============================================================

local CommandProcessor = {}
CommandProcessor.__index = CommandProcessor

-- ============================================================
-- DANH SÁCH LỆNH
-- ============================================================

local DEFAULT_COMMANDS = {
    -- Lệnh bay
    fly = {
        keywords = {"bay", "fly", "cất cánh", "take off", "лететь", "飞"},
        description = "Bay với tốc độ chỉ định",
        usage = "bay [tốc độ]",
        action = function(args, context)
            local speed = tonumber(args[1]) or 50
            speed = math.min(math.max(speed, 1), context.maxSpeed or 100)
            return {
                action = "fly",
                speed = speed,
                message = "🛫 Đang bay với tốc độ " .. speed .. " km/h!",
                emotion = "HAPPY"
            }
        end
    },
    
    stop = {
        keywords = {"dừng", "stop", "hạ cánh", "land", "остановить", "停"},
        description = "Dừng bay",
        usage = "dừng",
        action = function()
            return {
                action = "stop",
                message = "🛑 Đã dừng bay!",
                emotion = "NORMAL"
            }
        end
    },
    
    speed_up = {
        keywords = {"tăng tốc", "speed up", "faster", "ускорить", "加速"},
        description = "Tăng tốc độ bay",
        usage = "tăng tốc [số km/h]",
        action = function(args, context)
            local amount = tonumber(args[1]) or 10
            return {
                action = "speed_up",
                amount = amount,
                message = "⚡ Tăng tốc lên " .. amount .. " km/h!",
                emotion = "EXCITED"
            }
        end
    },
    
    speed_down = {
        keywords = {"giảm tốc", "slow down", "slower", "замедлить", "减速"},
        description = "Giảm tốc độ bay",
        usage = "giảm tốc [số km/h]",
        action = function(args)
            local amount = tonumber(args[1]) or 10
            return {
                action = "speed_down",
                amount = amount,
                message = "🐢 Giảm tốc xuống " .. amount .. " km/h!",
                emotion = "NORMAL"
            }
        end
    },
    
    -- Lệnh di chuyển
    jump = {
        keywords = {"nhảy", "jump", "прыгать", "跳"},
        description = "Nhảy lên cao",
        usage = "nhảy",
        action = function()
            return {
                action = "jump",
                message = "🦘 Nhảy lên nào!",
                emotion = "EXCITED"
            }
        end
    },
    
    sit = {
        keywords = {"ngồi", "sit", "сидеть", "坐"},
        description = "Ngồi xuống",
        usage = "ngồi",
        action = function()
            return {
                action = "sit",
                message = "🪑 Đang ngồi!",
                emotion = "NORMAL"
            }
        end
    },
    
    stand = {
        keywords = {"đứng", "stand", "стоять", "站"},
        description = "Đứng lên",
        usage = "đứng",
        action = function()
            return {
                action = "stand",
                message = "🧍 Đứng lên!",
                emotion = "NORMAL"
            }
        end
    },
    
    teleport = {
        keywords = {"dịch chuyển", "teleport", "tp", "телепорт", "传送"},
        description = "Dịch chuyển đến tọa độ",
        usage = "dịch chuyển [x] [y] [z]",
        action = function(args)
            local x = tonumber(args[1]) or 0
            local y = tonumber(args[2]) or 10
            local z = tonumber(args[3]) or 0
            return {
                action = "teleport",
                pos = {x = x, y = y, z = z},
                message = "🌀 Dịch chuyển đến " .. x .. ", " .. y .. ", " .. z,
                emotion = "EXCITED"
            }
        end
    },
    
    -- Lệnh đặc biệt
    effect = {
        keywords = {"phép thuật", "effect", "magic", "магия", "魔法"},
        description = "Tạo hiệu ứng đặc biệt",
        usage = "phép thuật",
        action = function()
            return {
                action = "effect",
                message = "✨ Phép thuật đang thi triển!",
                emotion = "EXCITED"
            }
        end
    },
    
    math = {
        keywords = {"tính", "math", "toán", "calculate", "вычислить", "算"},
        description = "Tính toán biểu thức",
        usage = "tính [biểu thức]",
        action = function(args)
            local expr = table.concat(args, " ")
            local success, result = pcall(function()
                return loadstring("return " .. expr)()
            end)
            if success and result then
                return {
                    action = "math",
                    result = result,
                    message = "🧮 Kết quả: " .. tostring(result),
                    emotion = "HAPPY"
                }
            end
            return {
                action = "chat",
                message = "🤔 Không hiểu phép toán!",
                emotion = "CONFUSED"
            }
        end
    },
    
    -- Lệnh thông tin
    help = {
        keywords = {"giúp", "help", "hướng dẫn", "помощь", "帮助"},
        description = "Hiển thị danh sách lệnh",
        usage = "giúp",
        action = function(self)
            local helpText = "📖 DANH SÁCH LỆNH:\n\n"
            for name, cmd in pairs(self.commands or DEFAULT_COMMANDS) do
                helpText = helpText .. "  • " .. name .. "\n"
                helpText = helpText .. "    " .. (cmd.description or "") .. "\n"
                if cmd.usage then
                    helpText = helpText .. "    Cách dùng: " .. cmd.usage .. "\n"
                end
                helpText = helpText .. "\n"
            end
            return {
                action = "chat",
                message = helpText,
                emotion = "NORMAL"
            }
        end
    },
    
    status = {
        keywords = {"trạng thái", "status", "thông tin", "состояние", "状态"},
        description = "Hiển thị trạng thái hiện tại",
        usage = "trạng thái",
        action = function(_, context)
            return {
                action = "chat",
                message = "📊 TRẠNG THÁI:\n" ..
                    "  • Bay: " .. (context.isFlying and "🟢 Bật" or "🔴 Tắt") .. "\n" ..
                    "  • Tốc độ: " .. (context.flySpeed or 0) .. " km/h\n" ..
                    "  • Cảm xúc: " .. (context.currentEmotion or "NORMAL") .. "\n" ..
                    "  • Ghi âm: " .. (context.isRecording and "🟢 Đang ghi" or "🔴 Tắt") .. "\n" ..
                    "  • Người chơi: " .. (context.playerName or "Unknown"),
                emotion = "NORMAL"
            }
        end
    }
}

-- ============================================================
-- PHẢN HỒI CẢM XÚC
-- ============================================================

local EMOTIONAL_RESPONSES = {
    greeting = {
        keywords = {"xin chào", "hello", "hi", "chào", "привет", "你好"},
        replies = {
            "👋 Xin chào! Tôi là Verity, rất vui được gặp bạn!",
            "❤️ Chào bạn! Tôi có thể giúp gì cho bạn không?",
            "🌟 Chào mừng bạn đã quay lại!",
            "💫 Xin chào! Bạn khỏe không?",
            "✨ Hi there! How can I help you today?"
        },
        emotion = "HAPPY"
    },
    
    thank = {
        keywords = {"cảm ơn", "thank", "thanks", "спасибо", "谢谢"},
        replies = {
            "❤️ Không có gì! Rất vui được giúp bạn!",
            "💖 Cảm ơn bạn đã tin tưởng tôi!",
            "🌟 Tôi luôn sẵn sàng giúp đỡ bạn!",
            "💫 Bạn thật tuyệt vời!"
        },
        emotion = "HAPPY"
    },
    
    sad = {
        keywords = {"buồn", "sad", "chán", "грустный", "悲伤"},
        replies = {
            "😢 Đừng buồn! Tôi ở đây với bạn!",
            "❤️ Mọi chuyện rồi sẽ tốt đẹp thôi!",
            "💪 Hãy mạnh mẽ lên nào!",
            "🌟 Tôi tin bạn có thể vượt qua!"
        },
        emotion = "SAD"
    },
    
    happy = {
        keywords = {"vui", "happy", "tuyệt", "счастливый", "开心"},
        replies = {
            "😊 Thật tuyệt! Tôi cũng vui vì bạn!",
            "🌟 Niềm vui của bạn là niềm vui của tôi!",
            "🎉 Cùng vui vẻ nào!",
            "💫 Hãy luôn giữ nụ cười nhé!"
        },
        emotion = "EXCITED"
    },
    
    confused = {
        keywords = {"không hiểu", "confused", "gì vậy", "не понимаю", "不懂"},
        replies = {
            "🤔 Tôi không hiểu. Bạn có thể nói rõ hơn được không?",
            "❓ Hãy diễn giải lại nhé!",
            "💭 Tôi đang suy nghĩ...",
            "🤷 Bạn có thể nói cách khác được không?"
        },
        emotion = "CONFUSED"
    },
    
    greedy = {
        keywords = {"tham lam", "greedy", "quá nhanh", "жадный", "贪婪"},
        replies = {
            "⚠️ Bạn quá tham lam!",
            "🚫 Không thể làm được điều đó!",
            "😅 Hãy khiêm tốn hơn nhé!",
            "⚖️ Mọi thứ cần có giới hạn!"
        },
        emotion = "GREEDY"
    }
}

-- ============================================================
-- HÀM XỬ LÝ LỆNH
-- ============================================================

function CommandProcessor:process(text, context)
    if not text or text == "" then
        return {
            action = "chat",
            message = "🤔 Bạn có thể nói gì đó không?",
            emotion = "CONFUSED"
        }
    end
    
    local lowerText = string.lower(text)
    context = context or {}
    context.commands = self.commands or DEFAULT_COMMANDS
    
    -- 1. Kiểm tra lệnh
    for cmdName, cmdData in pairs(context.commands) do
        for _, keyword in ipairs(cmdData.keywords) do
            if string.find(lowerText, keyword) then
                -- Trích xuất tham số
                local args = {}
                for word in string.gmatch(text, "%S+") do
                    table.insert(args, word)
                end
                table.remove(args, 1)  -- Bỏ từ khóa đầu tiên
                
                -- Thực thi lệnh
                local result = cmdData.action(args, context)
                if result then
                    return result
                end
            end
        end
    end
    
    -- 2. Kiểm tra phản hồi cảm xúc
    for respName, respData in pairs(EMOTIONAL_RESPONSES) do
        for _, keyword in ipairs(respData.keywords) do
            if string.find(lowerText, keyword) then
                local reply = respData.replies[math.random(#respData.replies)]
                return {
                    action = "chat",
                    message = reply,
                    emotion = respData.emotion
                }
            end
        end
    end
    
    -- 3. Mặc định - không hiểu
    return {
        action = "chat",
        message = "🤔 Tôi không hiểu. Bạn có thể nói rõ hơn được không?",
        emotion = "CONFUSED"
    }
end

-- ============================================================
-- THÊM LỆNH MỚI
-- ============================================================

function CommandProcessor:addCommand(name, data)
    if not name or not data then return false end
    
    self.commands = self.commands or DEFAULT_COMMANDS
    self.commands[name] = data
    return true
end

function CommandProcessor:removeCommand(name)
    if self.commands and self.commands[name] then
        self.commands[name] = nil
        return true
    end
    return false
end

-- ============================================================
-- THÊM PHẢN HỒI CẢM XÚC
-- ============================================================

function CommandProcessor:addEmotionalResponse(name, data)
    if not name or not data then return false end
    
    EMOTIONAL_RESPONSES[name] = data
    return true
end

-- ============================================================
-- LẤY DANH SÁCH LỆNH
-- ============================================================

function CommandProcessor:getCommands()
    return self.commands or DEFAULT_COMMANDS
end

function CommandProcessor:getCommandNames()
    local names = {}
    for name, _ in pairs(self.commands or DEFAULT_COMMANDS) do
        table.insert(names, name)
    end
    return names
end

-- ============================================================
-- KIỂM TRA TỪ KHÓA
-- ============================================================

function CommandProcessor:hasKeyword(text, keywords)
    if not text or not keywords then return false end
    local lowerText = string.lower(text)
    for _, keyword in ipairs(keywords) do
        if string.find(lowerText, keyword) then
            return true
        end
    end
    return false
end

-- ============================================================
-- TÁCH THAM SỐ
-- ============================================================

function CommandProcessor:extractParams(text, count)
    local words = {}
    for word in string.gmatch(text, "%S+") do
        table.insert(words, word)
    end
    
    if count then
        local params = {}
        for i = 2, math.min(count + 1, #words) do
            table.insert(params, words[i])
        end
        return params
    end
    
    -- Trả về tất cả sau từ khóa đầu tiên
    local params = {}
    for i = 2, #words do
        table.insert(params, words[i])
    end
    return params
end

-- ============================================================
-- TẠO INSTANCE
-- ============================================================

function CommandProcessor.new(commands)
    local self = setmetatable({}, CommandProcessor)
    self.commands = commands or DEFAULT_COMMANDS
    return self
end

-- ============================================================
-- VÍ DỤ SỬ DỤNG
-- ============================================================

--[[
-- Tạo instance
local processor = CommandProcessor.new()

-- Context (thông tin bổ sung)
local context = {
    isFlying = false,
    flySpeed = 0,
    currentEmotion = "NORMAL",
    maxSpeed = 100,
    playerName = "Player"
}

-- Xử lý lệnh
local text = "bay 80"
local result = processor:process(text, context)
print(result.message)  -- "🛫 Đang bay với tốc độ 80 km/h!"

-- Thêm lệnh mới
processor:addCommand("wave", {
    keywords = {"vẫy", "wave"},
    description = "Vẫy tay chào",
    action = function()
        return {
            action = "wave",
            message = "👋 Vẫy tay chào!",
            emotion = "HAPPY"
        }
    end
})

-- Xử lý lệnh mới
local result2 = processor:process("vẫy tay")
print(result2.message)  -- "👋 Vẫy tay chào!"
--]]

return CommandProcessor
