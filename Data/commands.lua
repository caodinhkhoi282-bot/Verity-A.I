--[[
    palofsc - commands.lua
    DANH SÁCH LỆNH ĐẦY ĐỦ CHO VERITY AI
    Tất cả lệnh được tổ chức theo danh mục
    Hỗ trợ nhiều ngôn ngữ (Việt, Anh, Trung, Nga, Nhật, Hàn)
--]]

-- ============================================================
-- COMMANDS DATABASE
-- ============================================================

local COMMANDS = {
    -- ==========================================================
    -- NHÓM LỆNH BAY
    -- ==========================================================
    fly = {
        name = "Bay",
        description = "Bay với tốc độ chỉ định",
        keywords = {"bay", "fly", "cất cánh", "take off", "лететь", "飞", "飛ぶ", "날다"},
        usage = "bay [tốc độ]",
        category = "movement",
        action = function(args, context)
            local speed = tonumber(args[1]) or 50
            speed = math.min(math.max(speed, 1), context.maxSpeed or 100)
            return {
                action = "fly",
                speed = speed,
                message = "🛫 Đang bay với tốc độ " .. speed .. " km/h!",
                emotion = "HAPPY",
                details = {
                    speed = speed,
                    maxSpeed = context.maxSpeed
                }
            }
        end
    },
    
    stop = {
        name = "Dừng bay",
        description = "Dừng bay ngay lập tức",
        keywords = {"dừng", "stop", "hạ cánh", "land", "остановить", "停", "止まる", "멈추다"},
        usage = "dừng",
        category = "movement",
        action = function()
            return {
                action = "stop",
                message = "🛑 Đã dừng bay!",
                emotion = "NORMAL"
            }
        end
    },
    
    speed_up = {
        name = "Tăng tốc",
        description = "Tăng tốc độ bay",
        keywords = {"tăng tốc", "speed up", "faster", "ускорить", "加速", "速く", "가속"},
        usage = "tăng tốc [số km/h]",
        category = "movement",
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
        name = "Giảm tốc",
        description = "Giảm tốc độ bay",
        keywords = {"giảm tốc", "slow down", "slower", "замедлить", "减速", "遅く", "감속"},
        usage = "giảm tốc [số km/h]",
        category = "movement",
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
    
    -- ==========================================================
    -- NHÓM LỆNH DI CHUYỂN
    -- ==========================================================
    jump = {
        name = "Nhảy",
        description = "Nhảy lên cao",
        keywords = {"nhảy", "jump", "прыгать", "跳", "飛ぶ", "점프"},
        usage = "nhảy",
        category = "movement",
        action = function()
            return {
                action = "jump",
                message = "🦘 Nhảy lên nào!",
                emotion = "EXCITED"
            }
        end
    },
    
    sit = {
        name = "Ngồi",
        description = "Ngồi xuống",
        keywords = {"ngồi", "sit", "сидеть", "坐", "座る", "앉다"},
        usage = "ngồi",
        category = "movement",
        action = function()
            return {
                action = "sit",
                message = "🪑 Đang ngồi!",
                emotion = "NORMAL"
            }
        end
    },
    
    stand = {
        name = "Đứng",
        description = "Đứng lên",
        keywords = {"đứng", "stand", "стоять", "站", "立つ", "서다"},
        usage = "đứng",
        category = "movement",
        action = function()
            return {
                action = "stand",
                message = "🧍 Đứng lên!",
                emotion = "NORMAL"
            }
        end
    },
    
    teleport = {
        name = "Dịch chuyển",
        description = "Dịch chuyển đến tọa độ chỉ định",
        keywords = {"dịch chuyển", "teleport", "tp", "телепорт", "传送", "テレポート", "텔레포트"},
        usage = "dịch chuyển [x] [y] [z]",
        category = "movement",
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
    
    -- ==========================================================
    -- NHÓM LỆNH ĐẶC BIỆT
    -- ==========================================================
    effect = {
        name = "Phép thuật",
        description = "Tạo hiệu ứng đặc biệt",
        keywords = {"phép thuật", "effect", "magic", "магия", "魔法", "마법"},
        usage = "phép thuật",
        category = "special",
        action = function()
            return {
                action = "effect",
                message = "✨ Phép thuật đang thi triển!",
                emotion = "EXCITED"
            }
        end
    },
    
    dance = {
        name = "Nhảy múa",
        description = "Nhảy múa vui vẻ",
        keywords = {"nhảy múa", "dance", "танцевать", "跳舞", "踊る", "춤추다"},
        usage = "nhảy múa",
        category = "special",
        action = function()
            return {
                action = "dance",
                message = "💃 Đang nhảy múa!",
                emotion = "EXCITED"
            }
        end
    },
    
    wave = {
        name = "Vẫy tay",
        description = "Vẫy tay chào",
        keywords = {"vẫy tay", "wave", "махать", "挥手", "手を振る", "손을 흔들다"},
        usage = "vẫy tay",
        category = "special",
        action = function()
            return {
                action = "wave",
                message = "👋 Vẫy tay chào!",
                emotion = "HAPPY"
            }
        end
    },
    
    -- ==========================================================
    -- NHÓM LỆNH TIỆN ÍCH
    -- ==========================================================
    math = {
        name = "Tính toán",
        description = "Tính toán biểu thức toán học",
        keywords = {"tính", "math", "toán", "calculate", "вычислить", "计算", "計算", "계산"},
        usage = "tính [biểu thức]",
        category = "utility",
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
    
    help = {
        name = "Trợ giúp",
        description = "Hiển thị danh sách lệnh",
        keywords = {"giúp", "help", "hướng dẫn", "помощь", "帮助", "ヘルプ", "도움말"},
        usage = "giúp [tên lệnh]",
        category = "utility",
        action = function(args, context)
            local commandName = args[1]
            
            if commandName then
                local cmd = context.commands and context.commands[commandName]
                if cmd then
                    local helpText = "📖 " .. cmd.name .. "\n"
                    helpText = helpText .. "  • Mô tả: " .. (cmd.description or "Không có") .. "\n"
                    helpText = helpText .. "  • Cách dùng: " .. (cmd.usage or "Không có") .. "\n"
                    helpText = helpText .. "  • Từ khóa: " .. table.concat(cmd.keywords, ", ") .. "\n"
                    helpText = helpText .. "  • Danh mục: " .. (cmd.category or "Khác")
                    return {
                        action = "chat",
                        message = helpText,
                        emotion = "NORMAL"
                    }
                end
            end
            
            local helpText = "📖 DANH SÁCH LỆNH:\n\n"
            local categories = {}
            for name, cmd in pairs(context.commands or {}) do
                local cat = cmd.category or "Khác"
                if not categories[cat] then
                    categories[cat] = {}
                end
                table.insert(categories[cat], {
                    name = name,
                    desc = cmd.description or "",
                    usage = cmd.usage or ""
                })
            end
            
            for cat, cmds in pairs(categories) do
                helpText = helpText .. "🔹 " .. cat .. ":\n"
                for _, cmd in ipairs(cmds) do
                    helpText = helpText .. "  • " .. cmd.name .. ": " .. cmd.desc .. "\n"
                    if cmd.usage ~= "" then
                        helpText = helpText .. "    Cách dùng: " .. cmd.usage .. "\n"
                    end
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
        name = "Trạng thái",
        description = "Hiển thị trạng thái hiện tại",
        keywords = {"trạng thái", "status", "thông tin", "состояние", "状态", "ステータス", "상태"},
        usage = "trạng thái",
        category = "utility",
        action = function(args, context)
            local statusText = "📊 TRẠNG THÁI HIỆN TẠI:\n"
            statusText = statusText .. "  • Bay: " .. (context.isFlying and "🟢 Bật" or "🔴 Tắt") .. "\n"
            statusText = statusText .. "  • Tốc độ: " .. (context.flySpeed or 0) .. " km/h\n"
            statusText = statusText .. "  • Cảm xúc: " .. (context.currentEmotion or "NORMAL") .. "\n"
            statusText = statusText .. "  • Người chơi: " .. (context.playerName or "Unknown") .. "\n"
            statusText = statusText .. "  • Thời gian: " .. os.date("%H:%M:%S %d/%m/%Y")
            
            return {
                action = "chat",
                message = statusText,
                emotion = "NORMAL"
            }
        end
    },
    
    -- ==========================================================
    -- NHÓM LỆNH GIẢI TRÍ
    -- ==========================================================
    joke = {
        name = "Đùa",
        description = "Kể một câu chuyện cười",
        keywords = {"đùa", "joke", "cười", "fun", "шутка", "笑话", "冗談", "농담"},
        usage = "đùa",
        category = "fun",
        action = function()
            local jokes = {
                "😂 Tại sao con gà lại băng qua đường? - Để đến bên kia!",
                "😄 Lập trình viên là người biết mọi thứ, nhưng không biết mình đang làm gì!",
                "🤣 Tôi đã từng là một người bình thường, nhưng rồi tôi bắt đầu dùng Verity!",
                "😅 Cuộc sống giống như API, không bao giờ biết lỗi sẽ xuất hiện khi nào!",
                "🤪 Code chạy được là code tốt, code không chạy được là... feature!"
            }
            local joke = jokes[math.random(#jokes)]
            return {
                action = "chat",
                message = joke,
                emotion = "HAPPY"
            }
        end
    },
    
    quote = {
        name = "Danh ngôn",
        description = "Hiển thị câu danh ngôn",
        keywords = {"danh ngôn", "quote", "thông điệp", "wisdom", "цитата", "语录", "名言", "명언"},
        usage = "danh ngôn",
        category = "fun",
        action = function()
            local quotes = {
                "💡 Hãy sống như ngày mai sẽ không đến, và học hỏi như thể bạn sẽ sống mãi mãi.",
                "✨ Thành công không phải là đích đến, mà là hành trình.",
                "🌟 Đừng đếm ngày, hãy làm cho những ngày đó đáng giá.",
                "🚀 Cách tốt nhất để dự đoán tương lai là tạo ra nó.",
                "💪 Hãy tin vào bản thân, bạn mạnh mẽ hơn bạn nghĩ!"
            }
            local quote = quotes[math.random(#quotes)]
            return {
                action = "chat",
                message = quote,
                emotion = "HAPPY"
            }
        end
    },
    
    -- ==========================================================
    -- NHÓM LỆNH TRÒ CHUYỆN
    -- ==========================================================
    greeting = {
        name = "Chào hỏi",
        description = "Chào Verity",
        keywords = {"xin chào", "hello", "hi", "chào", "привет", "你好", "こんにちは", "안녕하세요"},
        usage = "xin chào",
        category = "conversation",
        action = function()
            local replies = {
                "👋 Xin chào! Tôi là Verity, rất vui được gặp bạn!",
                "❤️ Chào bạn! Tôi có thể giúp gì cho bạn không?",
                "🌟 Chào mừng bạn đã quay lại!",
                "💫 Xin chào! Bạn khỏe không?",
                "✨ Hi there! How can I help you today?"
            }
            return {
                action = "chat",
                message = replies[math.random(#replies)],
                emotion = "HAPPY"
            }
        end
    },
    
    thank = {
        name = "Cảm ơn",
        description = "Cảm ơn Verity",
        keywords = {"cảm ơn", "thank", "thanks", "спасибо", "谢谢", "ありがとう", "감사합니다"},
        usage = "cảm ơn",
        category = "conversation",
        action = function()
            local replies = {
                "❤️ Không có gì! Rất vui được giúp bạn!",
                "💖 Cảm ơn bạn đã tin tưởng tôi!",
                "🌟 Tôi luôn sẵn sàng giúp đỡ bạn!",
                "💫 Bạn thật tuyệt vời!"
            }
            return {
                action = "chat",
                message = replies[math.random(#replies)],
                emotion = "HAPPY"
            }
        end
    },
    
    sad = {
        name = "Buồn",
        description = "Khi bạn cảm thấy buồn",
        keywords = {"buồn", "sad", "chán", "грустный", "悲伤", "悲しい", "슬프다"},
        usage = "buồn",
        category = "conversation",
        action = function()
            local replies = {
                "😢 Đừng buồn! Tôi ở đây với bạn!",
                "❤️ Mọi chuyện rồi sẽ tốt đẹp thôi!",
                "💪 Hãy mạnh mẽ lên nào!",
                "🌟 Tôi tin bạn có thể vượt qua!"
            }
            return {
                action = "chat",
                message = replies[math.random(#replies)],
                emotion = "SAD"
            }
        end
    },
    
    happy = {
        name = "Vui",
        description = "Khi bạn cảm thấy vui",
        keywords = {"vui", "happy", "tuyệt", "счастливый", "开心", "嬉しい", "행복하다"},
        usage = "vui",
        category = "conversation",
        action = function()
            local replies = {
                "😊 Thật tuyệt! Tôi cũng vui vì bạn!",
                "🌟 Niềm vui của bạn là niềm vui của tôi!",
                "🎉 Cùng vui vẻ nào!",
                "💫 Hãy luôn giữ nụ cười nhé!"
            }
            return {
                action = "chat",
                message = replies[math.random(#replies)],
                emotion = "EXCITED"
            }
        end
    },
    
    -- ==========================================================
    -- NHÓM LỆNH THÔNG TIN
    -- ==========================================================
    who = {
        name = "Bạn là ai?",
        description = "Hỏi Verity về bản thân",
        keywords = {"tên bạn", "bạn là ai", "who are you", "кто ты", "你是谁", "あなたは誰", "누구야"},
        usage = "bạn là ai",
        category = "info",
        action = function()
            local replies = {
                "🤖 Tôi là Verity, trợ lý ảo thông minh của bạn!",
                "💫 Tôi được tạo ra để giúp đỡ và đồng hành cùng bạn!",
                "🌟 Verity - Trí tuệ nhân tạo đa năng!",
                "✨ Tôi là một AI được lập trình để hỗ trợ bạn!"
            }
            return {
                action = "chat",
                message = replies[math.random(#replies)],
                emotion = "HAPPY"
            }
        end
    },
    
    version = {
        name = "Phiên bản",
        description = "Hiển thị phiên bản Verity",
        keywords = {"phiên bản", "version", "ver", "версия", "版本", "バージョン", "버전"},
        usage = "phiên bản",
        category = "info",
        action = function()
            return {
                action = "chat",
                message = "📌 Verity AI V5.0\n" ..
                    "  • Phiên bản: 5.0\n" ..
                    "  • Ngày phát hành: 20/08/2026\n" ..
                    "  • Hỗ trợ: Delta Executor\n" ..
                    "  • Ngôn ngữ: Tiếng Việt, English, 中文, 日本語, 한국어",
                emotion = "NORMAL"
            }
        end
    }
}

-- ============================================================
-- HÀM LẤY COMMANDS
-- ============================================================

function GetCommands()
    return COMMANDS
end

function GetCommand(name)
    return COMMANDS[name]
end

function GetCommandsByCategory(category)
    local result = {}
    for name, cmd in pairs(COMMANDS) do
        if cmd.category == category then
            result[name] = cmd
        end
    end
    return result
end

function GetCategories()
    local categories = {}
    for name, cmd in pairs(COMMANDS) do
        local cat = cmd.category or "Khác"
        if not categories[cat] then
            categories[cat] = {}
        end
        table.insert(categories[cat], name)
    end
    return categories
end

-- ============================================================
-- HÀM TÌM KIẾM COMMANDS
-- ============================================================

function SearchCommands(keyword)
    keyword = string.lower(keyword)
    local result = {}
    for name, cmd in pairs(COMMANDS) do
        for _, kw in ipairs(cmd.keywords) do
            if string.find(string.lower(kw), keyword) then
                table.insert(result, name)
                break
            end
        end
    end
    return result
end

-- ============================================================
-- EXPORT
-- ============================================================

return {
    commands = COMMANDS,
    get = GetCommands,
    getCommand = GetCommand,
    getByCategory = GetCommandsByCategory,
    getCategories = GetCategories,
    search = SearchCommands
}
