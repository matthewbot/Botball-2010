local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local timer = require "cbclua.timer"
local set = require "set"

local active_servos = set.new{}

--[[ SpeedControlServo ]]--

local Servo = cbc.Servo -- superclass abbreviation
SpeedControlServo = create_class("SpeedControlServo", Servo)

function SpeedControlServo:construct(args)
	Servo.construct(self, args)
	self.signal = task.Signal()
end

function SpeedControlServo:setpos(pos)
	set.remove(active_servos, self)
	return Servo.setpos(self, pos)
end

function SpeedControlServo:setpos_speed(stoppos, speed)
	local startpos = self:getpos()
	
	if stoppos < startpos then
		speed = -speed
	end
	
	self.startpos = startpos
	self.starttime = timer.seconds()
	self.stoppos = stoppos
	self.speed = speed
	set.insert(active_servos, self)
	
	start_update_task()
end

function SpeedControlServo:wait()
	while set.member(active_servos, self) do
		self.signal:wait()
	end
end

function SpeedControlServo:update()
	local tdelta = timer.seconds() - self.starttime
	local newpos = self.startpos + tdelta*self.speed
	
	local done
	if self.speed > 0 then
		done = newpos >= self.stoppos
	else
		done = newpos <= self.stoppos
	end
	
	if done then
		set.remove(active_servos, self)
		newpos = self.stoppos
		self.signal:notify_all()
	end
	
	Servo.setpos(self, newpos)
end

local update_task
local update_taskfunc

function start_update_task()
	if update_task and update_task:get_state() ~= "stopped" then
		return
	end
	
	update_task = task.start(update_taskfunc, "SpeedControlServo update")
end

function update_taskfunc()
	while true do
		task.sleep(1/40)
		
		local updated = false
		for servo in set.elements(active_servos) do
			servo:update()
			updated = true
		end
		
		if not updated then
			return
		end
	end
end

--[[ RescaleServo ]]--
RescaleServo = create_class("RescaleServo", SpeedControlServo)

function RescaleServo:construct(args)
	SpeedControlServo.construct(self, args)
	self.start_pos = args.start_pos
	self.end_pos = args.end_pos
end

function RescaleServo:scalepos(pos)
	return self.start_pos - pos / 1000 * (self.start_pos - self.end_pos)
end

function RescaleServo:setpos(pos)
	SpeedControlServo.setpos(self, self:scalepos(pos))
end

function RescaleServo:setpos_speed(pos, speed)
	SpeedControlServo.setpos_speed(self, self:scalepos(pos), speed)
end

function RescaleServo:getpos()
	local pos = SpeedControlServo.getpos(self)
	return (1000 * (self.start_pos - pos)) / (self.start_pos - self.end_pos)
end

--[[ build_functions ]]--

function build_functions(buildargs)
	local mod = getfenv(2)

	local servo = buildargs.servo
	buildargs.servo = nil
	local defspeed = buildargs.default_speed or "full"
	buildargs.default_speed = nil
	
	if servo == nil then
		error("Missing servo argument", 2)
	end
	
	for name, pos in pairs(buildargs) do
		mod[name] = function (args)
			local speed = (args and args.speed) or defspeed
			local wait = args and args.wait
			
			if speed == "full" then
				servo:setpos(pos)
			elseif type(speed) == "number" then
				servo:setpos_speed(pos, speed)
				if wait then
					servo:wait()
				end
			else
				error("Bad speed argument", 2)
			end
		end
	end
end
