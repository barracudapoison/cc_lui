Util = {}

local id = 0
function Util.assignID()
	id = id + 1
	return id
end

function Util.isPercentage(str)
    -- Matches one or more digits, optional decimal, ending with %
	return string.match(str, "^%d+%.?%d*%%$") ~= nil
end

function Util.keepInRange(v,min,max)
	return math.min(math.max(v,min),max)
end

function Util.measure(c)
	local g = {}
	local p = 0
	while p < 2 do
		local _, btn, mx, my = os.pullEvent("mouse_click")
		if btn == 1 then
			term.setCursorPos(mx, my)
			term.blit(tostring(p), "f", tostring(c))
			table.insert(g, {mx, my})
			p = p + 1
		end
	end
	return "{" .. (g[2][1] - g[1][1] + 1) .. "," .. (g[2][2] - g[1][2] + 1) .. "}"
end

function Util.sortMinMax(v1, v2)
	return math.min(v1, v2), math.max(v1, v2)
end

function Util.percentToDecimal(s)
	local numeric = string.match(s, "[%d%.]+")
	return tonumber(numeric) / 100.0
end

function Util.readMeasure(c)
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	local s = self:measure(c)
	term.setCursorPos(1, c)
	term.write(s)
end

function Util.transferAttributes(t, target, values)
	for i = 1, #t do t[i][target] = values[i] end
end

function Util.addScalarToAttributes(t, target, value)
	for i = 1, #t do t[i][target] = t[i][target] + value end
end

function Util.waitClick()
	os.pullEvent("mouse_click")
end