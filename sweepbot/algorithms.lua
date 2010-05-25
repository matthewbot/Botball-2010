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
	while not wall_bumper() do
		follow_wall()
	end
	drive:off()
end


function drive_bump()
	drive:fd{wait=wall_bumper, speed=100}
end

function final_palm_lineup()
	drive:bk{speed=200, inches=1}
	drive:scooch{xdist=-.5, dir="bk"}
	drive:fd{speed=200, inches=.5}
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
