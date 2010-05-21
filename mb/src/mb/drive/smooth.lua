local commandqueue = require "mb.drive.commandqueue"
local control = require "mb.control"
local task = require "cbclua.task"
local math = require "math"

Smooth = create_class "Smooth"

local SmoothSetSpeedCommand
local SmoothWaitDistanceCommand
local SmoothSetSpeedDistanceCommand

local calc_accels_stoptime

function Smooth:construct(args)
	self.accel = args.accel or 15
end

function Smooth:waitDistance(ldist, rdist)
	return SmoothWaitDistanceCommand(ldist, rdist)
end

function Smooth:setSpeed(lspeed, rspeed)
	return SmoothSetSpeedCommand(lspeed, rspeed, self.accel)
end

SmoothSetSpeedCommand = create_class "SmoothSetSpeedCommand"

function SmoothSetSpeedCommand:construct(lspeed, rspeed, accel)
	self.lspeed = lspeed
	self.rspeed = rspeed
	self.accel = accel
end

function SmoothSetSpeedCommand:prepare(topstate)
	self.lstartspeed = topstate.lspeed or 0
	self.rstartspeed = topstate.rspeed or 0
	local ldelta = self.lspeed - self.lstartspeed
	local rdelta = self.rspeed - self.rstartspeed
	self.laccel, self.raccel, self.stoptime = calc_accels_stoptime(ldelta, rdelta, self.accel)
	topstate.lspeed = self.lspeed
	topstate.rspeed = self.rspeed
end

function SmoothSetSpeedCommand:alterQueue(queue, queuetopstate)
	local top = #queue
	local topcommand = queue[top]
	if is_a(topcommand, SmoothSetSpeedCommand) then
		queue[top] = self
		return true
	end
	
	if is_a(topcommand, SmoothWaitDistanceCommand) then
		queue[top] = SmoothSetSpeedDistanceCommand(self.lspeed, self.rspeed, self.accel, topcommand.ldist, topcommand.rdist)
		return true
	end
end

function SmoothSetSpeedCommand:run(drivetrain)
	control.cycle(10, function (tdelta)
		if tdelta >= self.stoptime then return true end
		
		drivetrain:drive(self.lstartspeed + self.laccel*tdelta, self.rstartspeed + self.raccel*tdelta)   
	end)
	
	drivetrain:drive(self.lspeed, self.rspeed)
end

SmoothWaitDistanceCommand = create_class "SmoothWaitDistanceCommand"

function SmoothWaitDistanceCommand:construct(ldist, rdist)
	self.ldist = ldist
	self.rdist = rdist
end

function SmoothWaitDistanceCommand:prepare(topstate)
end

function SmoothWaitDistanceCommand:alterQueue(queue)
	local topcommand = queue[#queue]
	
	if is_a(topcommand, SmoothWaitDistanceCommand) then
		topcommand.ldist = topcommand.ldist + self.ldist
		topcommand.rdist = topcommand.rdist + self.rdist
		return true
	end
	
	if is_a(topcommand, SmoothSetSpeedCommand) then
		local time = topcommand.stoptime
		self.ldist = self.ldist - math.abs(.5 * topcommand.laccel * time * time + topcommand.lstartspeed * time)
		self.rdist = self.rdist - math.abs(.5 * topcommand.raccel * time * time + topcommand.rstartspeed * time)
	end
end

function SmoothWaitDistanceCommand:run(drivetrain)
	local lstartenc, rstartenc = drivetrain:getEncoders()
	
	while true do
		drivetrain:waitEncoders()
		
		local lenc, renc = drivetrain:getEncoders()
		if math.abs(lenc - lstartenc) > self.ldist or math.abs(renc - rstartenc) > self.rdist then
			return
		end
	end
end

SmoothSetSpeedDistanceCommand = create_class "SmoothSetSpeedDistanceCommand"

function SmoothSetSpeedDistanceCommand:construct(left, right, accel, ldist, rdist)
	self.left = left
	self.right = right
	self.accel = accel
	self.ldist = ldist
	self.rdist = rdist
end

function SmoothSetSpeedDistanceCommand:prepare(topstate)
	topstate.lspeed = self.left
	topstate.rspeed = self.right
end

function SmoothSetSpeedDistanceCommand:alterQueue(queue)
end

function SmoothSetSpeedDistanceCommand:run(drivetrain)
	local lstartspeed, rstartspeed = drivetrain:getSpeeds()
	local ldeltaspeed, rdeltaspeed = self.left - lstartspeed, self.right - rstartspeed	
	local laccel, raccel, stoptime = calc_accels_stoptime(ldeltaspeed, rdeltaspeed, self.accel)
	
	--distance until we start accelerating or deaccelerating
	local lstartdist = self.ldist - math.abs(.5*laccel*stoptime*stoptime + lstartspeed*stoptime)
	local rstartdist = self.rdist - math.abs(.5*raccel*stoptime*stoptime + rstartspeed*stoptime)
	
	local lstartenc, rstartenc = drivetrain:getEncoders()
	while true do
		drivetrain:waitEncoders()
		
		local lenc, renc = drivetrain:getEncoders()
		if math.abs(lenc - lstartenc) > lstartdist or math.abs(renc - rstartenc) > rstartdist then
			break
		end
	end
	
	local laccelenc, raccelenc = drivetrain:getEncoders()
	while true do
		drivetrain:waitEncoders()
		
		local lenc, renc = drivetrain:getEncoders()
		local trav = (lenc - laccelenc)
		local ltemp = 2*laccel*trav + lstartspeed*lstartspeed
		local lspeed = math.sqrt(math.abs(ltemp))
		if (ltemp < 0 and lstartspeed > 0) or (ltemp > 0 and lstartspeed < 0) then
			break
		end
		
		local rtemp = 2*raccel*trav + rstartspeed*rstartspeed
		local rspeed = math.sqrt(math.abs(rtemp))
		if (rtemp < 0 and rstartspeed > 0) or (rtemp > 0 and rstartspeed < 0) then
			break
		end
	
		drivetrain:drive(lspeed, rspeed)
	end
	
	drivetrain:drive(self.left, self.right)
end

----------------------------

function calc_accels_stoptime(leftdelta, rightdelta, accel)
	local leftaccel, rightaccel
	if leftdelta == 0 and rightdelta == 0 then
		return 0, 0, 0
	elseif leftdelta == 0 then
		leftaccel = 0
		rightaccel = accel
	elseif rightdelta == 0 then
		rightaccel = 0
		leftaccel = accel
	elseif math.abs(leftdelta) > math.abs(rightdelta) then
		leftaccel = accel
		rightaccel = math.abs(accel / leftdelta * rightdelta)
	else
		leftaccel = math.abs(accel / rightdelta * leftdelta)
		rightaccel = accel
	end
	
	if leftdelta < 0 then
		leftaccel = -leftaccel
	end
	if rightdelta < 0 then
		rightaccel = -rightaccel
	end
	
	local stoptime
	if leftaccel ~= 0 then
		stoptime = leftdelta / leftaccel
	else
		stoptime = rightdelta / rightaccel
	end
	stoptime = math.abs(stoptime)
	
	return leftaccel, rightaccel, stoptime
end

