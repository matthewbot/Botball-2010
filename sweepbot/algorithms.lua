import "config"
import "arm"

--!!! Algorithms file is for any functions mainly regarding sensor use

local task = require "cbclua.task"
local vision = require "cbclua.vision"
local math = require "math"

local turntime_constant = 1

function get_poms()								-- we dont use it... but it looks for palms
	vision.update()
	local a = green_channel[0]
	local b = green_channel[1]
	
	if a.size < 50 then
		return false
	elseif b.size < 50 then
		return a.x_float
	else
		return (a.x_float + b.x_float)/2
	end
end

function face_poms()									-- faces palms
	local poms = get_poms()
	if not poms then return false end
	
	local turntime = math.abs(poms) * turntime_constant
	if poms > 0 then
		drive:rturn{time=turntime, speed=200}
	else
		drive:lturn{time=turntime, speed=200}
	end	
end


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

function follow_wall_time(time)							-- does "follow wall()" but with a time out
	task.timeout(time, function()
		while true do
			follow_wall()
		end
	end)
	drive:stop{}
end

function follow_wall_sensor()									--does Follow_wall() until sensor if pushed
	while not rwall_bumper() do
		follow_wall()
	end
	drive:off()
end


function drive_bump()												-- drives until sensor is pushed
	drive:fd{wait=rwall_bumper, speed=500}
end

function final_palm_lineup()								-- does the fancy little scooch thing to lineup to get botguy and the second palms pile
	drive:bk{speed=200, inches=1}
	drive:scooch{xdist=-1, dir="bk"}
	drive:fd{wait=rwall_bumper, speed=600}
	drive:bk{inches=1}
	drive:off()
end

function either_bumper()								-- drives until either bumper is pushed
	return lwall_bumper() or rwall_bumper()
end

function both_bumpers()								-- drives until both bumpers are pushed
	return lwall_bumper() and rwall_bumper()
end

function wall_lineup_bumpers()						-- does a lineup on both bumpers
	print "running into wall"
	local first = true
	while true do
		if first then
			first = false
			bdrive:fd{speed=400}
		else
			bdrive:fd{speed=200}
		end
		task.wait(either_bumper)
		local lbump, rbump = lwall_bumper(), rwall_bumper()
		if (lbump and not rbump) or (rbump and not lbump) then -- either bumper but not both
			task.wait(both_bumpers, .1)
			lbump, rbump = lwall_bumper(), rwall_bumper()
		end
		
		if lbump and rbump then
			break
		elseif lbump then
			bdrive:lpiv{speed=-200, wait_while=lwall_bumper}
		elseif rbump then
			bdrive:rpiv{speed=-200, wait_while=rwall_bumper}
		end
	end
	print "hit wall"
	bdrive:stop{}
end

function drive_wall_follow()								-- a function we didnt end up using that follows a side wall (dont even have a sensor for it)
	task.timeout(time, function()
		while true do
			dist = wall_range()
			if dist < 150 and dist > 100 then
				drivetrain:drive(4, 4)
			elseif dist > 150 then
				drivetrain:drive(4, 3)
			else
				drivetrain:drive(3, 4)
			end
			task.sleep(0.01)
		end
	end)
end

function drive_wall()								-- drives to either bumper
	drive:fd{}
	task.wait(either_bumper)
	drive:off()
end

function lineup_first_palm_sweep()												-- does a lineup to sweep for the first palm pile
	drive:bk{speed=200, wait=function () return platform_range_sensor() > 700 end}
end
	