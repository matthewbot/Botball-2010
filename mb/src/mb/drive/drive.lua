local commandqueue = require "mb.drive.commandqueue"
local util = require "cbclua.util"
local task = require "cbclua.task"
local math = require "math"

Drive = create_class "Drive"

function Drive:construct(args)
	self.drivetrain = assert(args.drivetrain, "Missing argument drivetrain")
	self.style = assert(args.style, "Missing argument style")
	self.topspeed = args.topspeed or 10
	
	self.queue = commandqueue.CommandQueue(self.drivetrain)
end

function Drive:fd(args)
	local speed = self:getSpeed(args)
	local inches = args.inches
	local stop_func = args.stop_func

	self:setSpeed(speed, speed)
	if inches then
		self:waitDistance(inches, inches)
		self:stop()
	elseif stop_func then
		self:waitFunc(stop_func)
		self:stop()
	end
end

function Drive:bk(args)
	args.speed = -self:getSpeed(args)
	
	return self:fd(args)
end

function Drive:lturn(args)
	local speed = self:getSpeed(args)
	local rad = self:getRad(args)
	local stop_func = args.stop_func
	
	self:setSpeed(-speed, speed)
	
	if rad then
		local inches = rad * self.drivetrain:getWheelBase()/2
		self:waitDistance(inches, inches)
		self:stop()
	elseif stop_func then
		self:waitFunc(stop_func)
		self:stop()
	end
end

function Drive:rturn(args)
	args.speed = -self:getSpeed(args)
	
	return self:lturn(args)
end

function Drive:steer(dir, speed)
	local lmult, rmult
	
	if dir >= 0 then
		lmult = 1
		rmult = 1-dir*2
	else
		lmult = 1+dir*2
		rmult = 1
	end
	
	self:setSpeed(lmult*speed, rmult*speed)
end

--[[function Drive:lpiv(args)
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

function Drive:rpiv(args)
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

function Drive:scooch(xdist)
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
end]]

function Drive:stop()
	self:setSpeed(0, 0)
end

function Drive:wait()
	return self.queue:wait()
end

-- Util functions --

function Drive:getSpeed(args)
	if args.speed then
		return args.speed
	elseif args.power then
		return args.topspeed * args.power / 100
	else
		return self.topspeed
	end
end

function Drive:getRad(args)
	if args.degrees then
		return math.rad(args.degrees)
	elseif args.radians then
		return args.radians
	end
end

-- Low level API --

function Drive:off()
	self.queue:clear()
	self.drivetrain:drive(0, 0)
end

function Drive:setSpeed(lspeed, rspeed)
	self.queue:add(self.style:setSpeed(lspeed, rspeed))
end

function Drive:waitDistance(ldist, rdist)
	self.queue:add(self.style:waitDistance(ldist, rdist))
end

function Drive:waitTime(time)
	self.queue:add(commandqueue.SleepCommand(time))
end

function Drive:waitFunc(func)
	self.queue:add(commandqueue.InlineCommand(function ()
		return task.wait(func)
	end))
end

