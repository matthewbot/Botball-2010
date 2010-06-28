local comm = require "mb.create.comm"
local timer = require "cbclua.timer"
local task = require "cbclua.task"

import("mb.create.state")

-- Tasks

local transmit_taskfunc
local transmit_task

local receive_taskfunc
local receive_task

local monitor_taskfunc
local monitor_task

local reconnect_taskfunc
local reconnect_task

-- Private State

local desired_packet_rate = 30
local packet_rate = 0
local packet_ctr = 0
local started = false

-- Public functions

function get_packet_rate() 
	return packet_rate
end

function set_packet_rate(desired_rate)
	desired_packet_rate = desired_rate
end

function start()
	if started then return end
	
	transmit_task = task.start(transmit_taskfunc, "create transmit")
	receive_task = task.start(receive_taskfunc, "create receive")
	monitor_task = task.start(monitor_taskfunc, "create monitor")
	reconnect_task = nil
	started = true
end

function stop()
	if not started then return end
	
	started = false
	packet_rate = 0
	packet_ctr = 0
	
	task.stop(transmit_task)
	task.stop(receive_task)
	task.stop(monitor_task)
	if reconnect_task then
		task.stop(reconnect_task)
	end
end
	
-- Create process

function receive_taskfunc()
	while true do
		local sensors, lenc, renc = comm.receive_update()
		
		for sensorname, val in pairs(sensors) do
			_M[sensorname]:update(val)
		end
		
		left_motor:update_encoder(lenc)
		right_motor:update_encoder(renc)
		
		local lstop = left_motor:check_stop()
		local rstop = right_motor:check_stop()
		
		if lstop then
			left_motor:set_speed(0)
		end
		
		if rstop then
			right_motor:set_speed(0)
		end
		
		comm.send_motors(left_motor:get_speed(), right_motor:get_speed())
		
		packet_ctr = packet_ctr + 1
	end
end

function transmit_taskfunc()
	while true do		
		comm.send_motors(left_motor:get_speed(), right_motor:get_speed())
		comm.send_update_request()
		
		task.sleep(1/desired_packet_rate)
	end
end

function monitor_taskfunc()
	local prevtime = timer.seconds()

	while true do
		task.sleep(1/4)
		
		if packet_ctr == 0 then
			print("Create connection lost")
			reconnect_task = task.start(reconnect_taskfunc, "create reconnect")
			update_connection_state("error")
			stop()
			return
		end
		
		local curtime = timer.seconds()
		packet_rate = packet_ctr / (curtime - prevtime)
		packet_ctr = 0
		prevtime = curtime
	end
end

function reconnect_taskfunc()
	while true do
		local connected = comm.send_start()
		if connected then break end
		task.sleep(.5)
	end
	
	print("Create reconnected")
	start()
	update_connection_state("connected")
	reconnect_task = nil
end
