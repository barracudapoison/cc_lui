term.clear()
term.setCursorPos(1,1)


local Item = {
	width = 0,
	height = 0,
	padding = 0,
	color = nil,
    flex_x = 0,
    flex_y = 0,
    left = 0,
    top = 0,
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
	Right = 3,
    Top = 4,
    Bottom = 5
}

local FlexDirection = {
    Column = 1,
    Row = 2
}


local group = {
	children = {
		Item:new(3, 3, 1, colors.red),
		Item:new(3, 3, 0, colors.blue),
		Item:new(3, 3, 1, colors.green),
		--Item:new(3, 3, 0, colors.white),
	},
	width = 0,
	height = 0,
	flex = Flex.Array,
    flexDirection = FlexDirection.Column,
	orientation = Orientation.Right,
	spacing = 0
}

group.width, group.height = term.getSize()
group.width = group.width + 1
group.height = group.height + 1

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


local function solveFlexSpaced(group)

    local sum_item_size = 0
    local dsize = 0
    local gaps = {}
    local draw_coords = {}

    if group.flexDirection == FlexDirection.Row then
        for _, item in pairs(group.children) do
            sum_item_size = sum_item_size + item.height + item.padding * 2
        end
        dsize = group.height - sum_item_size
    elseif group.flexDirection == FlexDirection.Column then
        for _, item in pairs(group.children) do
            sum_item_size = sum_item_size + item.width + item.padding * 2
        end
        dsize = group.width - sum_item_size
    else
        print("Invalid FlexDirection")
        return
    end

    local amt_gaps = #group.children - 1
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

    local cx = 1
    draw_coords[1] = 1

    if group.flexDirection == FlexDirection.Row then

        for i=1, #group.children-1 do
            cx = cx + group.children[i].height + group.children[i].padding + group.children[i+1].padding
            cx = cx + gaps[i]
            table.insert(draw_coords, cx)
        end

        for i=1, #draw_coords do
            group.children[i].y = draw_coords[i]
        end

    elseif group.flexDirection == FlexDirection.Column then

        for i=1, #group.children-1 do
            cx = cx + group.children[i].width + group.children[i].padding + group.children[i+1].padding
            cx = cx + gaps[i]
            table.insert(draw_coords, cx)
        end

        for i=1, #draw_coords do
            group.children[i].x = draw_coords[i]
        end

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

	if group.flex == Flex.Spaced then

        solveFlexSpaced(group)

	elseif group.flex == Flex.Array then

        solveFlexArray(group)

	else
        print("Invalid Flex type")
	end

end

local function render(group)
	for k, v in pairs(group.children) do
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


--[[

local function solveFlexArray(group)

end




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


item1
    width = 3
    ...
item2
    width = fill
    padding = 1
    ...
item3
    width = 3
    ...

fillPriority = 1
fillPriority = 2
...
for children which use fill in a flex environment, will add fill to the children
    which have the lower priority first
    once all priorities of n=1 have been met, the next level of prioriities will be filled
    this allows better control of which elements grow with an expanding monitor

expect item2.width = (dsize - tfiw)



]]
