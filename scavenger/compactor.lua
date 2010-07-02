import "config"

local task = require "cbclua.task"
local servoutils = require "mb.servoutils"

local time_half = 1.5

function init()
	open()
	task.sleep(0.1)
	retract_full()
end

function retract(time)
	time = time or time_half
	extend_motor:bk()
	task.wait_while(out_sensor, time)
	extend_motor:off()
end

function retract_full()
	extend_motor:bk()
	task.wait_while(out_sensor)
	extend_motor:off()
end

function extend(time)
    time = time or time_half
	extend_motor:fd()
	task.wait_while(in_sensor, time)
	extend_motor:off()
end

function extend_full()
	extend_motor:fd()
	task.wait_while(in_sensor)
	extend_motor:off()
end

servoutils.build_functions{
	servo = door_servo,
	close = 0,
	close_half = 600,
	open = 1150
}