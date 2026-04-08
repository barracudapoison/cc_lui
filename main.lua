
local rcdd = {
	"add",
	"remove",
	"resize",
	"",
	width = 6
}

local click_listeners = {
	[1] = {

	},
	[2] = {

	}
}

-- [1-2 for left right click], coords, func ref
local function newClickListener( mi, x1, y1, x2, y2, zlayer, ref)

	return {
		mi = mi,
		x1 = x1, 
		y1 = y1,
		x2 = x2, 
		y2 = y2, 
		ref = ref,
		zlayer = zlayer,
		active = true 
	}

end

local function addClickListener(cl)
	local mouse_button = cl.mi
	table.insert(click_listeners[mouse_button], cl)
end

local current_dd = rcdd

local function drawDropdown(dd, x, y)
	local s = string.rep(" ", dd.width)

	term.setBackgroundColor(colors.gray)
	term.setTextColor(colors.white)

	for i=1, #dd do 
		local y1 = y-1+i
		term.setCursorPos(x,y1)
		term.write("|")
		term.write(s)
		term.write("|")
	end

	for i=1, #dd do 
		local y1 = y-1+i
		term.setCursorPos(x+1, y1)
		term.write(dd[i])
	end

end

local function drawBackground()
	term.setBackgroundColor(colors.lightGray)
	term.clear()

end

local function drawToolbar()
	term.setCursorPos(1,1)
	term.setBackgroundColor(colors.blue)
	term.clearLine()
	
	term.setTextColor(colors.white)
	local items = {
		"File",
		"Add",
		"Select",
		"View",
		"Help"
	}

	term.setCursorPos(2,1)
	for i=1, #items do
		term.setTextColor(colors.white) 
		term.write(items[i])
		term.setTextColor(colors.lightGray)
		term.write(" | ")
	end

end

local function drawScreen()
	drawBackground()
	drawToolbar()
end

local function inRange(v,min,max)
	return (v >= min and v <= max)
end	

local function inBounds(x,y,x1,y1,x2,y2)
	return inRange(x,x1,x2) and inRange(y,y1,y2)
end

local function checkClickListeners(mouse_button, x, y)
	for i=1, #click_listeners[mouse_button] do 
		local c = click_listeners[mouse_button][i]
		if c.active and inBounds(x,y,c.x1,c.y1,c.x2,c.y2) then 
			c.ref()
		end
	end
end

local function test(...)
	term.setCursorPos(10,10)
	term.write(...)
end

local function open_ddfile()
	drawDropdown({
		"New",
		"Open",
		"Save",
		"Save As",
		"Exit",
		width = 7
	},1,2)
end

local function open_ddtools()
	drawDropdown({
		"Box",
		"Filled Box",
		"Textbox",
		"Chart",
		"Button",
		width = 10
	},7,2)
end

--addClickListener(newClickListener(1, 2,2,10,10,1,test, "hello world"))

addClickListener(newClickListener(1, 1,1,6,1,1,open_ddfile))
addClickListener(newClickListener(1, 8,1, 11,1, 1,open_ddtools))

local function handleLeftClick(x,y)
	drawScreen()
	checkClickListeners(1, x, y)
	-- if not on dropdown, clear drop down
end

local function handleMiddleClick() end 

local function handleRightClick(x, y) 
	drawScreen()
	drawDropdown(rcdd, x, y+1)
end 

drawScreen()



while true do 
	local event, a1, a2, a3, a4 = os.pullEvent()
	if event == "mouse_click" then 
		if a1 == 1 then 
			handleLeftClick(a2, a3)
		elseif a1 == 3 then 
			handleMiddleClick(a2, a3)
			os.everythingDies()
		elseif a1 == 2 then 
			handleRightClick(a2,a3)
		end
	end
end

