term.clear()
term.setCursorPos(1,1)


local Item = {
	width = 0,
	height = 0,
	padding = 0,
	color = nil,
	x = 1,
	y = 1
}
Item.__index = Item 

function Item:new(width, height, padding, color)
	local o = setmetatable({}, self)
	o.width = width 
	o.height = height 
	o.padding = padding 
	o.color = color
	return o
end

local Flex = {
	Array = 1,
	Spaced = 2,
	Fill = 1024
}


local Orientation = {
	Left = 1,
	Middle = 2,
	Right = 3
}


local group = {
	items = {
		Item:new(3, 10, 0, colors.red),
		Item:new(3, 10, 0, colors.blue),
		Item:new(3, 10, 0, colors.green),
		Item:new(3, 10, 0, colors.white),
	},
	width = 71,
	height = 4,
	flex = Flex.Array,
	orientation = Orientation.Middle,
	spacing = 1
}

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
	return "{" .. g[2][1] - g[1][1] .. "," .. g[2][2] - g[1][2] .. "}"
end

local function solveFlex(group)

	local sum_item_width = 0
	
	for _, v in pairs(group.items) do
		sum_item_width = sum_item_width + v.width + v.padding * 2
	end

	local draw_coords = {}
	local gaps = {}

	if group.flex == Flex.Spaced then 

		local dwidth = group.width - sum_item_width
		local amt_gaps = #group.items - 1
		local gap_size = math.floor(dwidth/amt_gaps)
		local amt_lgaps = dwidth % amt_gaps

		local lgaps_left = amt_lgaps
		for i=1, amt_gaps do 
			local z = gap_size 
			if lgaps_left > 0 then 
				z = z + 1 
				lgaps_left = lgaps_left - 1 
			end
			table.insert(gaps, z)
		end
		
		draw_coords[1] = 1
		local cx = 1
		for i=1, #group.items-1 do 
			cx = cx + group.items[i].width + group.items[i].padding + group.items[i+1].padding
			cx = cx + gaps[i]
			table.insert(draw_coords, cx)
		end

		for i=1, #draw_coords do 
			group.items[i].x = draw_coords[i]
		end


	elseif group.flex == Flex.Array then 

		local amt_gaps = #group.items - 1
		local draw_coords = {1}

		local cx = 1 + group.items[1].padding 
		for i=1, amt_gaps do 

			cx = cx + group.items[i].width 
			cx = cx + group.items[i].padding
			cx = cx + group.items[i+1].padding
			cx = cx + group.spacing

			table.insert(draw_coords, cx)

		end

		
		for i=1, #draw_coords do 
			group.items[i].x = draw_coords[i]
		end
		if group.orientation == Orientation.Left then return end 
	
		local ti_width = group.items[#group.items].x + group.items[#group.items].width
		local offset = 0
		if group.orientation == Orientation.Right then 
			offset = group.width - ti_width
		elseif group.orientation == Orientation.Middle then 
			offset = math.floor((group.width-ti_width)/2)
		end

		for i=1, #draw_coords do 
			group.items[i].x = group.items[i].x + offset
		end

	end
	


end

local function render(group)
	for k, v in pairs(group.items) do
		paintutils.drawFilledBox(
			v.x,
			v.y,
			v.x + v.width - 1,
			v.y + v.height - 1,
			v.color
		)
	end
end

local function readMeasure(c)
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	s = measure(c)
	term.setCursorPos(1,c)
	term.write(s)
end


solveFlex(group)
render(group)

readMeasure(1)
readMeasure(2)
readMeasure(3)

--[[

width = Flex.Fill

Flex.Spaced
	not sure if you should be able to use Flex.Fill in a Flex.Spaced box

Flex.Array
	count # of elements with Flex.Fill, use space remaining after accounting for "spacing" and "padding" to evenly
	divide the amount of Flex.Fill available

how would Flex.Fill work with a maxWidth variable?
how would Flex.Fill work with a fillScale variable? ie. item1(width=fill, fillScale = 2), item2(width=fill, fillScale=1)

keep track of groups with flex.fill to do an early check before treating flex box like a Flex.Spaced?
it has become obvious that flex.fill does not work in a Flex.Spaced container

make array alignment for flex.array plz

]]