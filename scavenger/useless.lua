import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local math = require "math"
local compactor = require "compactor"
local grabs = require "grabs"
local motion = require "motion"
local camera = require "camera"

function check_if_decreasing(final_reading, stop_at)
	local yes = 0
	
	print("final reading: " .. final_reading)
	for x = 1, stop_at, 1 do --will do as many times as w/e value stop_at is
		if rrange() < final_reading then
			yes = yes + 1
		end
		print("false")
	end
	
	print("yes: " .. yes)
	
	if yes == stop_at then
		return true
	else
		return false
	end
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
			
			print("sum: " .. sum)
			
			avg = (math.abs(sum)) / num
			
			print("avg: " .. avg)
			print("value: " ..  value)
			
			if avg >= 450 and avg < value then
				if check_if_decreasing(value, 4) then
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

--[[function goto_pvc_island()
	local passed_corner, val = task.timeout(6.5, function() return motion.drive_to_corner(5) end) --need jeff's help to determine real time
	drive:off()
	
	if passed_corner then
		if val >= 450 and val < 600 then
			drive:rturn{degrees = 45}
			
			if block == true then 
				drive:fd{inches = 24}
			else
				drive:fd{inches = 26}
			end
		elseif val >= 600 then
			drive:fd{inches = 1}
			drive:rturn{degrees = 47}
			
			if block == true then 
				drive:fd{inches = 22}
			else
				drive:fd{inches = 24}
			end
		end
	else
		print("time has passed")
		drive:rturn{degrees = 47}
		if block == true then
			drive:fd{inches = 24}
		else
			drive:fd{inches = 26}
		end
	end]]--










--this is just for fun right now
function larc(args) --but the right wheel has the higher speed
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

function rarc(args) --but the right wheel has the higher speed
	local lspeed = parse_vel(args)
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
	
	local rdist, ldist = a, b
	local rspeed = lspeed * (rdist/ldist)
	
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