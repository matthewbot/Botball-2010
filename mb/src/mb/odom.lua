local task = require "cbclua.task"
local util = require "cbclua.util"
local math = require "math"

--

Odometry = create_class "Odometry"

local pi = math.pi
local twopi = 2*pi

function Odometry:construct(args)
	self.drivetrain = assert(args.drivetrain, "Missing drive argument to Odometry constructor")
	self.x = args.x or 0
	self.y = args.y or 0
	self.dir = args.dir or 0
	
	self.update_taskid = task.start(util.bind(self, "update_task"), "odometry update")
	self.update_signal = task.Signal()
end

function Odometry:set(args)
	if args.x then
		self.x = args.x
	end
	
	if args.y then
		self.y = args.y
	end
	
	if args.dir then
		self.dir = math.rad(args.dir)
	elseif args.rad then
		self.dir = args.rad
	end
end

function Odometry:get_drive()
	return self.drive
end

function Odometry:stop()
	task.stop(update_taskid)
end

function Odometry:get()
	return self.x, self.y, math.deg(self.dir)
end

function Odometry:get_x()
	return self.x
end

function Odometry:get_y()
	return self.y
end

function Odometry:get_dir_rad()
	return self.dir
end

function Odometry:get_dir()
	return math.deg(self.dir)
end

function Odometry:wait()
	return update_signal:wait()
end

function Odometry:update_task()
	local prev_l, prev_r = self.drivetrain:get_encoders()

	while true do
		self.drivetrain:wait_encoders()
		
		local l, r = self.drivetrain:get_encoders()
		local delta_l = l - prev_l
		local delta_r = r - prev_r
		
		if self.enable_dumps then
			print(delta_l, delta_r)
		end
		
		local dist = (delta_l + delta_r) / 2
		self.dir = self.dir + (delta_r - delta_l) / self.drivetrain:get_wheel_base()
		
		while self.dir >= twopi do
			self.dir = self.dir - twopi
		end
		
		while self.dir < 0 do
			self.dir = self.dir + twopi
		end
			
		self.x = self.x + dist * math.cos(self.dir)
		self.y = self.y + dist * math.sin(self.dir)
		
		prev_l, prev_r = l, r
		
		self.update_signal:notify()
	end
end

