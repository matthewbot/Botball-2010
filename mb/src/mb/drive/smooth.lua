local control = require "mb.control"
local math = require "math"

local calc_accels_stoptime
Smooth = create_class "Smooth"

function Smooth:construct(args)
	self.accel = args.accel or 10
end

function Smooth:set_vel(drivetrain, lendspeed, rendspeed, args)
	print("endspeed", lendspeed, rendspeed)
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
	local lstartenc, rstartenc = drivetrain:get_encoders()
	self:set_vel(drivetrain, ltravspeed, rtravspeed, args)
	
	print("dist", ldist, rdist)
	
	local accel = args.accel or self.accel
	local laccel, raccel, stoptime = calc_accels_stoptime(-ltravspeed, -rtravspeed, accel)
	local ldeacceldist = ldist - (.5*laccel*stoptime*stoptime + ltravspeed*stoptime)
	local rdeacceldist = rdist - (.5*raccel*stoptime*stoptime + rtravspeed*stoptime)
	
	print("deacceldist", ldeacceldist, rdeacceldist)
	
	while true do
		drivetrain:wait_encoders()
		
		local lenc, renc = drivetrain:get_encoders()
		if math.abs(lenc - lstartenc) > math.abs(ldeacceldist) or math.abs(renc - rstartenc) > math.abs(rdeacceldist) then
			break
		end
	end
	
	print("Deaccel")
	local ldeaccelenc, rdeaccelenc = drivetrain:get_encoders()
	control.cycle(50, function (tdelta)
		local lenc, renc = drivetrain:get_encoders()
		
		local ltrav = (lenc - ldeaccelenc)
		local ltemp = 2*laccel*ltrav + ltravspeed*ltravspeed
		if ltemp < 0 then return true end
		local lspeed = math.keepsgn(math.sqrt(ltemp), ltravspeed)

		local rtrav = (renc - rdeaccelenc)
		local rtemp = 2*raccel*rtrav + rtravspeed*rtravspeed
		if rtemp < 0 then return true end
		local rspeed = math.keepsgn(math.sqrt(rtemp), rtravspeed)
		
		print("temp", ltemp, rtemp)
		drivetrain:drive(lspeed, rspeed)
	end)
	print("Done")
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


