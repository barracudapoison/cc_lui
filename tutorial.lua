local w, h = term.getSize()

local message = "Welcome to LUI"

local dcomppiston = paintutils.loadImage("dcomputer.nfp")

for k, v in pairs(dcomppiston[3]) do 
	term.write(k) term.write(", ")
	term.write(v)
	print()
end

os.pullEvent("mouse_click")

local function getCenteredMessage(s,row,additive)
	local v = math.floor(h/2)
	if row and not additive then 
		v = row 
	elseif row then 
		v = v + row 
	end 
	return math.floor((w-#s)/2), v
end

local function drawPage1()
	
	local m1 = "Welcome to LUI!"
	term.setBackgroundColor(colors.blue)
	term.clear()
	term.setCursorPos(getCenteredMessage(message))
	term.write(message)

	local m2 = "[Click anywhere to continue]"
	term.setCursorPos(getCenteredMessage(m2,1,true))
	term.setTextColor(colors.lightGray)
	term.write(m2)

end

local function drawPage2()
	term.clear()
	term.setTextColor(colors.white)

	local t = "The Problem"
	term.setCursorPos(getCenteredMessage(t,2))
	term.write(t)

	local mn = {
		"Landons UI is designed to    ",
		"help you guys interface      ",
		"computers to other computers,",
		"turtles, logistics mods      ",
		"and honestly whatever else   ",
	    "you can think of             "
	}
	for i=1, #mn do 
		term.setCursorPos(getCenteredMessage(mn[i], i-3, true))
		term.write(mn[i])
	end
end

local function drawPage3()
	term.clear()
	term.setTextColor(colors.white)

	local t = "The Tools"
	term.setCursorPos(getCenteredMessage(t,2))
	term.write(t)

	local mn = {
		"Everything you need can be   ",
		"done with:                   ",
		" - Buttons                   ",
		" - Event Listeners           ",
		" - Operation Codes           ",
		"",
		"These are your building      ",
		"blocks for strong, functional",
		"interfaces.                  "
	}
	for i=1, #mn do 
		term.setCursorPos(getCenteredMessage(mn[i], i-5, true))
		term.write(mn[i])
	end
end

local function drawPage3()
	term.clear()
	term.setTextColor(colors.white)

	local t = "Buttons"
	term.setCursorPos(getCenteredMessage(t,2))
	term.write(t)

	local mn = {
		"Buttons are exactly as they sound.",
		"Simply a pressable button.        ",
		"",
		"They can output redstones signals ",
		"locally and remotely, allowing    ",
		"control from a central hub if     ",
		"necessary.                        "
	}
	for i=1, #mn do 
		term.setCursorPos(getCenteredMessage(mn[i], i-5, true))
		term.write(mn[i])
	end
end

local function drawPage4()
	term.clear()
	term.setTextColor(colors.white)

	local t = "Operation Codes"
	term.setCursorPos(getCenteredMessage(t,2))
	term.write(t)

	local mn = {
		"Buttons can also send Operation Codes.  ",
		"An operation code is some word,         ",
		"sentence, number, whatever; that can    ",
		"be wirelessly read from any computer    ",
		"waiting for the call.                   ",
		"",
		"While not necessary in many cases, the  ",
		"tool is at your disposal.               "
	}
	for i=1, #mn do 
		term.setCursorPos(getCenteredMessage(mn[i], i-5, true))
		term.write(mn[i])
	end
end

drawPage1()
os.pullEvent("mouse_click")
drawPage2()
os.pullEvent("mouse_click")
drawPage3()
os.pullEvent("mouse_click")
drawPage4()
os.pullEvent("mouse_click")