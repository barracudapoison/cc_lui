require("lui/lui")
local LUI = LUI

local w, h = term.getSize()

local b = LUI.Item.new({
	width = 10,
	height = 5,
	ox = 5,
	oy = 10,
	cox = 1,
	flex = LUI.Flex.Type.Array,
	flexDirection = LUI.Flex.Direction.Row,
	orientation = LUI.Flex.Orientation.Top,
	spacing = 0,
	color = LUI.Style.LColor.Gray
})

local option1 = LUI.Item.new({
	width = 1,
	height = 1,
	color = LUI.Style.LColor.Gray,
	text = "New",
	textColor = LUI.Style.LColor.Black
})

local option2 = LUI.Item.new({
	width = 1,
	height = 1,
	color = LUI.Style.LColor.Gray,
	text = "Resize",
	textColor = LUI.Style.LColor.Black
})

local option3 = LUI.Item.new({
	width = 1,
	height = 1,
	color = LUI.Style.LColor.Gray,
	text = "Set",
	textColor = LUI.Style.LColor.Black
})

b:addChild(option1)
b:addChild(option2)
b:addChild(option3)

local group = LUI.Item.new({
	width = 1,
	widthUnit = LUI.Style.Unit.Percent,
	height = 3,
	ox = 1,
	oy = 1,
	flex = LUI.Flex.Type.Array,
	flexDirection = LUI.Flex.Direction.Column,
	orientation = LUI.Flex.Orientation.Middle,
	spacing = 1,
	color = LUI.Style.LColor.Gray,
	fillDecoration = ".",
	fillDecorationColor = LUI.Style.LColor.LightGray
})


local test = LUI.Item.new({
	width = 9,
	height = 3,
	color = LUI.Style.LColor.Green,
	flex = LUI.Flex.Array,
	flexDirection = LUI.Flex.Direction.Row,
	orientation = LUI.Flex.Orientation.Top
})

print(test.flexDirection)


test:addChild(LUI.Item.new({
	width = 9,
	height = 1,
	color = LUI.Style.LColor.Purple,
	visible = true
}))

test:addChild(LUI.Item.new({
	width = 9,
	height = 1,
	color = LUI.Style.LColor.Orange
}))

test:addChild(LUI.Item.new({
	width = 9,
	height = 1,
	color = LUI.Style.LColor.Blue
}))

--term.setCursorPos(10,10)

group:addChild(test)

group:addChild(LUI.Item.new({
	width = 0.3,
	widthUnit = LUI.Style.Unit.Percent,
	height = 3,
	color = '4'
}))
group:addChild(LUI.Item.new({
	width = 3,
	height = 3,
	color = '5'
}))

local body = LUI.Item.new({
	visible = false,
	width = w,
	height = h,
	
})

body:addChild(group)
body:addChild(b)

LUI:render(body)