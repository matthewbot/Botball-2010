local motorutils = require 'mb.motorutils'
local task = require 'cbclua.task'
local userprgm = require 'cbclua.userprgm'
local util = require 'cbclua.util'
local math = require 'math'

MotorDriveTrain = create_class("MotorDriveTrain")

function MotorDriveTrain:construct(args)
	self.lmot = assert(args.lmot, "Missing lmot argument!")
	self.rmot = assert(args.rmot, "Missing rmot argument!")
	self.lticks = assert(args.ticks, "Missing ticks argument!")
	self.rticks = self.lticks * (args.rmult or 1)
	self.wb = assert(args.wb, "Missing wb argument")
	
	self.lspeed, self.rspeed = 0, 0
	
	userprgm.add_stop_hook(function ()
		self.lspeed = 0
		self.rspeed = 0
	end)
end

function MotorDriveTrain:drive(lspeed, rspeed)
	self.lspeed, self.rspeed = lspeed, rspeed

	lspeed = math.round(lspeed * self.lticks)
	rspeed = math.round(rspeed * self.rticks)
	
	if lspeed ~= 0 then
		self.lmot:mav(lspeed)
	else
		self.lmot:off()
	end
	
	if rspeed ~= 0 then
		self.rmot:mav(rspeed)
	else
		self.rmot:off()
	end
end

function MotorDriveTrain:drive_dist(lspeed, ldist, rspeed, rdist)
	assert(math.sgn(lspeed) == math.sgn(ldist), "Distance and speed must be the same sign!")
	assert(math.sgn(rspeed) == math.sgn(rdist), "Distance and speed must be the same sign!")
		
	if ldist < 0 then
		lspeed = -lspeed
	end
	if rdist < 0 then
		rspeed = -rspeed
	end

	self.lspeed, self.rspeed = lspeed, rspeed

	lspeed = lspeed * self.lticks
	rspeed = rspeed * self.rticks
	ldist = ldist * self.lticks
	rdist = rdist * self.rticks
	
	if lspeed ~= 0 then
		self.lmot:mrp(lspeed, ldist)
	end
	if rspeed ~= 0 then
		self.rmot:mrp(rspeed, rdist)
	end
	task.sleep(.02)
	
	self.lmot:wait()
	self.rmot:wait()
	
	self.lmot:off()
	self.rmot:off()
	
	self.lspeed, self.rspeed = 0, 0
end

function MotorDriveTrain:get_wheel_base()
	return self.wb
end

function MotorDriveTrain:get_encoders()
	return self.lmot:getpos() / self.lticks, self.rmot:getpos() / self.rticks
end

function MotorDriveTrain:wait_encoders()
	task.yield()
end

function MotorDriveTrain:get_speeds()
	return self.lspeed, self.rspeed
end

