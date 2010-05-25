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

function FixMotor:dual_mav(speed, othermot, otherspeed)
	if not is_a(othermot, FixMotor) then
		return false
	end
	
	self:update_realpos()
	othermot:update_realpos()
	dualtoggle = not dualtoggle
	if dualtoggle then
		Motor.mav(self, speed*weirdfactor)
		othermot:mav_direct(otherspeed)
	else
		othermot:mav_direct(otherspeed)
		Motor.mav(self, speed*weirdfactor)
	end
	
	return true
end

function FixMotor:mav_direct(speed)
	return Motor.mav(self, speed*weirdfactor)
end

function FixMotor:dual_mrp(speed, dist, othermot, otherspeed, otherdist)
	if not is_a(othermot, FixMotor) then
		return false
	end
	
	self:update_realpos()
	othermot:update_realpos()
	dualtoggle = not dualtoggle
	if dualtoggle then
		Motor.mrp(speed, dist)
		othermot:mrp_direct(self, otherspeed, otherdist)
	else
		othermot:mrp_direct(self, otherspeed, otherdist)	
		Motor.mrp(speed, dist)
	end
end

function FixMotor:mrp_direct(speed, dist)
	return Motor.mrp(self, speed, dist)
end
	
function FixMotor:dual_mtp(speed, dist, othermot, otherspeed, otherdist)
	if not is_a(othermot, FixMotor) then
		return false
	end
	
	self:update_realpos()
	othermot:update_realpos()
	dist = dist - self.realpos
	otherdist = otherdist - othermot.realpos
	dualtoggle = not dualtoggle
	if dualtoggle then
		Motor.mtp(speed, dist)
		othermot:mtp_direct(self, otherspeed, otherdist)
	else
		othermot:mtp_direct(self, otherspeed, otherdist)	
		Motor.mtp(speed, dist)
	end
end

function FixMotor:mtp_direct(speed, dist)
	return Motor.mtp(self, speed, dist)
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
	dual_mav(self.mot1, speed, self.mot2, speed)
end

function DualMotor:mrp(speed, dist)
	dual_mrp(self.mot1, speed, dist, self.mot2, speed, dist)
end

function DualMotor:mtp(speed, dist)
	dual_mtp(self.mot1, speed, dist, self.mot2, speed, dist)
end

--[[ dual_ motor commands ]]--
-- Attempts to perform motor commands at the exact same instant
-- Only works with FixMotor, and does all motor counter manipulation before the commands
-- to get rid of a slight startup delay

function dual_mav(mot1, speed1, mot2, speed2)
	if mot1.dual_mav and mot1:dual_mav(speed1, mot2, speed2) then
		return
	end
	
	mot1:mav(speed1)
	mot2:mav(speed2)
end

function dual_mrp(mot1, speed1, dist1, mot2, speed2, dist2)
	if mot1.dual_mrp and mot1:dual_mrp(speed1, dist1, mot2, speed2, dist2) then
		return
	end
	
	mot1:mrp(speed1, dist1)
	mot2:mrp(speed2, dist2)
end

function dual_mtp(mot1, speed1, dist1, mot2, speed2, dist2)
	if mot1.dual_mtp and mot1:dual_mtp(speed1, dist1, mot2, speed2, dist2) then
		return
	end
	
	mot1:mtp(speed1, dist1)
	mot2:mtp(speed2, dist2)
end
