local create = require "mb.create"
local task = require "cbclua.task"
 
CreateDriveTrain = create_class("CreateDriveTrain")
 
local ticks_per_inch = 198
local mm_per_inch = 25.4
 
function CreateDriveTrain:construct(args)
	self.wb = args.wb or 10.15
end
 
function CreateDriveTrain:drive(lspeed, rspeed)
	lspeed = lspeed*mm_per_inch
	rspeed = rspeed*mm_per_inch
	create.left_motor:set_speed(lspeed)
	create.right_motor:set_speed(rspeed)
end

function CreateDriveTrain:drive_dist(lspeed, ldist, rspeed, rdist)
	lspeed = lspeed*mm_per_inch
	rspeed = rspeed*mm_per_inch
	ldist = ldist*ticks_per_inch
	rdist = rdist*ticks_per_inch
	
	if ldist ~= 0 then
		create.left_motor:set_speed_offpos(lspeed, ldist)
		if rspeed ~= 0 then
			create.right_motor:set_speed_sync(rspeed, create.left_motor)
		end
	else
		create.right_motor:set_speed_offpos(rspeed, rdist)
		if lspeed ~= 0 then
			create.left_motor:set_speed_sync(rspeed, create.right_motor)
		end
	end
end
 
function CreateDriveTrain:get_wheelbase()
	return self.wb
end

function CreateDriveTrain:get_encoders()
	local lenc, renc = create.get_encoders()
	return lenc / ticks_per_inch, renc / ticks_per_inch
end

function CreateDriveTrain:wait_encoders()
	create.wait_encoders()
end

function CreateDriveTrain:get_speeds()
	return create.left_motor:get_speed(), create.right_motor:get_speed()
end
