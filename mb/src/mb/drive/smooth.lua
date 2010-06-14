local control = require "mb.control"
local math = require "math"
local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local timer = require "cbclua.timer"

--local calc_accels_stoptime
Smooth = create_class "Smooth"

function Smooth:construct(args)
	self.accel = args.accel or 10
end

function Smooth:set_vel(drivetrain, lendspeed, rendspeed, args)
	local lstartspeed, rstartspeed = drivetrain:get_speeds()
	local ldeltaspeed = lendspeed - lstartspeed
	local rdeltaspeed = rendspeed - rstartspeed
	local accel = args.accel or self.accel
	local laccel, raccel, stoptime = calc_accels_stoptime(ldeltaspeed, rdeltaspeed, accel)
	
	local starttime = timer.seconds()
	while true do
		local tdelta = timer.seconds() - starttime
		if tdelta >= stoptime then break end
	
		local lspeed = lstartspeed + tdelta * laccel
		local rspeed = rstartspeed + tdelta * raccel
		drivetrain:drive(lspeed, rspeed)
		
		task.yield()
	end
	
	drivetrain:drive(lendspeed, rendspeed)
end

local recalc_speeds

function Smooth:set_vel_dist(drivetrain, ltravspeed, ldist, rtravspeed, rdist, args)
	assert(math.sgn(ltravspeed) == math.sgn(ldist), "Distance and speed must be the same sign!")
	assert(math.sgn(rtravspeed) == math.sgn(rdist), "Distance and speed must be the same sign!")
	local accel = args.accel or self.accel

	ltravspeed, rtravspeed = recalc_speeds(ltravspeed, ldist, rtravspeed, rdist, accel)

	local lstartenc, rstartenc = drivetrain:get_encoders()
	self:set_vel(drivetrain, ltravspeed, rtravspeed, args)

	local laccel, raccel, stoptime = calc_accels_stoptime(-ltravspeed, -rtravspeed, accel)
	local ldeacceldist = ldist - (.5*laccel*stoptime*stoptime + ltravspeed*stoptime)
	local rdeacceldist = rdist - (.5*raccel*stoptime*stoptime + rtravspeed*stoptime)
	
	while true do
		drivetrain:wait_encoders()
		
		local lenc, renc = drivetrain:get_encoders()
		if ltravspeed ~= 0 and rtravspeed ~= 0 then
			local amt = math.abs(math.abs(lenc - lstartenc) / ldeacceldist) + math.abs(math.abs(renc - rstartenc) / rdeacceldist)
			if amt >= 2 then break end
		elseif ltravspeed ~= 0 then
			if math.abs(lenc - lstartenc) > math.abs(ldeacceldist) then break end
		else
			if math.abs(renc - rstartenc) > math.abs(rdeacceldist) then break end
		end
	end
	
	local ldeaccelenc, rdeaccelenc = lstartenc + ldeacceldist, rstartenc + rdeacceldist
	while true do
		local lenc, renc = drivetrain:get_encoders()
		local trav = (math.abs(lenc - ldeaccelenc) + math.abs(renc - rdeaccelenc)) / 2 + .5 -- FUDGE FACTOR
		local lspeed
		if ltravspeed ~= 0 then
			local ltemp = 2*laccel*math.keepsgn(trav, ltravspeed) + ltravspeed*ltravspeed
			if ltemp < 0 then break end
			lspeed = math.keepsgn(math.sqrt(ltemp), ltravspeed)
		else
			lspeed = 0
		end

		local rspeed
		if rtravspeed ~= 0 then
			local rtemp = 2*raccel*math.keepsgn(trav, rtravspeed) + rtravspeed*rtravspeed
			if rtemp < 0 then break end
			rspeed = math.keepsgn(math.sqrt(rtemp), rtravspeed)
		else
			rspeed = 0
		end
		
		drivetrain:drive(lspeed, rspeed)
		task.yield()
	end
	drivetrain:drive(0, 0)
end

function recalc_speeds(ltravspeed, ldist, rtravspeed, rdist, accel)
	local laccel, raccel, stoptime = calc_accels_stoptime(ltravspeed, rtravspeed, accel)
	local lacceldist = .5*laccel*stoptime*stoptime
	local racceldist = .5*raccel*stoptime*stoptime
	
	local lmaxtrav, rmaxtrav = ldist/2.1, rdist/2.1
	
	if lacceldist < lmaxtrav and racceldist < rmaxtrav then
		return ltravspeed, rtravspeed
	end
	
	stoptime = math.sqrt(2 * math.min(lmaxtrav/laccel, rmaxtrav/raccel))
	ltravspeed = laccel*stoptime
	rtravspeed = raccel*stoptime
	return ltravspeed, rtravspeed
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


