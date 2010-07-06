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

function swirl(num, dir, radius, degrees, speed)
	radius = radius or 5
	degrees = degrees or 360
	local amt = radius / num
	
	while num >= 0 then
		arc{dir = dir, radius = radius, degrees = degrees, speed = speed}
		radius = radius - amt
		num = num - 1
	end
end

function arc(args)
	local dir = args.dir or "left"
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
	
	local ldist, rdist, lspeed, rspeed
	if dir == "left" then
		ldist, rdist = a, b
		rspeed = parse_vel(args)
		lspeed = rspeed * (ldist/rdist)
	else
		rdist, ldist = a, b
		lspeed = parse_vel(args)
		rspeed = lspeed * (rdist/ldist)
	end
	
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