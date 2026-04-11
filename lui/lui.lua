require("lui/item")
require("lui/input")
require("lui/flex")
require("lui/anchor")
require("lui/graphics")
require("lui/util")
require("lui/style")

LUI = {
	Item = Item,
	Flex = Flex,
	Util = Util,
	Style = Style,
	Graphics = Graphics
}

function LUI:render(body)
	term.clear()
	self.Flex:solveFlex(body)
	self.Graphics:render(body)
end