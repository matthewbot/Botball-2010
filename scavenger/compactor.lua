import "config"

local task = require "cbclua.task"
local servoutils = require "mb.servoutils"

local time_to_close = 1.8

function init()
	open()
	task.sleep(0.1)
	retract_full()
end

function retract(time)
	time = time or time_to_close
	extend_motor:bk()
	task.wait_while(in_sensor, time)
	extend_motor:off()
end

function retract_full()
	extend_motor:bk()
	task.wait_while(in_sensor)
	extend_motor:off()
end

function extend(time)
    time = time or time_to_close
	extend_motor:fd()
	task.wait_while(out_sensor, time)
	extend_motor:off()
end

function extend_full()
	extend_motor:fd()
	task.wait_while(out_sensor)
	extend_motor:off()
end

servoutils.build_functions{
	servo = door_servo,
	close = 0,
	close_half = 600,
	open = 1150
}


--prototypes
function capture_open()
	extend_full()
	close_half({speed = 600, wait = true})
end

function capture_close()
	close({wait = true})
	task.sleep(0.5)
	retract()
end

function capture()
	drive:fd{inches = 10}
	capture_open()
	drive:bk{inches = 3.9}
	capture_close()
end

function release()
	open()
	drive:bk{inches = 3}
end