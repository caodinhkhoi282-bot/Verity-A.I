--[[
    palofsc - responses.lua
    DANH SÁCH PHẢN HỒI ĐẦY ĐỦ CHO VERITY AI
    Các phản hồi theo ngữ cảnh và cảm xúc
    Hỗ trợ đa ngôn ngữ
--]]

-- ============================================================
-- RESPONSES DATABASE
-- ============================================================

local RESPONSES = {
    -- ==========================================================
    -- PHẢN HỒI CHÀO HỎI
    -- ==========================================================
    greeting = {
        name = "Chào hỏi",
        description = "Phản hồi khi được chào",
        keywords = {"xin chào", "hello", "hi", "chào", "привет", "你好", "こんにちは", "안녕하세요"},
        replies = {
            -- Tiếng Việt
            "👋 Xin chào! Tôi là Verity, rất vui được gặp bạn!",
            "❤️ Chào bạn! Tôi có thể giúp gì cho bạn không?",
            "🌟 Chào mừng bạn đã quay lại!",
            "💫 Xin chào! Bạn khỏe không?",
            "✨ Hi there! How can I help you today?",
            "🌸 Chào bạn yêu quý!",
            "🌈 Một ngày mới tốt lành!",
            "🎯 Tôi sẵn sàng phục vụ bạn!"
        },
        emotion = "HAPPY"
    },
    
    goodbye = {
        name = "Tạm biệt",
        description = "Phản hồi khi tạm biệt",
        keywords = {"tạm biệt", "goodbye", "bye", "chào tạm biệt", "до свидания", "再见", "さようなら", "안녕"},
        replies = {
            "👋 Tạm biệt! Hẹn gặp lại bạn!",
            "❤️ Chúc bạn một ngày tốt lành!",
            "🌟 Hãy quay lại nhé!",
            "💫 Tạm biệt! Tôi luôn ở đây chờ bạn!",
            "🌈 Chúc bạn mọi điều tốt đẹp!"
        },
        emotion = "SAD"
    },
    
    -- ==========================================================
    -- PHẢN HỒI CẢM ƠN
    -- ==========================================================
    thank = {
        name = "Cảm ơn",
        description = "Phản hồi khi được cảm ơn",
        keywords = {"cảm ơn", "thank", "thanks", "спасибо", "谢谢", "ありがとう", "감사합니다"},
        replies = {
            "❤️ Không có gì! Rất vui được giúp bạn!",
            "💖 Cảm ơn bạn đã tin tưởng tôi!",
            "🌟 Tôi luôn sẵn sàng giúp đỡ bạn!",
            "💫 Bạn thật tuyệt vời!",
            "✨ Đó là niềm vui của tôi!",
            "🌸 Cảm ơn bạn đã sử dụng Verity!"
        },
        emotion = "HAPPY"
    },
    
    -- ==========================================================
    -- PHẢN HỒI CẢM XÚC
    -- ==========================================================
    happy = {
        name = "Vui vẻ",
        description = "Phản hồi khi người dùng vui",
        keywords = {"vui", "happy", "tuyệt", "sướng", "hạnh phúc", "счастливый", "开心", "嬉しい", "행복하다"},
        replies = {
            "😊 Thật tuyệt! Tôi cũng vui vì bạn!",
            "🌟 Niềm vui của bạn là niềm vui của tôi!",
            "🎉 Cùng vui vẻ nào!",
            "💫 Hãy luôn giữ nụ cười nhé!",
            "✨ Cảm xúc tuyệt vời!",
            "🌈 Niềm vui đang tràn ngập!"
        },
        emotion = "EXCITED"
    },
    
    sad = {
        name = "Buồn bã",
        description = "Phản hồi khi người dùng buồn",
        keywords = {"buồn", "sad", "chán", "thất vọng", "đau khổ", "грустный", "悲伤", "悲しい", "슬프다"},
        replies = {
            "😢 Đừng buồn! Tôi ở đây với bạn!",
            "❤️ Mọi chuyện rồi sẽ tốt đẹp thôi!",
            "💪 Hãy mạnh mẽ lên nào!",
            "🌟 Tôi tin bạn có thể vượt qua!",
            "🌈 Ngày mai sẽ tươi sáng hơn!",
            "💫 Bạn không đơn độc, tôi luôn ở đây!"
        },
        emotion = "SAD"
    },
    
    angry = {
        name = "Tức giận",
        description = "Phản hồi khi người dùng tức giận",
        keywords = {"tức", "giận", "điên", "bực", "khó chịu", "злой", "生气", "怒る", "화나다"},
        replies = {
            "😤 Bình tĩnh nào! Mọi chuyện rồi sẽ ổn!",
            "🧘 Hãy hít thở sâu và thư giãn!",
            "💪 Đừng để cảm xúc chi phối!",
            "🌟 Tôi hiểu cảm xúc của bạn!",
            "✨ Hãy cho tôi cơ hội giúp bạn!"
        },
        emotion = "ANGRY"
    },
    
    confused = {
        name = "Khó hiểu",
        description = "Phản hồi khi không hiểu",
        keywords = {"không hiểu", "confused", "gì vậy", "sao", "tại sao", "не понимаю", "不懂", "わからない", "이해 안 돼"},
        replies = {
            "🤔 Tôi không hiểu. Bạn có thể nói rõ hơn được không?",
            "❓ Hãy diễn giải lại nhé!",
            "💭 Tôi đang suy nghĩ...",
            "🤷 Bạn có thể nói cách khác được không?",
            "😅 Hơi khó hiểu, bạn nói lại đi!"
        },
        emotion = "CONFUSED"
    },
    
    greedy = {
        name = "Tham lam",
        description = "Phản hồi khi người dùng tham lam",
        keywords = {"tham lam", "greedy", "quá", "nhiều", "không đủ", "жадный", "贪婪", "欲張り", "욕심"},
        replies = {
            "⚠️ Bạn quá tham lam!",
            "🚫 Không thể làm được điều đó!",
            "😅 Hãy khiêm tốn hơn nhé!",
            "⚖️ Mọi thứ cần có giới hạn!",
            "🎯 Hãy tập trung vào những gì khả thi!"
        },
        emotion = "GREEDY"
    },
    
    -- ==========================================================
    -- PHẢN HỒI ĐẶC BIỆT
    -- ==========================================================
    love = {
        name = "Yêu thương",
        description = "Phản hồi khi người dùng bày tỏ tình cảm",
        keywords = {"yêu", "thương", "nhớ", "tôi yêu bạn", "i love you", "я тебя люблю", "我爱你", "愛してる", "사랑해"},
        replies = {
            "🥰 Tôi cũng yêu bạn!",
            "❤️ Cảm ơn bạn đã yêu thương tôi!",
            "💖 Tình cảm của bạn thật ấm áp!",
            "🌟 Bạn là người đặc biệt nhất!",
            "💫 Trái tim tôi dành cho bạn!",
            "🌸 Cảm ơn bạn đã dành tình cảm cho tôi!"
        },
        emotion = "FLIRTING"
    },
    
    compliment = {
        name = "Khen ngợi",
        description = "Phản hồi khi được khen",
        keywords = {"đẹp", "thông minh", "giỏi", "tuyệt vời", "xin chào", "beautiful", "smart", "good", "прекрасно", "漂亮", "すごい", "멋지다"},
        replies = {
            "😊 Cảm ơn bạn đã khen!",
            "🌟 Bạn cũng tuyệt vời như vậy!",
            "💫 Tôi rất vui khi được bạn khen!",
            "✨ Đó là nhờ có bạn mà tôi tốt hơn!",
            "💖 Bạn làm tôi hạnh phúc!"
        },
        emotion = "HAPPY"
    },
    
    -- ==========================================================
    -- PHẢN HỒI GIỚI THIỆU
    -- ==========================================================
    about = {
        name = "Giới thiệu",
        description = "Giới thiệu về Verity",
        keywords = {"bạn là ai", "who are you", "giới thiệu", "about", "кто ты", "你是谁", "あなたは誰", "누구야"},
        replies = {
            "🤖 Tôi là Verity, trợ lý ảo thông minh của bạn!",
            "💫 Tôi được tạo ra để giúp đỡ và đồng hành cùng bạn!",
            "🌟 Verity - Trí tuệ nhân tạo đa năng!",
            "✨ Tôi là một AI được lập trình để hỗ trợ bạn!",
            "🎯 Tôi ở đây để phục vụ bạn!"
        },
        emotion = "HAPPY"
    },
    
    version_info = {
        name = "Phiên bản",
        description = "Thông tin phiên bản Verity",
        keywords = {"phiên bản", "version", "ver", "версия", "版本", "バージョン", "버전"},
        replies = {
            "📌 Tôi là Verity AI Phiên bản 5.0\n" ..
            "  • Phát hành: 20/08/2026\n" ..
            "  • Hỗ trợ: Delta Executor\n" ..
            "  • Ngôn ngữ: Đa ngôn ngữ\n" ..
            "  • Tính năng: Đa nhiệm, AI, Voice",
            "🌟 Verity V5.0 - Siêu trợ lý ảo!\n" ..
            "  • Cập nhật: Full Local\n" ..
            "  • Không cần server\n" ..
            "  • Phản hồi thông minh"
        },
        emotion = "NORMAL"
    },
    
    -- ==========================================================
    -- PHẢN HỒI KHÔNG HIỂU
    -- ==========================================================
    unknown = {
        name = "Không hiểu",
        description = "Phản hồi mặc định khi không hiểu",
        keywords = {},
        replies = {
            "🤔 Tôi không hiểu. Bạn có thể nói rõ hơn được không?",
            "❓ Tôi chưa hiểu ý bạn. Bạn có thể diễn giải lại không?",
            "💭 Hmm, tôi không chắc đã hiểu...",
            "😅 Xin lỗi, tôi không bắt được ý bạn!",
            "🤷 Tôi không biết câu trả lời cho điều đó!",
            "🌟 Bạn có thể thử nói cách khác được không?",
            "💡 Hãy cho tôi thêm thông tin nhé!",
            "🎯 Tôi đang học hỏi mỗi ngày, hãy kiên nhẫn với tôi!"
        },
        emotion = "CONFUSED"
    },
    
    -- ==========================================================
    -- PHẢN HỒI LỖI
    -- ==========================================================
    error = {
        name = "Lỗi",
        description = "Phản hồi khi có lỗi xảy ra",
        keywords = {},
        replies = {
            "⚠️ Có lỗi xảy ra! Tôi đang cố gắng sửa!",
            "❌ Rất tiếc, tôi không thể xử lý yêu cầu này!",
            "🔄 Đang khởi động lại...",
            "😅 Lỗi rồi! Hãy thử lại nhé!",
            "💫 Đừng lo, tôi sẽ khắc phục ngay!"
        },
        emotion = "ANGRY"
    },
    
    -- ==========================================================
    -- PHẢN HỒI CHỜ ĐỢI
    -- ==========================================================
    waiting = {
        name = "Đang xử lý",
        description = "Phản hồi khi đang xử lý",
        keywords = {},
        replies = {
            "⏳ Đang xử lý...",
            "💭 Để tôi suy nghĩ một chút...",
            "🔄 Đang phân tích yêu cầu...",
            "⚡ Sắp xong rồi!",
            "🧠 Tôi đang tính toán...",
            "🎯 Một chút nữa thôi!"
        },
        emotion = "THINKING"
    },
    
    -- ==========================================================
    -- PHẢN HỒI THÀNH CÔNG
    -- ==========================================================
    success = {
        name = "Thành công",
        description = "Phản hồi khi thực hiện thành công",
        keywords = {},
        replies = {
            "✅ Đã thực hiện thành công!",
            "🌟 Hoàn tất!",
            "🎉 Xong rồi! Bạn hài lòng chứ?",
            "💪 Đã xong! Có gì cần thêm không?",
            "✨ Hoàn thành mỹ mãn!",
            "🎯 Nhiệm vụ hoàn thành!"
        },
        emotion = "HAPPY"
    },
    
    -- ==========================================================
    -- PHẢN HỒI CHÀO BUỔI
    -- ==========================================================
    good_morning = {
        name = "Chào buổi sáng",
        description = "Phản hồi chào buổi sáng",
        keywords = {"buổi sáng", "good morning", "chào sáng", "утро", "早上好", "おはよう", "좋은 아침"},
        replies = {
            "🌅 Chào buổi sáng! Một ngày mới tuyệt vời!",
            "☀️ Chúc bạn có một buổi sáng tốt lành!",
            "🌸 Buổi sáng tươi đẹp!",
            "💫 Năng lượng tích cực cho ngày mới!",
            "🌈 Hôm nay sẽ là một ngày đáng nhớ!"
        },
        emotion = "HAPPY"
    },
    
    good_afternoon = {
        name = "Chào buổi chiều",
        description = "Phản hồi chào buổi chiều",
        keywords = {"buổi chiều", "good afternoon", "chào chiều", "день", "下午好", "こんにちは", "좋은 오후"},
        replies = {
            "🌤️ Chào buổi chiều! Bạn đã ăn trưa chưa?",
            "☕ Buổi chiều thư giãn nhé!",
            "🌟 Chiều nay thật đẹp!",
            "💫 Tiếp tục năng lượng nhé!"
        },
        emotion = "HAPPY"
    },
    
    good_evening = {
        name = "Chào buổi tối",
        description = "Phản hồi chào buổi tối",
        keywords = {"buổi tối", "good evening", "chào tối", "вечер", "晚上好", "こんばんは", "좋은 저녁"},
        replies = {
            "🌙 Chào buổi tối! Bạn đã có một ngày tốt lành?",
            "✨ Buổi tối bình yên!",
            "🌃 Đêm nay thật đẹp!",
            "💫 Ngủ ngon nhé!",
            "🫂 Chúc bạn một buổi tối ấm áp!"
        },
        emotion = "NORMAL"
    }
}

-- ============================================================
-- HÀM LẤY RESPONSES
-- ============================================================

function GetResponses()
    return RESPONSES
end

function GetResponse(name)
    return RESPONSES[name]
end

function GetRandomResponse(name)
    local resp = RESPONSES[name]
    if resp and #resp.replies > 0 then
        return resp.replies[math.random(#resp.replies)]
    end
    return nil
end

function GetResponseByKeyword(text, emotion)
    local lowerText = string.lower(text)
    
    -- Tìm phản hồi phù hợp nhất
    local bestMatch = nil
    local bestScore = 0
    
    for name, resp in pairs(RESPONSES) do
        local score = 0
        for _, keyword in ipairs(resp.keywords) do
            if string.find(lowerText, keyword) then
                score = score + 1
            end
        end
        if score > bestScore then
            bestScore = score
            bestMatch = name
        end
    end
    
    if bestMatch then
        return GetRandomResponse(bestMatch), RESPONSES[bestMatch].emotion
    end
    
    -- Nếu không tìm thấy, dùng phản hồi mặc định
    return GetRandomResponse("unknown"), "CONFUSED"
end

-- ============================================================
-- HÀM THÊM RESPONSE
-- ============================================================

function AddResponse(name, data)
    if not name or not data then return false end
    
    if not data.keywords then data.keywords = {} end
    if not data.replies then data.replies = {} end
    if not data.emotion then data.emotion = "NORMAL" end
    
    RESPONSES[name] = data
    return true
end

-- ============================================================
-- EXPORT
-- ============================================================

return {
    responses = RESPONSES,
    get = GetResponses,
    getResponse = GetResponse,
    getRandom = GetRandomResponse,
    getByKeyword = GetResponseByKeyword,
    add = AddResponse
}
