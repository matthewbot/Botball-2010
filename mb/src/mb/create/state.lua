local task = require "cbclua.task"
local math = require "math"

-- General state

local bat

function get_battery()
	return bat
end

function update_battery(newbat)
	bat = newbat
end

local connstate = "disconnected"
local connstate_signal = task.Signal()

function get_connection_state()
	return connstate
end

function update_connection_state(state)
	connstate = state
	connstate_signal:notify_all()
end

function wait_connection_state(state)
	while connstate ~= state do
		connstate_signal:wait()
	end
end

function assert_connection(depth)
	if depth == nil then
		depth = 2
	end
	
	if connstate == "disconnected" then
		error("Create is disconnected", depth+1)
	else
		wait_connection_state("connected")
	end
end

-- Motor state class

local Motor = create_class "mb.create.Motor"
local Motor_sig = task.Signal()

function Motor:construct()
	self.speed = 0
	self.prevdir = "fd"
	
	self.enc = 0
	self.rawenc = 0
	self.prevdelta = 0
	
	self.stop = false
end

local function wrap_speed(speed)
	if speed > 500 then
		return 500
	elseif speed < -500 then
		return -500
	else
		return speed
	end
end

function Motor:set_speed(speed)
	assert_connection(2)
	self.speed = math.floor(wrap_speed(speed))
	self.offpos = nil
	self.sync = nil
	self.stop = false
end

function Motor:set_speed_offpos(speed, offpos)
	assert_connection(2)
	self.speed = math.floor(wrap_speed(speed))
	self.offpos = math.floor(offpos)
	self.sync = nil
	self.stop = false
end

function Motor:set_speed_sync(speed, sync)
	assert_connection(2)
	self.speed = math.floor(wrap_speed(speed))
	self.offpos = nil
	self.sync = sync
	self.stop = false
end

function Motor:get_speed()
	return self.speed
end

function Motor:get_encoder()
	return self.enc
end

function Motor:get_done()
	return self.offpos == nil and self.sync == nil
end

function Motor:wait()
	while not self:get_done() do
		Motor_sig:wait()
	end
end

function Motor:update_encoder(newenc)
	local delta = newenc - self.rawenc
	
	if delta == 0 then return end
	
	if delta < 0 then
		delta = delta + 0xFFFF
	end
	
	if delta > 400 or delta < 0 then
		print("Got a big delta of " .. delta .. " newenc " .. newenc .. " rawenc " .. self.rawenc)
		self.rawenc = newenc
		return 0
	end
	
	if math.abs(delta) > math.abs(self.prevdelta) then
		if self.speed > 0 then
			self.prevdir = "fd"
		elseif self.speed < 0 then
			self.prevdir = "bk"
		end
	end
	
	if self.prevdir == "bk" then
		delta = -delta
	end
		
	self.enc = self.enc + delta
	self.rawenc = newenc
	self.prevdelta = delta
	
	Motor_sig:notify_all()
	
	if not self.stop and self.offpos ~= nil then
		if self.speed > 0 then
			self.stop = self.enc >= self.offpos - (self.prevdelta/2)
		elseif self.speed < 0 then
			self.stop = self.enc <= self.offpos - (self.prevdelta/2)
		end
	end
	
	return delta
end

function Motor:check_stop()
	if self.sync ~= nil then
		return self.sync:check_stop()
	end
	
	return self.stop
end

function Motor:set_raw_encoder(rawenc)
	self.rawenc = rawenc
end

-- Combined motor functions

function get_encoders()
	return left_motor.enc, right_motor.enc
end

function wait_encoders()
	local lenc, renc = get_encoders()
	
	while lenc == left_motor.enc and renc == right_motor.enc do
		Motor_sig:wait()
	end
end

-- Motor setup

left_motor = Motor()
right_motor = Motor()

-- Sensor class

local Sensor = create_class "Sensor"

function Sensor:construct(val)
	self.signal = task.Signal()
	self:update(val)
end

function Sensor:update(val)
	self.val = val
	self.signal:notify()
end

function Sensor:read()
	return self.val
end

function Sensor:__call() 
	return self:read()
end

function Sensor:wait()
	self.signal:wait()
end

function Sensor:read_float()
	local val = self:read()

	if type(val) == "number" then
		return val / 4096
	elseif val == nil then
		return nil
	else
		error("Attempting to read digital create sensor as floating point", 2)
	end
end

function Sensor:__call()
	return self:read()
end

-- Sensor setup

for _, sensor in pairs{"left_bump", "right_bump", "left_wheel_drop", "right_wheel_drop", "front_wheel_drop"} do
	_M[sensor] = Sensor(false)
end

bump = Sensor(nil)

function bump:read() -- specialize the bump sensor, it reads the logical or of lbump and rbump
	return left_bump.val or right_bump.val
end

for _, sensor in pairs{"left_cliff", "right_cliff", "front_left_cliff", "front_right_cliff", "wall"} do
	_M[sensor] = Sensor(0)
end

