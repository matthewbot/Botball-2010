local motorutils = require 'mb.motorutils'
local task = require 'cbclua.task'
local math = require 'math'

MotorDriveTrain = create_class("MotorDriveTrain")

function MotorDriveTrain:construct(args)
	self.lmot = assert(args.lmot, "Missing lmot argument!")
	self.rmot = assert(args.rmot, "Missing rmot argument!")
	self.lticks = assert(args.ticks, "Missing ticks argument!")
	self.rticks = self.lticks * (args.rmult or 1)
	self.wb = assert(args.wb, "Missing wb argument")
	self.encdelay = args.encdelay or 1/40
	
	self.lspeed, self.rspeed = 0, 0
end

function MotorDriveTrain:drive(lspeed, rspeed)
	self.lspeed, self.rspeed = lspeed, rspeed

	lspeed = math.round(lspeed * self.lticks)
	rspeed = math.round(rspeed * self.rticks)
	
	motorutils.dual_mav(self.lmot, lspeed, self.rmot, rspeed)
	if lspeed == 0 then
		self.lmot:off()
	end
	if rspeed == 0 then
		self.rmot:off()
	end
end

function MotorDriveTrain:driveDist(lspeed, ldist, rspeed, rdist)
	assert(ldist > 0, "negative ldist!")
	assert(rdist > 0, "negative rdist!")

	self.lspeed, self.rspeed = lspeed, rspeed

	lspeed = lspeed * self.lticks
	rspeed = rspeed * self.rticks
	ldist = ldist * self.lticks
	rdist = rdist * self.rticks
	
	if lspeed ~= 0 and rspeed ~= 0 then
		motorutils.dual_mrp(self.lmot, lspeed, ldist, self.rmot, rspeed, rdist)
	elseif lspeed ~= 0 then
		self.lmot:mrp(lspeed, ldist)
	else
		self.rmot:mrp(rspeed, rdist)
	end
end

function MotorDriveTrain:getWheelBase()
	return self.wb
end

function MotorDriveTrain:getEncoders()
	return self.lmot:getpos() / self.lticks, self.rmot:getpos() / self.rticks
end

function MotorDriveTrain:waitEncoders()
	task.sleep(self.encdelay)
end

function MotorDriveTrain:getSpeeds()
	return self.lspeed, self.rspeed
end

