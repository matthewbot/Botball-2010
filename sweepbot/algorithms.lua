import "config"
import "arm"

--!!! Algorithms file is for any functions mainly regarding sensor use

local task = require "cbclua.task"
local vision = require "cbclua.vision"
local math = require "math"

function read_ranges()										-- reads our rangefinders for when we are wall following (the island)
	local left = lrange() > 550
	local right = rrange() > 550
	return left, right
end

function follow_wall()								-- follows top of island pvc
	local left, right = read_ranges()
	if not left and not right then
		drivetrain:drive(.5, 3) -- TODO add arcs!!!
	elseif left and not right then
		drivetrain:drive(4, 4)
	else
		drivetrain:drive(3, .5)
	end
	task.sleep(0.01)
end

function follow_wall_sensor()									--does Follow_wall() until sensor if pushed
	while not rwall_bumper() do
		follow_wall()
	end
	drive:off()
end

function final_palm_lineup()								-- does the fancy little scooch thing to lineup to get botguy and the second palms pile
	drive:bk{speed=200, inches=1}
	drive:scooch{xdist=-1, dir="bk"}
	drive:fd{wait=rwall_bumper, speed=600}
	drive:bk{inches=1}
	drive:off()
end

function drive_wall()								-- drives to either bumper
	drive:fd{}
	task.wait(either_bumper)
	drive:off()
end

function lineup_first_palm_sweep()												-- does a lineup to sweep for the first palm pile
	drive:bk{speed=200, wait=function () return platform_range_sensor() > 700 end}
end
	