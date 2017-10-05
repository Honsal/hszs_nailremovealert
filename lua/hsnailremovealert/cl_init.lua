include("shared.lua")

local COL_WHITE = Color(255, 255, 255)
local COL_SKYBLUE = Color(0, 200, 200)
local COL_RED = Color(200, 0, 0)
local COL_GREEN = Color(0, 200, 0)
local COL_BLUE = Color(0, 0, 200)
local COL_YELLOW = Color(200, 200, 0)

local checkMessage = function(message, compare)

	if isstring(compare) then
		compare = HSNR.MESSAGE[string.upper(string.Replace(compare, " ", "_"))]
	end
	return bit.band(message, compare) == compare
end

HSNR.ReceiveMessage = function(len)
	local message = net.ReadInt(16)
	if checkMessage(message, "no queue") then
		chat.AddText(COL_GREEN, "아직 아무도 내 바리케이드의 못을 빼지 않았다.")
	end
	
	if checkMessage(message, "nail removed") then
		local remover = net.ReadEntity()
		chat.AddText(COL_RED, remover:Nick() .. "님이 못을 뺐다.")
	end
	
	if checkMessage(message, "showlist") then
		local lst = net.ReadTable()
		HSNR.ShowList(lst)
	end
	
	if checkMessage(message, "wrong argument") then
		chat.AddText(COL_YELLOW, "인수를 잘못 입력하셨습니다. 사용법을 참조해주세요.")
	end
	
	if checkMessage(message, "target disconnect") then
		local sid = net.ReadString()
		local nick = net.ReadString()
		chat.AddText(COL_RED, nick, COL_WHITE, " 님은 이미 접속을 종료하셨습니다.")
		chat.AddText(COL_WHITE, "그래도 처벌을 원하신다면 어드민에게 ", COL_YELLOW, sid, COL_WHITE, "를 제출하세요.")
	end
	
	if checkMessage(message, "penalty point") then
		local time = net.ReadFloat()
		local point = net.ReadString()
		
		if point == "10" then
			chat.AddText(COL_GREEN, os.date("%H:%M:%S", time), COL_WHITE, "에 타인의 못을 제거한 첫 번째 패널티로 ", COL_RED, point, " 포인트", COLOR_WHITE, " 감소 처리되었습니다.")
		elseif point == "30" then
			chat.AddText(COL_GREEN, os.date("%H:%M:%S", time), COL_WHITE, "에 타인의 못을 제거한 두 번째 패널티로 ", COL_RED, point, " 포인트", COLOR_WHITE, " 감소 처리되었습니다.")
		end
	end
	
	if checkMessage(message, "penalty brain") then
		local time = net.ReadFloat()
		local brain = net.ReadString()
		if brain == "1" then
			chat.AddText(COL_GREEN, os.date("%H:%M:%S", time), COL_WHITE, "에 타인의 못을 제거한 첫 번째 패널티로 ", COL_RED, "뇌 ", brain, "개", COLOR_WHITE, " 감소 처리되었습니다.")
		elseif brain == "3" then
			chat.AddText(COL_GREEN, os.date("%H:%M:%S", time), COL_WHITE, "에 타인의 못을 제거한 두 번째 패널티로 ", COL_RED, "뇌 ", brain, "개", COLOR_WHITE, " 감소 처리되었습니다.")
		end
	end
	
	if checkMessage(message, "penalty damage") then
		local time = net.ReadFloat()
		chat.AddText(COL_GREEN, os.date("%H:%M:%S", time), COL_WHITE, "에 타인의 못을 제거한 세 번째 패널티로 ", COL_RED, "사망", COLOR_WHITE, " 처리되었습니다.")
	end
	
	if checkMessage(message, "penalty kick") then
		local time = net.ReadFloat()
		chat.AddText(COL_GREEN, os.date("%H:%M:%S", time), COL_WHITE, "에 타인의 못을 제거한 마지막 패널티로 ", COL_RED, "킥", COLOR_WHITE, " 처리되었습니다.")
	end
	
	if checkMessage(message, "process penalty point") then
		local nick = net.ReadString()
		local point = net.ReadString()
		
		if point == "10" then
			chat.AddText(COL_RED, nick, COL_WHITE, "님께서 첫 번째 패널티로 ", COL_RED, "포인트 ", point, " 감소", COL_WHITE, " 처리되었습니다.")
		elseif point == "30" then
			chat.AddText(COL_RED, nick, COL_WHITE, "님께서 두 번째 패널티로 ", COL_RED, "포인트 ", point, " 감소", COL_WHITE, " 처리되었습니다.")
		end
	end
	
	if checkMessage(message, "process penalty brain") then
		local nick = net.ReadString()
		local brain = net.ReadString()
		
		if brain == "1" then
			chat.AddText(COL_RED, nick, COL_WHITE, "님께서 첫 번째 패널티로", COL_RED, "뇌 ", brain, "개 감소", COL_WHITE, " 처리되었습니다.")
		elseif brain == "3" then
			chat.AddText(COL_RED, nick, COL_WHITE, "님께서 두 번째 패널티로", COL_RED, "뇌 ", brain, "개 감소", COL_WHITE, " 처리되었습니다.")
		end
	end
	
	if checkMessage(message, "process penalty damage") then
		local nick = net.ReadString()
		local brain = net.ReadString()
		chat.AddText(COL_RED, nick, COL_WHITE, "님께서 세 번째 패널티로", COL_RED, "사망", COL_WHITE, " 처리되었습니다.")
	end
	
	if checkMessage(message, "process penalty kick") then
		local nick = net.ReadString()
		local brain = net.ReadString()
		chat.AddText(COL_RED, nick, COL_WHITE, "님께서 마지막 패널티로", COL_RED, "킥", COL_WHITE, " 처리되었습니다.")
	end
end
net.Receive("hsnr.message", HSNR.ReceiveMessage)

HSNR.ShowList = function(lst)
	if !istable(lst) or #lst == 0 then
		chat.AddText(COL_RED, "서버로부터 정보를 가져오는 중 에러가 발생하였습니다.")
		return
	end
	
	for i, data in pairs(lst) do
		chat.AddText(COL_YELLOW, "[", tostring(i), "] ", COL_SKYBLUE, os.date("%H:%M:%S", data.time), COL_WHITE, ": " , COL_RED, data.nick, COL_WHITE, "님께서 못을 뺐습니다.")
	end
end
net.Receive("hsnr.showlist", HSNR.ShowList)