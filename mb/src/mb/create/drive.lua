local drive = require "mb.drive"
local task = require "cbclua.task"
local math = require "math"

import("mb.create.state")

local Odometer

-- Drive class

local ticks_per_inch = 198

Drive = create_class("Drive", drive.DriveBase)

function Drive:construct(args)
	if args == nil then
		args = { }
	end

	self.slow_speed = args.slow_speed or 40
	self.slow_dist = (args.slow_dist or 4.5) * ticks_per_inch
	self.speed_mult = (args.top_speed or 500) / 1000
	self.coast = (args.coast or 0.1) * ticks_per_inch
	self.wb = args.wb or 10.15
end

function Drive:get_wheelbase()
	return self.wb
end

function Drive:drive(lspeed, rspeed, extraargs)
	assert_connection()
	left_motor:set_speed(lspeed * self.speed_mult)
	right_motor:set_speed(rspeed * self.speed_mult)
end

local function keep_sign(orig, val)
	if orig < 0 then
		if val < 0 then
			return val
		else
			return -val
		end
	else
		if val > 0 then
			return val
		else
			return -val
		end
	end
end

function Drive:drive_dist(lspeed, dist, rspeed, extraargs)
	if dist < 0 then
		dist = -dist
	end

	assert_connection()
	lspeed = math.floor(lspeed * self.speed_mult)
	rspeed = math.floor(rspeed * self.speed_mult)
	dist = dist * ticks_per_inch
	
	local lenc = left_motor:get_encoder()
	local renc = right_motor:get_encoder()
	local slow_trav = dist - self.coast
	local slow_speed = self.slow_speed
	local slow_dist = (extraargs.slow == false) and 0 or self.slow_dist	
	local fast_trav = dist - slow_dist - self.coast
	
	if fast_trav < 0 then
		fast_trav = 0
	end
	
	local lslow_speed, rslow_speed
	if lspeed == 0 then
		lslow_speed = 0
		rslow_speed = keep_sign(rspeed, slow_speed)
	elseif rspeed == 0 then
		lslow_speed = keep_sign(lspeed, slow_speed)
		rslow_speed = 0
	elseif math.abs(lspeed) < math.abs(rspeed) then
		lslow_speed = math.floor(keep_sign(lspeed, slow_speed / rspeed * lspeed))
		rslow_speed = keep_sign(rspeed, slow_speed)
	else
		lslow_speed = keep_sign(lspeed, slow_speed)
		rslow_speed = math.floor(keep_sign(rspeed, slow_speed / lspeed * rspeed))
	end		
	
	if fast_trav > 0 then
		self:drive_part(fast_trav, lspeed, rspeed, lenc, renc)
	end
	if slow_trav > fast_trav then
		self:drive_part(slow_trav, lslow_speed, rslow_speed, lenc, renc)	
	end
	
	if self.debug then
		task.sleep(1)
	
		local lerr
		if lspeed > 0 then
			lerr = left_motor:get_encoder() - (lenc + dist)
		else
			lerr = left_motor:get_encoder() - (lenc - dist)
		end
		
		local rerr
		if rspeed > 0 then
			rerr = right_motor:get_encoder() - (renc + dist)
		else
			rerr = right_motor:get_encoder() - (renc - dist)
		end
		print("L err " .. lerr .. " R err " .. rerr)
	end
end

function Drive:drive_part(trav, lspeed, rspeed, lenc, renc)
	if lspeed ~= 0 then
		local stop = lspeed > 0 and lenc + trav or lenc - trav
		left_motor:set_speed_offpos(lspeed, stop)
		right_motor:set_speed_sync(rspeed, left_motor)
		left_motor:wait()
	else
		local stop = rspeed > 0 and renc + trav or renc - trav
		right_motor:set_speed_offpos(rspeed, stop)
		right_motor:wait()
	end
end

function Drive:stop()
	assert_connection()
	left_motor:set_speed(0)
	right_motor:set_speed(0)
end

function Drive:read_encoders()
	local lenc, renc = get_encoders()
	
	return lenc / ticks_per_inch, renc / ticks_per_inch
end

function Drive:wait_encoders()
	wait_encoders()
end
