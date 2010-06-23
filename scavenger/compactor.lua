import "config"

local task = require "cbclua.task"
local servoutils = require "mb.servoutils"

local time_half = 1.8
local time_full = 25

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


--prototypes
function capture_open_botguy()
	extend_full()
	close_half({speed = 600, wait = true})
end

function capture_open_tribbles(waqt)
	extend_full()
	close()
	retract(waqt)
end

function capture_close_botguy()
	close({wait = true})
	task.sleep(0.5)
	retract()
end

function capture_close_tribbles()
	drive:lturn{degrees = 25}
	drive:fd{inches = 2, speed =500}
	open()
	capture_open_tribbles(1.2)
	
	drive:rturn{degrees = 50}
	drive:fd{inches = 2, speed =500}
	open()
	capture_open_tribbles(1.2)
	
	drive:lturn{degrees = 25}
	open()
	capture_open_tribbles(time_full)
end

function capture(what)
	drive:fd{inches = 10}
	
	if what == "botguy" then
		capture_open_botguy()
	elseif what == "tribbles" then
		capture_open_tribbles()
	end
	
	drive:bk{inches = 3.9}
	
	if what == "botguy" then
		capture_close_botguy()
	elseif what == "tribbles" then
		capture_close_tribbles()
	end
end

function release()
	open()
	drive:bk{inches = 3}
end