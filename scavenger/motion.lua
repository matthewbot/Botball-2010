import "config"

local task = require "cbclua.task"
local math = require "math"
local compactor = require "compactor"

function drive_sensor(side, dir, wait_for, speed, value)
	if side == "left" then
		if dir == "fd" then
			drive:fd{speed = speed}
		elseif dir == "bk" then
			drive:bk{speed = speed}
		end
		
		if wait_for == "pvc" then
			task.wait(function () return lrange() > value end)
		elseif wait_for == "no_pvc" then
			task.wait(function () return lrange() < value end)
		end
		
		--drive:off{}
	elseif side == "right" then
		if dir == "fd" then
			drive:fd{speed = speed}
		elseif dir == "bk" then
			drive:bk{speed = speed}
		end
		
		if wait_for == "pvc" then
			task.wait(function () return rrange() > value end)
		elseif wait_for == "no_pvc" then
			task.wait(function () return rrange() < value end)
		end
		
		--drive:off{}
	end
	
	drive:off()
end