term.clear()
term.setCursorPos(1,1)

local id = 0

local function merge(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

local Flex = {
	None = 0,
	Array = 1,
	Spaced = 2,
	Fill = 1024
}

local Orientation = {
	Left = 1,
	Middle = 2,
	Right = 3,
    Top = 4,
    Bottom = 5
}

local FlexDirection = {
    Column = 1,
    Row = 2
}

local Item = {
	id =0 ,
	width = 0,
	height = 0,
	padding = 0,
	color = nil,
    flex_x = 0,
    flex_y = 0,
    ox = 0,
    oy = 0,
	x = 0,
	y = 0,
	flex = nil,
	flexDirection = nil,
	orientation = nil,
	spacing = 0
}
Item.__index = Item

function assignID()
	id = id + 1
	return id
end

function Item:new(args)
	local o = setmetatable({}, self)

	args.id = assignID()

	for k, v in pairs(args) do 
		o[k] = v
	end	

	o.children = {}

	return o
end


function Item:setPosition(x,y)
	self.x = x 
	self.y = y
end

function Item:setOffset(ox,oy)
	self.ox = ox 
	self.oy = oy 
end

function Item:setSize(w,h)
	self.width = w
	self.height = h 
end 

function Item:addChild(item)
	table.insert(self.children, item)
	item.parent = self
end

function Item:getFlexOffset()
	return self.flex_x, self.flex_y
end

function Item:translate(x,y)
	self.x = self.x + x 
	self.y = self.y + y 
end 

function Item:getCoords()
	local px, py = 0, 0
	if self.parent then 
		px, py = self.parent:getCoords()
	end
	return self.x + self.ox + self.flex_x + px, self.y + self.oy + self.flex_y + py
end


local function measure(c)
	local g = {}
	local p = 0
	while p < 2 do
		local e, a1, a2, a3 = os.pullEvent("mouse_click")
		if a1 == 1 then
			term.setCursorPos(a2,a3)
			term.blit(tostring(p),"f",tostring(c))
			table.insert(g, {a2,a3})
			p = p + 1
		end
	end
	return "{" .. g[2][1] - g[1][1] + 1 .. "," .. g[2][2] - g[1][2] + 1 .. "}"
end

local function getSumHeight(items)
	local a = 0
	for _, item in pairs(items) do 
		a = a + item.height + item.padding * 2
	end 
	return a
end

local function getSumWidth(items)
	local a = 0

	for _, item in pairs(items) do 
		a = a + item.width + item.padding * 2
	end 
	return a
end

local function getGaps(items, dsize)
	local gaps = {} 

	local amt_gaps = #items - 1
    local gap_size = math.floor(dsize/amt_gaps)
    local amt_lgaps = dsize % amt_gaps

    local lgaps_left = amt_lgaps
    for i=1, amt_gaps do
        local z = gap_size
        if lgaps_left > 0 then
            z = z + 1
            lgaps_left = lgaps_left - 1
        end
        table.insert(gaps, z)
    end

	return gaps
end

local function calculateRowSpacedCoords(items, gaps)

	local cx = 0
	local draw_coords = {cx+0}

	for i=1, #items-1 do
		cx = cx + items[i].height + items[i].padding + items[i+1].padding
		cx = cx + gaps[i]
		table.insert(draw_coords, cx)
	end
	return draw_coords
end

local function calculateColumnSpacedCoords(items, gaps)

	local cx = 0
	local draw_coords = {cx+0}

	for i=1, #items-1 do
		cx = cx + items[i].width + items[i].padding + items[i+1].padding
		cx = cx + gaps[i]
		table.insert(draw_coords, cx)
	end

	return draw_coords

end

local function setItemFlexCoordinatesY(items, coords)
	for i=1, #coords do
		items[i].flex_y = coords[i]
	end
end

local function setItemFlexCoordinatesX(items, coords)
	for i=1, #coords do
		items[i].flex_x = coords[i]
	end
end

local function solveFlexSpaced(group)

	if group.flex == nil then return end 
	if #group.children == 0 then return end 

    local sum_item_size = 0
    local dsize = 0
    local gaps = {}
    local draw_coords = {}

	-- get the total width of the group (sum_item_size) and the amount of space remaining (dsize)
	if group.flexDirection == nil then 
		group.flexDirection = FlexDirection.Column 
	end 

    if group.flexDirection == FlexDirection.Row then

        sum_item_size = getSumHeight(group.children)
        dsize = group.height - sum_item_size

    elseif group.flexDirection == FlexDirection.Column then

		sum_item_size = getSumWidth(group.children)
        dsize = group.width - sum_item_size

	else
        print("Invalid FlexDirection")
        return
    end

    gaps = getGaps(group.children, dsize)

    local cx = 0
    draw_coords[1] = cx

    if group.flexDirection == FlexDirection.Row then

        draw_coords = calculateRowSpacedCoords(group.children, gaps)
		setItemFlexCoordinatesY(group.children, draw_coords)
        

    elseif group.flexDirection == FlexDirection.Column then

        draw_coords = calculateColumnSpacedCoords(group.children, gaps)
		setItemFlexCoordinatesX(group.children, draw_coords)

    end

end

local function solveFlexArray(group)

    local sum_item_size = 0

    local amt_gaps = #group.children - 1

    local gaps = {}
    local draw_coords = {}

    -- get the sum_item_size
    if group.flexDirection == FlexDirection.Row then
       for _, item in pairs(group.children) do
           sum_item_size = sum_item_size + item.height + item.padding * 2
        end

    elseif group.flexDirection == FlexDirection.Column then
        for _, item in pairs(group.children) do
            sum_item_size = sum_item_size + item.width + item.padding * 2
        end
    else
        print("Invalid FlexDirection")
        return
    end

    local cx = 1 + group.children[1].padding
    table.insert(draw_coords, cx)

    if group.flexDirection == FlexDirection.Row then
        for i=1, amt_gaps do
            local item = group.children[i]
            cx = cx + item.height + item.padding + group.children[i+1].padding + group.spacing
            table.insert(draw_coords, cx)
        end

        for i=1, #draw_coords do
            group.children[i].y = draw_coords[i]
        end
        if group.orientation == Orientation.Top then return end
        local last_item = group.children[#group.children]
        local tih = last_item.y + last_item.height
        local offset = 0
        if group.orientation == Orientation.Bottom then
            offset = group.height - tih - last_item.padding
        elseif group.orientation == Orientation.Middle then
            offset = math.floor((group.height - tih)/2)
        else
            print("Invalid FlexOrientation")
            return
        end
        for i=1, #draw_coords do
            group.children[i].y = group.children[i].y + offset
        end
    elseif group.flexDirection == FlexDirection.Column then
        for i=1, amt_gaps do
            local item = group.children[i]
            cx = cx + item.width + item.padding + group.children[i+1].padding + group.spacing
            table.insert(draw_coords, cx)
        end

        for i=1, #draw_coords do
            group.children[i].x = draw_coords[i]
        end
        if group.orientation == Orientation.Left then
            return
        end
        local last_item = group.children[#group.children]
        local tiw = last_item.x + last_item.width
        local offset = 0
        if group.orientation == Orientation.Right then
            offset = group.width - tiw - last_item.padding
        elseif group.orientation == Orientation.Middle then
            offset = math.floor((group_width - tiw)/2)
        else
            print("Invalid FlexOrientation")
        end

        for i=1, #draw_coords do
            group.children[i].x = group.children[i].x + offset
        end

    end


end

local function solveFlex(group)

	
	if group.flex == nil then return end
	if group.flex == Flex.Spaced then

        solveFlexSpaced(group)

	elseif group.flex == Flex.Array then

        solveFlexArray(group)

	else
        print("Invalid Flex type")
	end

	for _, item in pairs(group.children) do 

		solveFlex(item)

	end

end


local function drawItem(item)
	local x, y = item:getCoords()
	paintutils.drawFilledBox(
		x,
		y,
		x + item.width - 1,
		y + item.height - 1,
		item.color
	)
end

local function render(group)
	drawItem(group)
	for k, v in pairs(group.children) do
		render(v)
	end
end

local function readMeasure(c)
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	s = measure(c)
	term.setCursorPos(1,c)
	term.write(s)
end

local w, h = term.getSize()
local group = Item:new({
	width = w,
	height = 3,
	ox = 1,
	oy = 1,
	color = colors.gray,
	flex = Flex.Spaced,
	flexDirection = Flex.Row,
	orientation = Flex.Top
})
term.setCursorPos(10,10)

local test = Item:new({
	width = 9,
	height = 3,
	color = colors.lightGray,
	flex = Flex.Spaced,
	flexDirection = FlexDirection.Row,
	orientation = Orientation.Top
})

test:addChild(Item:new({
	width = 1,
	height = 1,
	color = colors.purple
}))

test:addChild(Item:new({
	width = 1,
	height = 1,
	color = colors.orange
}))
test:addChild(Item:new({
	width = 1,
	height = 1,
	color = colors.blue
}))

--term.setCursorPos(10,10)

group:addChild(test)

group:addChild(Item:new({
	width = 3,
	height = 3,
	color = colors.green
}))
group:addChild(Item:new({
	width = 3,
	height = 3,
	color = colors.yellow
}))


solveFlex(group)
render(group)

--readMeasure(1)

--[[

clean up flex array solve 
relook flex type verifications (flex.direction == something_bad)
	default flex will be flex.array where spacing = 0
rename orientation to flexOrientation

add width % 

use buffer?
	can imagine problems writing text that overlaps two different items
store all items in a box and render based on z-index
assign z-index based on nested level

flex resolving 
shifting container sizes
clothesline alignment

            ###      ##
	---#----###------##-
            ###        


    ---#----###------##- 
	        ###      ## 
			###

separate item constructor to its own class 

anchor.lua
text
textAlign
draggable containers
checkboxes
input
textarea

silhouette rendering? move box, only redraw what needs to be redrawn
dynamic = true 
	(has buffer that stores colors of stuff underneath it)

scrollX and scrollY
makes buffers somewhat imperative

pages:
	some kind of built in dynamic loading system

sheets:
	should be very doable with arrays
	

browsing:
	transmit body item as table?
	key value pairs possibly
	transmit and verify version
	downloading screen!

remote connect:
	login system
	literally transmitting ui from one computer to the other
	how to transmit events?

]]
