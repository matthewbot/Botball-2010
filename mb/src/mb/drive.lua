local util = require "cbclua.util"
local task = require "cbclua.task"
local math = require "math"

DriveBase = create_class "DriveBase"

--[[
This base class expects subclasses to implement the following two methods
drive(lspeed, rspeed) - run motors at specified speed
drive_dist(lspeed, dist, rspeed) - run motors at speed.
   - If lspeed ~= 0, stop when left wheel has traveled dist (signs with speed must match)
   - If lspeed == 0, stop when right wheel has traveled dist (signs with speed must match)
stop() - stop motors
]]

function DriveBase:fd(args)
	local speed = args.speed or 1000
	local inches = args.inches
	local stop_func = args.stop_func

	if inches then
		if inches > 0 then
			self:drive_dist(speed, inches, speed, args)
		else
			self:drive_dist(-speed, inches, -speed, args)
		end
	elseif stop_func then
		self:drive(speed, speed, args)
		task.wait(stop_func)
		self:stop()
	else
		self:drive(speed, speed, args)
	end
end

function DriveBase:bk(args)
	if args.inches then
		args.inches = -args.inches
	elseif args.speed then
		args.speed = -args.speed
	else
		args.speed = -1000
	end
	
	self:fd(args)
end

function DriveBase:lturn(args)
	local speed = args.speed or 1000
	local stop_func = args.stop_func
	local rad
	
	if args.degrees then
		rad = math.rad(args.degrees)
	elseif args.radians then
		rad = args.radians
	end
	
	if rad then
		local inches = rad * self:get_wheelbase()/2
		if inches > 0 then
			self:drive_dist(-speed, -inches, speed, args)
		else
			self:drive_dist(speed, -inches, -speed, args)
		end
	elseif stop_func then
		self:drive(-speed, speed, args)
		task.wait(stop_func)
		self:stop()
	else
		self:drive(-speed, speed, args)
	end
end

function DriveBase:rturn(args)
	if args.degrees then
		args.degrees = -args.degrees
	elseif args.radians then
		args.radians = -args.radians
	elseif args.speed then
		args.speed = -args.speed
	else
		args.speed = -1000
	end
	
	self:lturn(args)
end

function DriveBase:steer(dir, speed)
	local lmult, rmult
	
	if dir >= 0 then
		lmult = 1
		rmult = 1-dir*2
	else
		lmult = 1+dir*2
		rmult = 1
	end
	
	self:drive(lmult*speed, rmult*speed)
end

function DriveBase:lpiv(args)
	local speed = args.speed or 1000
	
	local rad
	if args.rad then
		rad = args.rad
	elseif args.degrees then
		rad = math.rad(args.degrees)
	end
	
	if rad then
		if rad > 0 then
			self:drive_dist(-speed, -rad * self:get_wheelbase(), 0, args)
		else
			self:drive_dist(speed, -rad * self:get_wheelbase(), 0, args)
		end
	else
		self:drive(speed, 0, args)
	end
end

function DriveBase:rpiv(args)
	local speed = args.speed or 1000

	local rad
	if args.rad then
		rad = args.rad
	elseif args.degrees then
		rad = math.rad(args.degrees)
	end
	
	if rad then
		if rad > 0 then
			self:drive_dist(0, rad * self:get_wheelbase(), speed, args)
		else
			self:drive_dist(0, rad * self:get_wheelbase(), -speed, args)
		end
	else
		self:drive(0, speed, args)
	end
end

function DriveBase:scooch(xdist)
	local wb = self:get_wheelbase()

	local rad = -math.acos((math.abs(xdist) - wb)/-wb)
	
	if xdist > 0 then
		self:lpiv{rad = rad}
		self:rpiv{rad = rad}
	else
		self:rpiv{rad = rad}
		self:lpiv{rad = rad}
	end
	
	return math.abs(math.sin(rad)*wb)
end

-- Not a public API
-- more of a Matt always seems to type this in a huge panic API

function DriveBase:off()
	self:stop()
end

