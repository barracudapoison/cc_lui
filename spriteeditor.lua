require("lui/style")

local buffer = {}
local cbuffer = {}

local sw = 16
local sh = 16

local scw = math.ceil(sw/2)
local sch = math.ceil(sh/3)

local dscale = 1
local x = 1
local y = 1

local lx = 0
local ly = 0

local dscl = 2
local grid_type = 1

local ctool = "pencil"
local draw_grid = true

for i=1, sh do 
	local a = {}
	for j=1, sw do 
		table.insert(a, false)
	end
	table.insert(buffer, a)
end

for i=1, sch do 
	local a = {}
	for j=1, scw do 
		table.insert(a, {colors.black, colors.white})
	end
	table.insert(cbuffer, a)
end


local function drawPaintBuffer(buffer, x, y, dscale)
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setTextColor(colors.gray)
	-- local x = x or 0
	-- local y = y or 0
	for i=0, sh-1 do
		term.setCursorPos(x, y+i)
		for j=0, sw-1 do 
			local cbx = math.floor(i/2)+1
			local cby = math.floor(j/3)+1

			if dscale == 1 then
				term.setCursorPos(i+x+1, j+y+1)
			elseif dscale == 2 then
				term.setCursorPos(i*2+x+1, j+y+1)
			end
			if buffer[j+1][i+1] then 
				term.setBackgroundColor(cbuffer[cby][cbx][2])
				if dscale == 1 then
					term.write(" ")
				elseif dscale == 2 then
					term.write("  ")
				end
			else 
				if cbuffer[cby][cbx][1] ~= colors.black then 
					term.setBackgroundColor(cbuffer[cby][cbx][1])
					if dscale == 1 then
						term.write(" ")
					elseif dscale == 2 then
						term.write("  ")
					end
				elseif drawgrid and cbx % 2 == cby % 2 then
					term.setBackgroundColor(colors.black) 
					term.write(string.rep(string.char(127),dscale))
				end
			end
		end
	end
end


local function setPixel(x,y,v)
	buffer[y][x] = v
end	

local function getColorAt(x,y,i)
	local cbx = math.floor((x-1)/4)+1
	local cby = math.floor((y-1)/3)+1
	local is_foreground = false
	is_foreground = buffer[math.floor((y+1)/3)+1][math.floor((x+1)/2)+1]
	return {cbuffer[cby][cbx][i], is_foreground}
end

local cfg_picker = nil
local cfg_type = false

local function displayCfgType()
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.gray)
	term.setCursorPos(2,20)
	local t = ""
	if cfg_type then 
		t = "fg"
	else
		t = "bg"
	end
	term.write(t .. ":".. tostring(cfg_picker))
end

local function displayDrawInfo(x,y)
	term.setBackgroundColor(colors.black)
	term.setCursorPos(2,21)
	term.write("(x:" .. x .. ", y:" .. y .. ")")
	term.setCursorPos(2,22)
	term.write("[x:" .. x .. ", y:" .. y .. "]")
end	

local hotkeys = {
	["p"] = "pencil",
	["e"] = "erase",
	["b"] = "box",
	["s"] = "select",
	["w"] = "wand",
	["i"] = "picker",
	["m"] = "move"
}

local function drawHotkeys(x,y)


	local x = x or 40
	local y = y or 5


	local i = 0
	for k, v in pairs(hotkeys) do
		if v == ctool then
			term.setTextColor(colors.yellow)
		else
			term.setTextColor(colors.gray)
		end
		i = i + 1
		term.setCursorPos(x,y+i)
		term.write(k .. ":" .. v)
	end
end


local function localToGrid(x,y)
	local gx, gy = x, y
	if dscl == 2 then
		gx = math.ceil(x/2)
	end

	if (gx > sw) or (gx < 1) or (gy > sh) or (gy < 1) then
		return false, false
	end

	return gx, gy
end

local running = true

while running do
	drawPaintBuffer(buffer, 0, 0, dscl)
	displayCfgType()
	displayDrawInfo(lx,ly)
	drawHotkeys()
	local e, a1, a2, a3 = os.pullEvent()

	if (e == "mouse_drag" or e == "mouse_click") and a2 and a3 then
		local x, y = localToGrid(a2,a3)
		if not x or not y then
		elseif a1 == 1 then
			if ctool == "pencil" then
				setPixel(x,y, true)
			elseif ctool == "erase" then
				setPixel(x,y,false)
			end
		elseif a1 == 2 then
			local a = getColorAt(x,y,1)
			cfg_picker = a[1]
			cfg_type = a[2] 
		end
		lx = a2
		ly = a3
	elseif e == "key" then
		if a1 == keys.y then
			dscl = (dscl)%2+1
		elseif a1 == keys.i then
			ctool = hotkeys.i
		elseif a1 == keys.e then
			ctool = hotkeys.e
		elseif a1 == keys.p then
			ctool = hotkeys.p
		elseif a1 == keys.g then
			drawgrid = not drawgrid
		elseif a1 == keys.m then
			ctool = hotkeys.m
		elseif a1 == keys.v then
			running = false
		end
	end
end

