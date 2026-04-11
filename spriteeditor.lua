require("lui/style")

local buffer = {}
local cbuffer = {}

local sw = 16
local sh = 16

local scw = math.ceil(sw/2)
local sch = math.ceil(sh/3)

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

local function drawPaintBuffer(buffer, x, y)
	term.clear()
	term.setTextColor(colors.gray)
	local x = x or 0 
	local y = y or 0
	for i=0, sh-1 do
		term.setCursorPos(x, y+i)
		for j=0, sw-1 do 
			local cbx = math.floor(i/2)+1
			local cby = math.floor(j/3)+1
			term.setCursorPos(i*2+x+1, j+y+1)

			if buffer[j+1][i+1] then 
				term.setBackgroundColor(cbuffer[cby][cbx][2])
				term.write("  ")
			else 
				if cbuffer[cby][cbx][1] ~= colors.black then 
					term.setBackgroundColor(cbuffer[cby][cbx][1])
					term.write("  ")
				elseif cbx % 2 == cby % 2 then
					term.setBackgroundColor(colors.black) 
					term.write(string.rep(string.char(127),2))
				end
			end
		end
	end
end

buffer[1][1] = true
cbuffer[1][1][2] = colors.red 
cbuffer[1][1][1] = colors.blue

drawPaintBuffer(buffer)

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
	term.setCursorPos(2,21)
	term.write("(x:" .. x .. ", y:" .. y .. ")")
	term.setCursorPos(2,22)
	term.write("[x:" .. x .. ", y:" .. y .. "]")
end	

local lx = 0
local ly = 0

while true do 
	drawPaintBuffer(buffer)	
	displayCfgType()
	displayDrawInfo(lx,ly)
	local e, a1, a2, a3 = os.pullEvent()
	if e == "mouse_click" then 
		if a1 == 1 then 
			setPixel(math.ceil(a2/2), a3, true)
		elseif a1 == 2 then 
			setPixel(math.ceil(a2/2), a3, false)
		elseif a1 == 3 then 
			local a = getColorAt(a2,a3,1)
			cfg_picker = a[1]
			cfg_type = a[2] 
		end
		lx = a2
		ly = a3
	end




end	