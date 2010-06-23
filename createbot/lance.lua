local servoutils = require "mb.servoutils"
local task = require "cbclua.task"
import "config"

function extend()
	pivot_back()
	
	spool_in()
	pivot(500)
	task.sleep(1.5)
	pivot_back()
	task.sleep(1)
	spool_off()
	
	pivot(650)
	spool_out()
	task.sleep(1.5)
	spool_off()
end

function retract()
	pivot_back()
end

----------------

function pivot_back()
	pivot_servo(1250)
end

function pivot(pos, speed)
	pivot_servo:setpos_speed(pos, speed or 500)
	pivot_servo:wait()
end

function spool_out()
	spool_motor:fd()
end

function spool_in()
	spool_motor:bk()
end

function spool_off()
	spool_motor:off()
end

