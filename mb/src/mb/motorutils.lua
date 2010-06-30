local cbc = require "cbclua.cbc"

--[[ FixMotor ]]--
-- Fixes integral windup jerks when changing directions
-- clears physical motor counters between every BEMF command to insure integrator is reset
-- maintains accurate logical motor counters

local Motor = cbc.Motor -- superclass abbreviation
FixMotor = create_class("FixMotor", Motor)

local weirdfactor = .88235
dualtoggle = false

function FixMotor:construct(args)
	Motor.construct(self, args)
	self.realpos = Motor.getpos(self)
	Motor.clearpos(self)
end

function FixMotor:getpos()
	return self.realpos + Motor.getpos(self)
end

function FixMotor:clearpos()
	self.realpos = 0
	return Motor.clearpos(self)
end

function FixMotor:update_realpos()
	self.realpos = self.realpos + Motor.getpos(self)
	return Motor.clearpos(self)
end

function FixMotor:mav(speed)
	return Motor.mav(self, speed*weirdfactor)
end

function FixMotor:mrp(speed, pos)
	return Motor.mrp(self, speed*weirdfactor, pos)
end

function FixMotor:off()
	self:update_realpos()
	return Motor.off(self)
end

function FixMotor:mtp(speed, pos)
	pos = pos - self.realpos
	return Motor.mtp(self, speed*weirdfactor, pos)
end

--[[ DualMotor ]]--

DualMotor = create_class "DualMotor"

function DualMotor:construct(mot1, mot2)
	self.mot1 = mot1
	self.mot2 = mot2
end

for _, func in ipairs{"fd", "bk", "off", "clearpos", "setpos", "getpos", "getpwm", "setpwm"} do
	DualMotor[func] = function (self, ...)
		local result1 = self.mot1[func](self.mot1, ...)
		local result2 = self.mot2[func](self.mot2, ...)
	
		return result1, result2
	end
end

function DualMotor:mav(speed)
	self.mot1:mav(speed)
	self.mot2:mav(speed)
end

function DualMotor:mrp(speed, dist)
	self.mot1:mrp(speed, dist)
	self.mot2:mrp(speed, dist)
end

function DualMotor:mtp(speed, dist)
	self.mot1:mtp(speed, dist)
	self.mot2:mtp(speed, dist)
end

