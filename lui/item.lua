require("lui/style")
require("lui/util")

local Util = Util
local Style = Style

Item = {}
Item.__index = Item

function Item.initStyle(o, args)
	o.text 		= args.text      or ""
	o.width     = args.width     or 0
	o.height    = args.height    or 0
	o.widthUnit = args.widthUnit or LUI.Style.Unit.Default
	o.heightUnit = args.heightUnit or LUI.Style.Unit.Default
	o.dwidth    = args.width     or 0
	o.dheight   = args.height    or 0 
	o.padding   = args.padding   or 0
	o.color     = args.color	 or -1
	o.flex_x    = args.flex_x    or 0
	o.flex_y    = args.flex_y    or 0
	o.ox        = args.ox        or 0
	o.oy        = args.oy        or 0
	o.x         = args.x         or 0
	o.y         = args.y         or 0
	o.cox 		= args.cox 		 or 0
	o.coy  		= args.coy		 or 0
	o.minWidth  = args.minWidth  or 0
	o.maxWidth  = args.maxWidth  or 256 
	o.minHeight = args.minHeight or 0 
	o.maxHeight = args.maxHeight or 256 
	
	o.visible   = (args.visible ~= false)

	o.flex          = args.flex
	o.flexDirection = args.flexDirection
	o.flexOrientation   = args.flexOrientation
	
	o.spacing       = args.spacing or 0
	
	o.fillDecoration      = args.fillDecoration
	o.fillDecorationColor = args.fillDecorationColor
	
	o.children = {}
	o.class = {}
end

function Item.new(args)
	local o = setmetatable({}, {__index = LUI.Item})
	o.id        = Util.assignID()
	LUI.Item.initStyle(o, args)
	return o
end

function Item:setStyle(args)
	for k, v in pairs(args) do 
		self[k] = v
	end
end

function Item:setPosition(x, y)
	self.x = x
	self.y = y
end

function Item:setOffset(ox, oy)
	self.ox = ox
	self.oy = oy
end

function Item:setSize(w, h)
	self.width  = w
	self.height = h
end

function Item:getWidth()
	if self.widthUnit == Style.Unit.Default then 
		return Util.keepInRange(self.width, self.minWidth, self.maxWidth) 
	elseif self.widthUnit == Style.Unit.Percent then 
		return Util.keepInRange(self.parent:getWidth() * self.width, self.minWidth, self.maxWidth)
	end
end

function Item:getHeight()
	if self.heightUnit == Style.Unit.Default then 
		return Util.keepInRange(self.height, self.minHeight, self.maxHeight)
	elseif self.heightUnit == Style.Unit.Percent then 
		return Util.keepInRange(self.parent:getHeight() * self.height, self.minHeight, self.maxHeight)
	end
end

function Item:addChild(item)
	table.insert(self.children, item)
	item.parent = self
end

function Item:getFlexOffset()
	return self.flex_x, self.flex_y
end

function Item:translate(x, y)
	self.x = self.x + x
	self.y = self.y + y
end


function Item:getCoords()
	local px, py = 0, 0
	if self.parent then
		px, py = self.parent:getCoords()
		px, py = px + self.parent.cox, py + self.parent.coy
	end
	return self.x + self.ox + self.flex_x + px,
	       self.y + self.oy + self.flex_y + py
end