require("lui/style")
require("lui/util")

local Style = Style
local Util = Util

Graphics = {}

function Graphics:drawFilledBox(x1, y1, x2, y2, color1, color2, char)
	x1, y1, x2, y2 = math.floor(x1), math.floor(y1), math.floor(x2), math.floor(y2)
	x1, x2 = Util.sortMinMax(x1, x2)
	y1, y2 = Util.sortMinMax(y1, y2)
	local w  = x2 - x1
	if w <= 0 then return end
	local s  = string.rep(char or " ", w)
	local bg = string.rep(color1, w)
	local fg = color2 and string.rep(color2, w) or bg
	for i = 0, y2 - y1 - 1 do
		term.setCursorPos(x1, y1 + i)
		term.blit(s, fg, bg)
	end
end

function Graphics:drawItem(item)
	if item.visible == false then 
		return 
	end
	local x, y = item:getCoords()
	if item.color then 
		self:drawFilledBox(
			x, y,
			x + item:getWidth(), y + item:getHeight(),
			item.color,
			item.fillDecorationColor or item.color,
			item.fillDecoration or " "
		)	
	end
	if item.text ~= "" and item.text ~= nil then 
		if item.textColor then 
			term.setTextColor(Style.CCColor[item.textColor])
		end
		term.setBackgroundColor(Style.CCColor[item.color])
		term.setCursorPos(x, y)
		term.write(item.text)
	end
end

function Graphics:render(group)
	self:drawItem(group)
	for _, v in pairs(group.children) do
		self:render(v)
	end
end