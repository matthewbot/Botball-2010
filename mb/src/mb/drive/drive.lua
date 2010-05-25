local util = require "cbclua.util"
local task = require "cbclua.task"
local math = require "math"

Drive = create_class "Drive"

function Drive:construct(args)
	self.drivetrain = assert(args.drivetrain, "Missing argument drivetrain")
	self.style = assert(args.style, "Missing style argument")
	self.topvel = args.topvel or 5
end

function Drive:fd(args)
	local vel = self:parse_velocity(args)
	local style = args.style or self.style

	local inches = args.inches
	if inches then
		style:set_vel_dist(self.drivetrain, vel, inches, vel, inches, args)
		return
	end
	
	style:set_vel(self.drivetrain, vel, vel, args)
	
	self:wait_time(args)
end

function Drive:bk(args)
	if args.inches then
		args.inches = -args.inches
	end
	self:flip_velocity(args)
	
	return self:fd(args)
end

function Drive:lturn(args)
	local vel = self:parse_velocity(args)
	local style = args.style or self.style
	
	local rad = self:parse_radians(args)
	if rad then
		local inches = rad * self.drivetrain:get_wheel_base()/2
		style:set_vel_dist(self.drivetrain, -vel, -inches, vel, inches, args)
		return
	end
	
	style:set_vel(self.drivetrain, -vel, vel, args)
	
	self:wait_time(args)
end

function Drive:rturn(args)
	self:flip_velocity(args)
	
	return self:lturn(args)
end

function Drive:lpiv(args)
	local vel = self:parse_velocity(args)
	local style = args.style or self.style
	
	local rad = self:parse_radians(args)
	if rad then
		local inches = rad * self.drivetrain:get_wheel_base()
		style:set_vel_dist(self.drivetrain, math.keepsgn(vel, inches), inches, 0, 0, args)
		return
	end
	
	style:set_vel(self.drivetrain, vel, 0, args)

	self:wait_time(args)
end

function Drive:rpiv(args)
	local vel = self:parse_velocity(args)
	local style = args.style or self.style
	
	local rad = self:parse_radians(args)
	if rad then
		local inches = rad * self.drivetrain:get_wheel_base()
		style:set_vel_dist(self.drivetrain, 0, 0, math.keepsgn(vel, inches), inches, args)
		return
	end
	
	style:set_vel(self.drivetrain, 0, vel, args)

	self:wait_time(args)
end

function Drive:scooch(args)
	local vel = self:parse_velocity(args)
	local xdist = assert(args.xdist, "Missing argument xdist to scooch method")

	local wb = self.drivetrain:get_wheel_base()

	local rad = math.acos((math.abs(xdist) - wb)/-wb)
	if args.dir == "bk" then
		rad = -rad
	end
	
	if xdist > 0 then
		self:lpiv{rad = rad, vel = vel}
		self:rpiv{rad = rad, vel = vel}
	else
		self:rpiv{rad = rad, vel = vel}
		self:lpiv{rad = rad, vel = vel}
	end
	
	return math.sin(rad)*wb
end

function Drive:stop(args)
	local style = args.style or self.style
	style:set_vel(self.drivetrain, 0, 0, args)
end

function Drive:off()
	self.drivetrain:off()
end

-- Util functions --

function Drive:parse_velocity(args)
	if args.speed then
		return args.speed / 1000 * self.topvel
	elseif args.vel then
		return args.vel
	else
		return self.topvel
	end
end

function Drive:flip_velocity(args)
	local vel = self:parse_velocity(args)
	args.vel = -vel
	args.speed = nil
end

function Drive:parse_radians(args)
	if args.degrees then
		return math.rad(args.degrees)
	elseif args.rad then
		return args.rad
	end
end

function Drive:wait_time(args)
	local wait = args.wait
	if wait then	
		task.wait(wait)
		self:stop(args)
		return
	end
	
	local wait_while = args.wait_while
	if wait_while then
		task.wait_while(wait_while)
		self:stop(args)
		return
	end
	
	local time = args.time
	if time then
		task.sleep(time)
		self:stop(args)
		return
	end
end
