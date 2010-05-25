local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local timer = require "cbclua.timer"

local active_servos = {}

--[[ SpeedControlServo ]]--

local Servo = cbc.Servo -- superclass abbreviation
SpeedControlServo = create_class("SpeedControlServo", Servo)

function SpeedControlServo:construct(args)
	Servo.construct(self, args)
	self.signal = task.Signal()
end

function SpeedControlServo:setpos(pos)
	active_servos[self] = nil
	return Servo.setpos(self, pos)
end

function SpeedControlServo:setpos_speed(stoppos, speed)
	local startpos = Servo.getpos(self)
	if startpos == -1 then
		error("Attempt to call setpos_speed on disabled servo!", 2)
	end
	
	if stoppos < startpos then
		speed = -speed
	end
	
	self.startpos = startpos
	self.starttime = timer.seconds()
	self.stoppos = stoppos
	self.speed = speed
	active_servos[self] = true
	
	start_update_task()
end

function SpeedControlServo:wait()
	while active_servos[self] do
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
		active_servos[self] = nil
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
		for servo in pairs(active_servos) do
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
	if pos == -1 then return -1 end
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
