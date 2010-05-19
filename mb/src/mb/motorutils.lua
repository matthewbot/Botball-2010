local cbc = require "cbclua.cbc"

--[[ JerkFixMotor ]]--
-- Fixes integral windup jerks when changing directions
-- clears physical motor counters between every BEMF command to insure integrator is reset
-- maintains accurate logical motor counters

local Motor = cbc.Motor -- superclass abbreviation
JerkFixMotor = create_class("JerkFixMotor", Motor)

function JerkFixMotor:construct(args)
	Motor.construct(self, args)
	self.realpos = Motor.getpos(self)
	Motor.clearpos(self)
end

function JerkFixMotor:getpos()
	return self.realpos + Motor.getpos(self)
end

function JerkFixMotor:clearpos()
	self.realpos = 0
	return Motor.clearpos(self)
end

function JerkFixMotor:update_realpos()
	self.realpos = self.realpos + Motor.getpos(self)
	return Motor.clearpos(self)
end

function JerkFixMotor:mav(speed)
	self:update_realpos()
	return Motor.mav(self, speed)
end

function JerkFixMotor:mrp(speed, pos)
	self:update_realpos()
	return Motor.mrp(self, speed, pos)
end

function JerkFixMotor:mtp(speed, pos)
	self:update_realpos()
	pos = pos - self.realpos
	return Motor.mtp(self, speed, pos)
end

function JerkFixMotor:dual_mav(speed, othermot, otherspeed)
	if not is_a(othermot, JerkFixMotor) then
		return false
	end
	
	self:update_realpos()
	othermot:update_realpos()
	Motor.mav(self, speed)
	othermot:mav_direct(otherspeed)
	
	return true
end

function JerkFixMotor:mav_direct(speed)
	return Motor.mav(self, speed)
end

function JerkFixMotor:dual_mrp(speed, dist, othermot, otherspeed, otherdist)
	if not is_a(othermot, JerkFixMotor) then
		return false
	end
	
	self:update_realpos()
	othermot:update_realpos()
	Motor.mrp(speed, dist)
	othermot:mrp_direct(self, otherspeed, otherdist)
end

function JerkFixMotor:mrp_direct(speed, dist)
	return Motor.mrp(self, speed, dist)
end
	
function JerkFixMotor:dual_mtp(speed, dist, othermot, otherspeed, otherdist)
	if not is_a(othermot, JerkFixMotor) then
		return false
	end
	
	self:update_realpos()
	othermot:update_realpos()
	dist = dist - self.realpos
	otherdist = otherdist - othermot.realpos
	Motor.mtp(self, speed, dist)
	othermot:mtp_direct(otherspeed, otherdist)
end

function JerkFixMotor:mtp_direct(speed, dist)
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
-- Only works with JerkFixMotor, and does all motor counter manipulation before the commands
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
