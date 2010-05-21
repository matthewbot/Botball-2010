local commandqueue = require "mb.drive.commandqueue"
local math = require "math"

BangBang = create_class "BangBang"
local BangBangSetSpeedCommand
local BangBangWaitDistanceCommand

function BangBang:setSpeed(lspeed, rspeed)
	return BangBangSetSpeedCommand(lspeed, rspeed)
end

function BangBang:waitDistance(ldist, rdist)
	return BangBangWaitDistanceCommand(ldist, rdist)
end

BangBangSetSpeedCommand = create_class "BangBangSetSpeedCommand"

function BangBangSetSpeedCommand:construct(lspeed, rspeed)
	self.lspeed = lspeed
	self.rspeed = rspeed
end

function BangBangSetSpeedCommand:prepare(topstate)
	topstate.lspeed = self.lspeed
	topstate.rspeed = self.rspeed
end

function BangBangSetSpeedCommand:alterQueue(queue)
end

function BangBangSetSpeedCommand:run(drivetrain)
	drivetrain:drive(self.lspeed, self.rspeed)
end

BangBangWaitDistanceCommand = create_class "BangBangWaitDistanceCommand"

function BangBangWaitDistanceCommand:construct(ldist, rdist)
	self.ldist = ldist
	self.rdist = rdist
end

function BangBangWaitDistanceCommand:prepare(topstate)
end

function BangBangWaitDistanceCommand:alterQueue(queue)
	local topcommand = queue[#queue]
	
	if is_a(topcommand, BangBangWaitDistanceCommand) then
		topcommand.ldist = topcommand.ldist + self.ldist
		topcommand.rdist = topcommand.rdist + self.rdist
		return true
	end
end

function BangBangWaitDistanceCommand:run(drivetrain)
	local lstartenc, rstartenc = drivetrain:getEncoders()
	
	while true do
		drivetrain:waitEncoders()
		
		local lenc, renc = drivetrain:getEncoders()
		if math.abs(lenc - lstartenc) > self.ldist or math.abs(renc - rstartenc) > self.rdist then
			return
		end
	end
end

