import "config"
import "arm"


local task = require "cbclua.task"
local vision = require "cbclua.vision"
local math = require "math"

local turntime_constant = 1

function get_poms()
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

function face_poms()
	local poms = get_poms()
	if not poms then return false end
	
	local turntime = math.abs(poms) * turntime_constant
	if poms > 0 then
		drive:rturn{time=turntime, speed=200}
	else
		drive:lturn{time=turntime, speed=200}
	end	
end


function read_ranges()
	local left = lrange() > 550
	local right = rrange() > 550
	return left, right
end

function follow_wall()
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

function follow_wall_time(time)
	task.timeout(time, function()
		while true do
			follow_wall()
		end
	end)
	drive:stop{}
end

function follow_wall_sensor()
	while not rwall_bumper() do
		follow_wall()
	end
	drive:off()
end


function drive_bump()
	drive:fd{wait=rwall_bumper, speed=100}
end

function final_palm_lineup()
	drive:bk{speed=200, inches=1}
	drive:scooch{xdist=-1.5, dir="bk"}
	drive:fd{wait=rwall_bumper, speed=200}
	drive:bk{inches=3}
	drive:off()
	
	
--[[	drive_motors(-300, -300)
	task.sleep(.3)
	drive_stop()
	local left, right = read_ranges()
	while not right do
		drive_motors(0, 200)
		left, right = read_ranges()
		task.sleep(.01)
	end
	drive_motors(100, 0)
	task.sleep(.5)
	drive_stop() ]]
end

function either_bumper()
	return lwall_bumper() or rwall_bumper()
end

function both_bumpers()
	return lwall_bumper() and rwall_bumper()
end

function wall_lineup_bumpers()
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

function drive_wall_follow()
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

function drive_wall()
	drive:fd{}
	task.wait(either_bumper)
	drive:off()
end