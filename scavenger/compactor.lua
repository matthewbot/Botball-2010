import "config"

local task = require "cbclua.task"
local servoutils = require "mb.servoutils"

local sleep_time = 1.3

function init()
	open()
	extend_motor:mrp(1000) --dont know the exact position	
end

function retract(time)
	time = time or sleep_time
	extend_motor:bk()
	task.sleep(sleep_time)
	extend_motor:off()
end

function extend(time)
    time = time or sleep_time
	extend_motor:fd()
	task.sleep(sleep_time)
	extend_motor:off()
end

servoutils.build_functions{
	servo = door_servo,
	close = 0,
	open = 1000
}


--prototypes
function capture()
	extend()
	close()
	retract()
end

function release()
	open()
	drive:bk{inches = 6}
end