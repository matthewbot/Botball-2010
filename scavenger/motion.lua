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

function corner_check()-- use corner_check w/ driving now.  if > 500 and < 700, just turn and move more than usual elseif > 700 do what we have been doing
	local readings = {}
	local value = rrange()
	
	local index, sum, avg = 0, 0, 0
	
	while true do
		reading[index] = rrange()
		index = index + 1
		
		if index == 2 then
			index, sum, avg = 0, 0, 0
			
			for v in pairs(readings) do
				sum = sum + v
			end
			
			avg = (math.abs(sum)) / 3
			
			if avg < value then
				return value
			end
		end
		
		value = rrange()
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
function arc(lspeed, ldist, ratio)
	drivetrain:drive_dist(lspeed, ldist, lspeed * ratio, ldist * ratio)
end

function startarc(diff, dist)
	drivetrain:drive_dist(10-diff, dist/2, 10, dist/2)
	drivetrain:drive_dist(10, dist/2, 10-diff, dist/2)
end

function arc_off()
	ldrive:off()
	rdrive:off()
end

function arc_mav(lvel, rvel)
	ldrive:mav(lvel)
	rdrive:mav(rvel)
end

function arc_power(lpower, rpower)
	ldrive:setpwm(lpower)
	rdrive:setpwm(rpower)
end