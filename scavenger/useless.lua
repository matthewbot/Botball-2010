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
	
		if index == num then
			index, sum, avg = 1, 0, 0
			
			for k, v in pairs(readings) do
				sum = sum + v
			end
			
			avg = (math.abs(sum)) / num
			
			if avg >= 450 and avg < value then
				if check_if_decreasing(value, 4) then
					drive:off()
					return value
				end
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


--old camera functions for reference (changed find to locate for less confusion)
function locate_botguy()
	local cm = cm_red
		
	local once, min_x
	local k = 0
	local y_list, count_list = {}, {}	
	
	local image = camera.take_image(6)
	camera.dump_grid(cm, image)
	
	gip:processImage(image)
	
	for x=0,7 do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if x == 4 and y == 3 then
				print("skip")
			else
				if count > 30 then
					k = k + 1
					print("k: " .. k)
					y_list[k] = y
					count_list[k] = count
					
					if not once then
						min_x = x
						once = true
					end
				end
			end
		end
	end

	print("min_x: " .. tostring(min_x))
	local close = camera.check_closeness(y_list, count_list)
	
	return close, min_x	
end

function locate_tribbles()
	local cm = cm_green
		
	local k, max_x = 0
	local x_list = {}	
	
	local image = camera.take_image(6)
	--camera.dump_grid(cm, image)
	
	gip:processImage(image)
	
	for x=0,5 do
		for y=0,3 do
			local count = gip:getCount(x, y, cm)
			if x == 4 and y == 3 then
				print("skip")
			else
				if count > 20 then
					k = k + 1
					print("k: " .. k)
					x_list[k] = x
				end
			end
		end
	end

	print("max_x: " .. tostring(max_x))
	
	max_x = camera.return_highest(x_list)
	
	if max_x ~= 0 then
		return max_x
	end
	
	return nil
end






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