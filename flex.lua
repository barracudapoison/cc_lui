term.clear()
term.setCursorPos(1,1)

local id = 0
local function assignID()
	id = id + 1
	return id
end

LUI = {}
LUI.__index = LUI

LUI.LColor = {
	White     = "0", Orange  = "1", Magenta   = "2", LightBlue = "3",
	Yellow    = "4", Lime    = "5", Pink      = "6", Gray      = "7",
	LightGray = "8", Cyan    = "9", Purple    = "a", Blue      = "b",
	Brown     = "c", Green   = "d", Red       = "e", Black     = "f",
}

LUI.CCColor = {
	["0"] = colors.white,
	["1"] = colors.orange,
	["2"] = colors.magenta,
	["3"] = colors.lightBlue,
	["4"] = colors.yellow,
	["5"] = colors.lime,
	["6"] = colors.pink,
	["7"] = colors.gray,
	["8"] = colors.lightGray,
	["9"] = colors.cyan,
	["a"] = colors.purple,
	["b"] = colors.blue,
	["c"] = colors.brown,
	["d"] = colors.green,
	["e"] = colors.red,
	["f"] = colors.black
}

LUI.Flex = {
	None   = 0,
	Array  = 1,
	Spaced = 2,
	Fill   = 1024,
}

LUI.FlexOrientation = {
	Left   = 1,
	Middle = 2,
	Right  = 3,
	Top    = 4,
	Bottom = 5,
}

LUI.FlexDirection = {
	Column = 1,
	Row    = 2,
}

-- ─── Item ────────────────────────────────────────────────────────────────────

LUI.Item = {}
LUI.Item.__index = LUI.Item

function LUI.Item.new(args)
	local o = setmetatable({}, {__index = LUI.Item})
	o.id        = assignID()
	o.width     = args.width     or 0
	o.height    = args.height    or 0
	o.padding   = args.padding   or 0
	o.color     = args.color	 or -1
	o.flex_x    = args.flex_x    or 0
	o.flex_y    = args.flex_y    or 0
	o.ox        = args.ox        or 0
	o.oy        = args.oy        or 0
	o.x         = args.x         or 0
	o.y         = args.y         or 0
	o.text 		= args.text      or ""	
	o.flex          = args.flex
	o.flexDirection = args.flexDirection
	o.orientation   = args.orientation
	o.spacing       = args.spacing or 0
	o.fillDecoration      = args.fillDecoration
	o.fillDecorationColor = args.fillDecorationColor
	o.children = {}
	return o
end

function LUI.Item:setPosition(x, y)
	self.x = x
	self.y = y
end

function LUI.Item:setOffset(ox, oy)
	self.ox = ox
	self.oy = oy
end

function LUI.Item:setSize(w, h)
	self.width  = w
	self.height = h
end

function LUI.Item:addChild(item)
	table.insert(self.children, item)
	item.parent = self
end

function LUI.Item:getFlexOffset()
	return self.flex_x, self.flex_y
end

function LUI.Item:translate(x, y)
	self.x = self.x + x
	self.y = self.y + y
end

function LUI.Item:getCoords()
	local px, py = 0, 0
	if self.parent then
		px, py = self.parent:getCoords()
	end
	return self.x + self.ox + self.flex_x + px,
	       self.y + self.oy + self.flex_y + py
end

-- ─── LUI methods ─────────────────────────────────────────────────────────────

function LUI:new()
	return setmetatable({}, LUI)
end

function LUI:merge(t1, t2)
	for k, v in pairs(t2) do t1[k] = v end
	return t1
end

function LUI:measure(c)
	local g = {}
	local p = 0
	while p < 2 do
		local _, btn, mx, my = os.pullEvent("mouse_click")
		if btn == 1 then
			term.setCursorPos(mx, my)
			term.blit(tostring(p), "f", tostring(c))
			table.insert(g, {mx, my})
			p = p + 1
		end
	end
	return "{" .. (g[2][1] - g[1][1] + 1) .. "," .. (g[2][2] - g[1][2] + 1) .. "}"
end

function LUI:getSumHeight(items)
	local a = 0
	for _, item in pairs(items) do
		a = a + item.height + item.padding * 2
	end
	return a
end

function LUI:getSumWidth(items)
	local a = 0
	for _, item in pairs(items) do
		a = a + item.width + item.padding * 2
	end
	return a
end

function LUI:getGaps(items, dsize)
	local gaps     = {}
	local amt_gaps = #items - 1
	if amt_gaps <= 0 then return gaps end
	local gap_size   = math.floor(dsize / amt_gaps)
	local amt_lgaps  = dsize % amt_gaps
	local lgaps_left = amt_lgaps
	for i = 1, amt_gaps do
		local z = gap_size
		if lgaps_left > 0 then
			z = z + 1
			lgaps_left = lgaps_left - 1
		end
		table.insert(gaps, z)
	end
	return gaps
end

-- Row = items stacked vertically  → coords along Y axis, size = height
function LUI:calculateRowSpacedCoords(items, gaps)
	local cx = 0
	local draw_coords = {cx}
	for i = 1, #items - 1 do
		cx = cx + items[i].height + items[i].padding + items[i+1].padding + gaps[i]
		table.insert(draw_coords, cx)
	end
	return draw_coords
end

-- Column = items laid out horizontally → coords along X axis, size = width
function LUI:calculateColumnSpacedCoords(items, gaps)
	local cx = 0
	local draw_coords = {cx}
	for i = 1, #items - 1 do
		cx = cx + items[i].width + items[i].padding + items[i+1].padding + gaps[i]
		table.insert(draw_coords, cx)
	end
	return draw_coords
end

function LUI:setItemFlexCoordinatesY(items, coords)
	for i = 1, #coords do items[i].flex_y = coords[i] end
end

function LUI:setItemFlexCoordinatesX(items, coords)
	for i = 1, #coords do items[i].flex_x = coords[i] end
end

function LUI:solveFlexSpaced(group)
	if group.flex == nil       then return end
	if #group.children == 0    then return end
	if group.flexDirection == nil then
		group.flexDirection = self.FlexDirection.Column
	end

	local sum_item_size, dsize

	-- Row: children stack vertically, so measure height
	-- Column: children sit side-by-side, so measure width
	if group.flexDirection == self.FlexDirection.Row then
		sum_item_size = self:getSumHeight(group.children)
		dsize         = group.height - sum_item_size
	elseif group.flexDirection == self.FlexDirection.Column then
		sum_item_size = self:getSumWidth(group.children)
		dsize         = group.width - sum_item_size
	else
		error("Invalid FlexDirection")
	end

	local gaps = self:getGaps(group.children, dsize)

	if group.flexDirection == self.FlexDirection.Row then
		local draw_coords = self:calculateRowSpacedCoords(group.children, gaps)
		self:setItemFlexCoordinatesY(group.children, draw_coords)
	elseif group.flexDirection == self.FlexDirection.Column then
		local draw_coords = self:calculateColumnSpacedCoords(group.children, gaps)
		self:setItemFlexCoordinatesX(group.children, draw_coords)
	end
end

function LUI:solveArrayCoordsRow(group)
	local cx          = group.children[1].padding
	local draw_coords = {cx}
	for i = 1, #group.children - 1 do
		local item = group.children[i]
		cx = cx + item.height + item.padding + group.children[i+1].padding + group.spacing
		table.insert(draw_coords, cx)
	end
	return draw_coords
end

function LUI:solveArrayCoordsColumn(group)
	local cx          = group.children[1].padding
	local draw_coords = {cx}
	for i = 1, #group.children - 1 do
		local item = group.children[i]
		cx = cx + item.width + item.padding + group.children[i+1].padding + group.spacing
		table.insert(draw_coords, cx)
	end
	return draw_coords
end

function LUI:solveArrayOffsetRow(group)
	if group.orientation == self.FlexOrientation.Top or group.orientation == nil then
		return 0
	end
	local last = group.children[#group.children]
	local tih  = last.flex_y + last.height
	if group.orientation == self.FlexOrientation.Bottom then
		return group.height - tih - last.padding
	elseif group.orientation == self.FlexOrientation.Middle then
		return math.floor((group.height - tih) / 2)
	else
		error("Invalid FlexOrientation")
	end
end

function LUI:solveArrayOffsetColumn(group)
	if group.orientation == self.FlexOrientation.Left or group.orientation == nil then
		return 0
	end
	local last = group.children[#group.children]
	local tiw  = last.flex_x + last.width
	if group.orientation == self.FlexOrientation.Right then
		return group.width - tiw - last.padding
	elseif group.orientation == self.FlexOrientation.Middle then
		return math.floor((group.width - tiw) / 2)
	else
		error("Invalid FlexOrientation")
	end
end

function LUI:transferAttributes(t, target, values)
	for i = 1, #t do t[i][target] = values[i] end
end

function LUI:addScalarToAttributes(t, target, value)
	for i = 1, #t do t[i][target] = t[i][target] + value end
end

function LUI:sortMinMax(v1, v2)
	return math.min(v1, v2), math.max(v1, v2)
end

function LUI:solveFlexArray(group)
	if #group.children == 0 then return end
	if group.flexDirection == self.FlexDirection.Row then
		local draw_coords = self:solveArrayCoordsRow(group)
		self:transferAttributes(group.children, "flex_y", draw_coords)
		local offset = self:solveArrayOffsetRow(group)
		self:addScalarToAttributes(group.children, "flex_y", offset)
	elseif group.flexDirection == self.FlexDirection.Column then
		local draw_coords = self:solveArrayCoordsColumn(group)
		self:transferAttributes(group.children, "flex_x", draw_coords)
		local offset = self:solveArrayOffsetColumn(group)
		self:addScalarToAttributes(group.children, "flex_x", offset)
	end
end

function LUI:solveFlex(group)
	if group.flex == nil then return end
	if group.flex == self.Flex.Spaced then
		self:solveFlexSpaced(group)
	elseif group.flex == self.Flex.Array then
		self:solveFlexArray(group)
	else
		error("Invalid Flex type")
	end
	for _, item in pairs(group.children) do
		self:solveFlex(item)
	end
end

function LUI:drawFilledBox(x1, y1, x2, y2, color1, color2, char)
	x1, y1, x2, y2 = math.floor(x1), math.floor(y1), math.floor(x2), math.floor(y2)
	x1, x2 = self:sortMinMax(x1, x2)
	y1, y2 = self:sortMinMax(y1, y2)
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

function LUI:drawItem(item)
	local x, y = item:getCoords()
	self:drawFilledBox(
		x, y,
		x + item.width, y + item.height,
		item.color,
		item.fillDecorationColor or item.color,
		item.fillDecoration or " "
	)	
	if item.text then 
		if item.textColor then 
			term.setTextColor(LUI.CCColor[item.textColor])
		end
		term.setBackgroundColor(LUI.CCColor[item.color])
		term.setCursorPos(x, y)
		term.write(item.text)
	end
end

function LUI:render(group)
	self:drawItem(group)
	for _, v in pairs(group.children) do
		self:render(v)
	end
end

function LUI:readMeasure(c)
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	local s = self:measure(c)
	term.setCursorPos(1, c)
	term.write(s)
end