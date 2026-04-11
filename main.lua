require("lui/lui")
local LUI = LUI 

local w, h = term.getSize()

local body = LUI.Item.new({
	visible = false,
	width = w,
	height = h,
	cox = 1,
	coy = 1
})

local header = LUI.Item.new({
	width = 1,
	widthUnit = LUI.Style.Unit.Percent,
	height = 2,
	flex = LUI.Flex.Type.Array,
	flexDirection = LUI.Flex.Direction.Row,
	color = LUI.Style.LColor.LightGray
})
local title_bar = LUI.Item.new({
	width = 1,
	widthUnit = LUI.Style.Unit.Percent,
	height = 1,
	flex = LUI.Flex.Type.Array,
	flexDirection = LUI.Flex.Direction.Column,
	flexOrientation = LUI.Flex.Orientation.Middle,
	color = LUI.Style.LColor.LightGray
})
local ts_text = "Example Program"
local title_span = LUI.Item.new({
	width = #ts_text,
	height = 1,
	text = ts_text,
	color = LUI.Style.LColor.LightGray
})
local option_bar = LUI.Item.new({
	width = 1,
	widthUnit = LUI.Style.Unit.Percent,
	height = 1,
	flex = LUI.Flex.Type.Array,
	flexDirection = LUI.Flex.Direction.Column,
	color = LUI.Style.LColor.LightGray,	
	spacing = 1
})


body:addChild(header)

header:addChild(title_bar)
header:addChild(option_bar)

title_bar:addChild(title_span)

LUI:render(body)