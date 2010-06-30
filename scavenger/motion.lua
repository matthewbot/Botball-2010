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

function check_if_decreasing(final_reading, stop_at)
	local yes = 0
	
	for x = 1, stop_at, 1 do --will do as many times as w/e value stop_at is
		if rrange() < final_reading then
			yes = yes + 1
		end
	end
	
	if yes == stop_at then
		return true
	else
		return false
end

--need to add a way to check its decreasing for a while
function drive_to_corner(num)-- use corner_check w/ driving now.  if > 500 and < 700, just turn and move more than usual elseif > 700 do what we have been doing
	local readings = {}
	local value = rrange()
	local index, sum, avg = 1, 0, 0
	
	drive:fd{speed = 800}
	while true do
		task.yield()
		readings[index] = rrange()
	
		print("reading: " .. readings[index] .. " and index: " .. index)
		
		if index == num then
			index, sum, avg = 1, 0, 0
			
			for k, v in pairs(readings) do
				sum = sum + v
			end
			
			print("sum" .. sum)
			
			avg = (math.abs(sum)) / num
			
			print("avg" .. avg)
			print("value" ..  value)
			
			if avg >= 500 and avg < value then
				if check_if_decreasing(value, 3) then
					drive:off()
					print("value returned:" .. value)
					return value
				end
				print("there was a spike, not a true decrease")
			end
		end
		
		index = index + 1
		value = rrange()
	end
end

function drive_bumper() --need to create when bumpers are installed
	return 1
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

function larc_drive(args) --but the right wheel has the higher speed
	local rspeed = parse_vel(args)
	local radius = args.radius
	
	local wb = drivetrain:get_wheel_base()
	local a, b
	
	local rad = drive:parse_radians(args)
	
	if rad then
		a = radius * rad
		b = (radius + wb) * rad
	else
		a = radius
		b = radius + wb
	end
	
	local ldist, rdist = a, b
	local lspeed = rspeed * (ldist/rdist)
	
	if rad then
		drivetrain:drive_dist(lspeed, ldist, rspeed, rdist)
	else
		drivetrain:drive(lspeed, rspeed)
	end
end

function parse_vel(args)
	if args.speed then
		return args.speed / 1000 * 8
	elseif args.vel then
		return args.vel
	else
		return 8
	end
end