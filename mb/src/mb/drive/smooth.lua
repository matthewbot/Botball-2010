local control = require "mb.control"
local math = require "math"

local calc_accels_stoptime
Smooth = create_class "Smooth"

function Smooth:construct(args)
	self.accel = args.accel or 10
end

function Smooth:set_vel(drivetrain, lendspeed, rendspeed, args)
	local lstartspeed, rstartspeed = drivetrain:get_speeds()
	local ldeltaspeed = lendspeed - lstartspeed
	local rdeltaspeed = rendspeed - rstartspeed
	local accel = args.accel or self.accel
	local laccel, raccel, stoptime = calc_accels_stoptime(ldeltaspeed, rdeltaspeed, self.accel)
	
	control.cycle(50, function (tdelta)
		if tdelta >= stoptime then return true end
	
		local lspeed = lstartspeed + tdelta * laccel
		local rspeed = rstartspeed + tdelta * raccel
		drivetrain:drive(lspeed, rspeed)
	end)
	
	drivetrain:drive(lendspeed, rendspeed)
end

function Smooth:set_vel_dist(drivetrain, ltravspeed, ldist, rtravspeed, rdist, args)
	assert(math.sgn(ltravspeed) == math.sgn(ldist), "Distance and speed must be the same sign!")
	assert(math.sgn(rtravspeed) == math.sgn(rdist), "Distance and speed must be the same sign!")

	local lstartenc, rstartenc = drivetrain:get_encoders()
	self:set_vel(drivetrain, ltravspeed, rtravspeed, args)
	
	local accel = args.accel or self.accel
	local laccel, raccel, stoptime = calc_accels_stoptime(-ltravspeed, -rtravspeed, accel)
	local ldeacceldist = ldist - (.5*laccel*stoptime*stoptime + ltravspeed*stoptime)
	local rdeacceldist = rdist - (.5*raccel*stoptime*stoptime + rtravspeed*stoptime)
	
	while true do
		drivetrain:wait_encoders()
		
		local lenc, renc = drivetrain:get_encoders()
		if ltravspeed ~= 0 and math.abs(lenc - lstartenc) > math.abs(ldeacceldist) then
			break
		end
		if rtravspeed ~= 0 and math.abs(renc - rstartenc) > math.abs(rdeacceldist) then
			break
		end
	end
	
	local ldeaccelenc, rdeaccelenc = drivetrain:get_encoders()
	control.cycle(50, function (tdelta)
		local lenc, renc = drivetrain:get_encoders()
		
		local lspeed
		if ltravspeed ~= 0 then
			local ltrav = (lenc - ldeaccelenc)
			local ltemp = 2*laccel*ltrav + ltravspeed*ltravspeed
			if ltemp < 0 then return true end
			lspeed = math.keepsgn(math.sqrt(ltemp), ltravspeed)
		else
			lspeed = 0
		end

		local rspeed
		if rtravspeed ~= 0 then
			local rtrav = (renc - rdeaccelenc)
			local rtemp = 2*raccel*rtrav + rtravspeed*rtravspeed
			if rtemp < 0 then return true end
			rspeed = math.keepsgn(math.sqrt(rtemp), rtravspeed)
		else
			rspeed = 0
		end
		
		drivetrain:drive(lspeed, rspeed)
	end)
	drivetrain:drive(0, 0)
end

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


