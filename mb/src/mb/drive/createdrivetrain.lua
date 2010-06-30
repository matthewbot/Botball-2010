local create = require "mb.create"
local task = require "cbclua.task"
 
CreateDriveTrain = create_class("CreateDriveTrain")
 
local mm_per_inch = 25.4
 
function CreateDriveTrain:construct(args)
	self.wb = args.wb or 10.15
	self.ticks_per_inch = args.ticks or 195
	self.flip = args.flip or false
end
 
function CreateDriveTrain:drive(lvel, rvel)
	local lspeed, rspeed
	if not self.flip then
		lspeed = lvel*mm_per_inch
		rspeed = rvel*mm_per_inch
	else
		lspeed = -rvel*mm_per_inch
		rspeed = -lvel*mm_per_inch
	end
	create.left_motor:set_speed(lspeed)
	create.right_motor:set_speed(rspeed)
end

function CreateDriveTrain:drive_dist(lvel, ltrav, rvel, rtrav)
	local lspeed, ldist, rspeed, rdist

	if not self.flip then
		lspeed = lvel*mm_per_inch
		rspeed = rvel*mm_per_inch
		ldist = ltrav*self.ticks_per_inch
		rdist = rtrav*self.ticks_per_inch
	else
		lspeed = -rvel*mm_per_inch
		rspeed = -lvel*mm_per_inch
		ldist = -rtrav*self.ticks_per_inch
		rdist = -ltrav*self.ticks_per_inch
	end
	
	local lenc, renc = create.get_encoders()
	
	if ldist ~= 0 then
		create.left_motor:set_speed_offpos(lspeed, ldist+lenc)
		if rspeed ~= 0 then
			create.right_motor:set_speed_sync(rspeed, create.left_motor)
		end
	else
		create.right_motor:set_speed_offpos(rspeed, rdist+renc)
		if lspeed ~= 0 then
			create.left_motor:set_speed_sync(rspeed, create.right_motor)
		end
	end
	
	create.left_motor:wait()
	create.right_motor:wait()
end
 
function CreateDriveTrain:get_wheel_base()
	return self.wb
end

function CreateDriveTrain:get_encoders()
	local lenc, renc = create.get_encoders()
	if self.flip then
		return -renc / self.ticks_per_inch, -lenc / self.ticks_per_inch
	else
		return lenc / self.ticks_per_inch, renc / self.ticks_per_inch
	end
end

function CreateDriveTrain:wait_encoders()
	create.wait_encoders()
end

function CreateDriveTrain:get_speeds()
	return create.left_motor:get_speed() / self.ticks_per_inch, create.right_motor:get_speed() / self.ticks_per_inch
end
