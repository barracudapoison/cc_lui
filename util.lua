local width, height = term.getSize()

local function drawBox(col,x1,y1,x2,y2)
	local width = x2-x1
	local height = y2-y1
	local s = string.rep(" ", width+1)
	local c = colors.toBlit(col)
	local t = colors.toBlit(colors.white)

	local r = string.rep(c, width+1)

	term.setCursorPos(x1,y1)
	term.blit(s,r,r)
	
	term.setCursorPos(x1,y2)
	term.blit(s,r,r)

	for i=y1+1, y2-1 do
		term.setCursorPos(x1, i) 
		term.blit(" ", t,c)

		term.setCursorPos(x2, i) 
		term.blit(" ", t,c)
	end
end

local function drawFilledBox(col,x1,y1,x2,y2)
	local width = x2-x1
	local height = y2-y1
	local s = string.rep(" ", width+1)
	local c = colors.toBlit(col)

	local r = string.rep(c, width+1)

	for i=y1, y2 do
		term.setCursorPos(x1, i) 
		term.blit(s, r,r)
	end
end

-- string, p1 and p2 defines bounds to be centered in,
-- ox and oy are offsets for after the center is calculated      
local function getCenteredTextCoords(s, x1, y1, x2, y2, ox, oy)
	local width = x2-x1
	local height = y2-y1
	local cw = math.floor((width-#s)/2) + x1
	local ch = math.floor(height/2) + y1
	return cw + ox, ch + oy 
end


local Position = {
	Default = 1,
	Anchor = 2,
	InsetAnchor = 3,
	InheritCenter = 4,
}

local Side = {
	Top = 1,
	Right = 2,
	Bottom = 3,
	Left = 4,

	TopRight = 5,
	BottomRight = 6,
	BottomLeft = 7,
	TopLeft = 8
}

local AdvancedPosition = {
	subject = nil,
	type = Position.Default,
	ox = 0,
	oy = 0,
	target = nil,
	side = Side.Top,
	target2 = nil
}
AdvancedPosition.__index = AdvancedPosition

function AdvancedPosition:new(type, target, side, ox, oy, target2, side2)
	local obj = setmetatable({}, self)
	obj.type = type
	obj.target = target 
	obj.side = side 
	obj.side2 = side2
	obj.ox = ox 
	obj.oy = oy 
	obj.target2 = target2
	return obj
end

function AdvancedPosition:calculatePosition(subject)
	if self.type == Position.Default then 
		return subject.style.x, subject.style.y 
	elseif self.type == Position.Anchor then 
		if not obj.side2 then 
			-- center the subject to the main anchor side

		else 
			-- 

		end
	end
end

local Style = {
	x = 0,
	y = 0,
	width = 0,
	height = 0,
	color = colors.white,
	text_color = colors.black,
	is_box = false,
	fill = false
}
Style.__index = Style 

function Style:new()
	local obj = setmetatable({}, self)
	return obj 
end

local Element = {
	static = true,
	click_bounds = {},
	drag_bounds = {},
	text = nil,
	style = {}
}
Element.__index = Element 

function Element:new() 
	local obj = setmetatable({}, self)
	obj.style = Style:new()
	return obj
end

function Element:draw()
	if not self.style.is_box then 
		-- draw text too i guess but whatever
		return 
	else 
		if self.style.fill then 
			drawFilledBox(self.style.color, self.style.x, self.style.y, self.style.x + self.style.width-1, self.style.y + self.style.height-1)
		else 
			drawBox(self.style.color, self.style.x, self.style.y, self.style.x + self.style.width-1, self.style.y + self.style.height-1)
		end 
	end 
end

function Element:calculateAnchors()
	local anchors = {}
	local wo2 = math.floor(self.style.width/2)
	local ho2 = math.floor(self.style.height/2)

	anchors.topc = {self.style.x + wo2, self.style.y-1}
	anchors.bottomc = {self.style.x + wo2, self.style.y + self.style.height}
	
	anchors.leftc = {self.style.x-1, self.style.y + ho2}
	anchors.rightc = {self.style.x + self.style.width, self.style.y + ho2}

	anchors.topr = {self.style.x + self.style.width - 1, self.style.y-1}
	anchors.topl = {self.style.x, self.style.y-1}

	anchors.bottomr = {self.style.x + self.style.width - 1, self.style.y + self.style.height}
	anchors.bottoml = {self.style.x, self.style.y + self.style.height}

	anchors.rightt = {self.style.x + width+1, self.style.y}

	return anchors
end

function Element:drawAnchors()
	local wo2 = math.floor(self.style.width/2)
	local ho2 = math.floor(self.style.height/2)

	local a = self:calculateAnchors()
	for k, v in pairs(a) do 
		term.setCursorPos(v[1], v[2])
		term.blit(" ", "e","e")
	end


end

term.clear()
term.setCursorPos(getCenteredTextCoords("hello world", 1, 1, width, height, 0, 0))
term.write("hello world")

local s1 = Element:new()
s1.style.width = 7
s1.style.height = 7
s1.style.x = 3
s1.style.y = 3
s1.style.is_box = true 



local s2 = Element:new()
s2.style.width = 3
s2.style.height = 3
s2.style.x = 10
s2.style.y = 10
s2.style.color = colors.red
s2.style.is_box = true 	

s1:draw()
s2:draw()
s1:drawAnchors()