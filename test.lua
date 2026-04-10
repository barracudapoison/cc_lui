require("flex")

local w, h = term.getSize()


local b = LUI.Item.new({
	width = 10,
	height = 5,
	ox = 5,
	oy = 10,
	flex = LUI.Flex.Array,
	flexDirection = LUI.FlexDirection.Row,
	orientation = LUI.FlexOrientation.Top,
	spacing = 0,
	color = LUI.LColor.Gray
})

local option1 = LUI.Item.new({
	width = 1,
	height = 1,
	ox = 1,
	color = LUI.LColor.Gray,
	text = "New",
	textColor = LUI.LColor.Black
})

local option2 = LUI.Item.new({
	width = 1,
	height = 1,
	ox = 1,
	color = LUI.LColor.Gray,
	text = "Resize",
	textColor = LUI.LColor.Black
})

local option3 = LUI.Item.new({
	width = 1,
	height = 1,
	ox = 1,
	color = LUI.LColor.Gray,
	text = "Set",
	textColor = LUI.LColor.Black
})

b:addChild(option1)
b:addChild(option2)
b:addChild(option3)

local group = LUI.Item.new({
	width = w,
	height = 3,
	ox = 1,
	oy = 1,
	flex = LUI.Flex.Array,
	flexDirection = LUI.FlexDirection.Column,
	orientation = LUI.FlexOrientation.Middle,
	spacing = 1,
	color = LUI.LColor.Gray,
	fillDecoration = ".",
	fillDecorationColor = LUI.LColor.LightGray
})
term.setCursorPos(10,10)

local test = LUI.Item.new({
	width = 9,
	height = 3,
	color = LUI.LColor.Green,
	flex = LUI.Flex.Array,
	flexDirection = LUI.FlexDirection.Row,
	orientation = LUI.FlexOrientation.Top
})


test:addChild(LUI.Item.new({
	width = 9,
	height = 1,
	color = LUI.LColor.Purple
}))

test:addChild(LUI.Item.new({
	width = 9,
	height = 1,
	color = LUI.LColor.Orange
}))
test:addChild(LUI.Item.new({
	width = 9,
	height = 1,
	color = LUI.LColor.Blue
}))

--term.setCursorPos(10,10)

group:addChild(test)

group:addChild(LUI.Item.new({
	width = 5,
	height = 3,
	color = '4'
}))
group:addChild(LUI.Item.new({
	width = 3,
	height = 3,
	color = '5'
}))


LUI:solveFlex(group)
LUI:render(group)

LUI:solveFlex(b)
LUI:render(b)