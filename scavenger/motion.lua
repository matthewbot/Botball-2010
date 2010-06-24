import "config"

local task = require "cbclua.task"
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
		
		drive:off{}
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
		
		drive:off{}
	end
end

function drive_bumper() --need to create when bumpers are installed
	return 1
end

function turn(dir, degrees, speed)
	compactor.close()
	speed = speed or 1000
	
	if dir == "left" then
		drive:lturn{degrees = degrees, speed = speed}
	elseif dir == "right" then
		drive:rturn{degrees = degrees, speed = speed}
	end
	
	compactor.open()
end 

--this is just for fun right now

function arc(speed)
	drivetrain:drive_dist(speed, 3, (speed - 200), 5)
end

function startarc(diff, dist)
	drivetrain:drive_dist(10-diff, dist/2, 10, dist/2)
	drivetrain:drive_dist(10, dist/2, 10-diff, dist/2)
end

function arc_power(power)
	ldrive:mav(-power)
	rdrive:mav(-(power - 200))
end