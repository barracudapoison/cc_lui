require("lui/item")
require("lui/util")

Flex = {}

Flex.Type = {
	None   = 0,
	Array  = 1,
	Spaced = 2,
	Fill   = 1024,
}

Flex.Orientation = {
	Left   = 1,
	Middle = 2,
	Right  = 3,
	Top    = 4,
	Bottom = 5,
}

Flex.Direction = {
	Column = 1,
	Row    = 2,
}

function Flex:getSumHeight(items)
	local a = 0
	for _, item in pairs(items) do
		a = a + item.height + item.padding * 2
	end
	return a
end

function Flex:getSumWidth(items)
	local a = 0
	for _, item in pairs(items) do
		a = a + item:getWidth() + item.padding * 2
	end
	return a
end

function Flex:getGaps(items, dsize)
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
function Flex:calculateRowSpacedCoords(items, gaps)
	local cx = 0
	local draw_coords = {cx}
	for i = 1, #items - 1 do
		cx = cx + items[i]:getHeight() + items[i].padding + items[i+1].padding + gaps[i]
		table.insert(draw_coords, cx)
	end
	return draw_coords
end

-- Column = items laid out horizontally → coords along X axis, size = width
function Flex:calculateColumnSpacedCoords(items, gaps)
	local cx = 0
	local draw_coords = {cx}
	for i = 1, #items - 1 do
		cx = cx + items[i]:getWidth() + items[i].padding + items[i+1].padding + gaps[i]
		table.insert(draw_coords, cx)
	end
	return draw_coords
end

function Flex:setItemFlexCoordinatesY(items, coords)
	for i = 1, #coords do items[i].flex_y = coords[i] end
end

function Flex:setItemFlexCoordinatesX(items, coords)
	for i = 1, #coords do items[i].flex_x = coords[i] end
end

function Flex:solveFlexSpaced(group)
	if group.flex == nil       then return end
	if #group.children == 0    then return end
	if group.flexDirection == nil then
		group.flexDirection = self.Direction.Column
	end

	local sum_item_size, dsize

	-- Row: children stack vertically, so measure height
	-- Column: children sit side-by-side, so measure width
	if group.flexDirection == self.Direction.Row then
		sum_item_size = self:getSumHeight(group.children)
		dsize         = group:getHeight() - sum_item_size
	elseif group.flexDirection == self.Direction.Column then
		sum_item_size = self:getSumWidth(group.children)
		dsize         = group:getWidth() - sum_item_size
	else
		error("Invalid FlexDirection")
	end

	local gaps = self:getGaps(group.children, dsize)

	if group.flexDirection == self.Direction.Row then
		local draw_coords = self:calculateRowSpacedCoords(group.children, gaps)
		self:setItemFlexCoordinatesY(group.children, draw_coords)
	elseif group.flexDirection == self.Direction.Column then
		local draw_coords = self:calculateColumnSpacedCoords(group.children, gaps)
		self:setItemFlexCoordinatesX(group.children, draw_coords)
	end
end

function Flex:solveArrayCoordsRow(group)
	local cx          = group.children[1].padding
	local draw_coords = {cx}
	for i = 1, #group.children - 1 do
		local item = group.children[i]
		cx = cx + item:getHeight() + item.padding + group.children[i+1].padding + group.spacing
		table.insert(draw_coords, cx)
	end
	return draw_coords
end

function Flex:solveArrayCoordsColumn(group)
	local cx          = group.children[1].padding
	local draw_coords = {cx}
	for i = 1, #group.children - 1 do
		local item = group.children[i]
		cx = cx + item:getWidth() + item.padding + group.children[i+1].padding + group.spacing
		table.insert(draw_coords, cx)
	end
	return draw_coords
end

function Flex:solveArrayOffsetRow(group)
	if group.orientation == self.Orientation.Top or group.orientation == nil then
		return 0
	end
	local last = group.children[#group.children]
	local tih  = last.flex_y + last:getHeight()
	if group.orientation == self.Orientation.Bottom then
		return group:getHeight() - tih - last.padding
	elseif group.orientation == self.Orientation.Middle then
		return math.floor((group:getHeight() - tih) / 2)
	else
		error("Invalid Orientation")
	end
end

function Flex:solveArrayOffsetColumn(group)
	if group.orientation == self.Orientation.Left or group.orientation == nil then
		return 0
	end
	local last = group.children[#group.children]
	local tiw  = last.flex_x + last:getWidth()
	if group.orientation == self.Orientation.Right then
		return group:getWidth() - tiw - last.padding
	elseif group.orientation == self.Orientation.Middle then
		return math.floor((group:getWidth() - tiw) / 2)
	else
		error("Invalid Orientation")
	end
end

function Flex:solveFlexArray(group)
	if #group.children == 0 then return end
	if group.flexDirection == self.Direction.Row then
		local draw_coords = self:solveArrayCoordsRow(group)
		Util.transferAttributes(group.children, "flex_y", draw_coords)
		local offset = self:solveArrayOffsetRow(group)
		Util.addScalarToAttributes(group.children, "flex_y", offset)
	elseif group.flexDirection == self.Direction.Column then
		local draw_coords = self:solveArrayCoordsColumn(group)
		Util.transferAttributes(group.children, "flex_x", draw_coords)
		local offset = self:solveArrayOffsetColumn(group)
		Util.addScalarToAttributes(group.children, "flex_x", offset)
	end
end

function Flex:solveFlex(group)
	if group.flex == nil then 
		-- ignore i guess. cant figure out a better code pattern
		-- that keeps the children being solved
	elseif group.flex == self.Type.Spaced then
		self:solveFlexSpaced(group)
	elseif group.flex == self.Type.Array then
		self:solveFlexArray(group)
	else
		error("Invalid Flex type")
	end
	for _, item in pairs(group.children) do
		self:solveFlex(item)
	end
end
