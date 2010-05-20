import "config"

local servoutils = require "mb.servoutils"
local control = require "mb.control"
local task = require "cbclua.task"

extend_open_pos		= 500
extend_close_pos 	= 2000
pitch_up_pos		= 1050
pitch_down_pos		= 0

---------------------
-- Pitch Functions --
---------------------

servoutils.build_functions{
	servo = pitch_servo,
	pitch_up = pitch_up_pos,
	pitch_down = pitch_down_pos
}

function pitch(pos, speed)
	local position = pitch_down_pos - pos / 1000 * (pitch_down_pos - pitch_up_pos)
	
	if speed == nil then
		pitch_servo:setpos(position)
	else
		pitch_servo:setpos_speed(position, speed)
	end
end
	
function pitch_off()
	pitch_servo:disable()
end

function pitch_wait()
	pitch_servo:wait()
end

function pitch_reset()
	if pitch_servo:getpos() == -1 then
		pitch_down()
	else
		pitch(0, 500)
	end
end

----------------------
-- Extend Functions --
----------------------

servoutils.build_functions{
	servo = extend_servo,
	extend_open = extend_open_pos,
	extend_close = extend_close_pos,
}

function extend(pos, speed)
	local position = extend_close_pos - pos / 1000 * (extend_close_pos - extend_open_pos)
	
	if speed == nil then
		extend_servo:setpos(position)
	else
		extend_servo:setpos_speed(position, speed)
	end
end

function extend_off()
	extend_servo:disable()
end

function extend_wait()
	extend_servo:wait()
end

function extend_reset()
	if extend_servo:getpos() == -1 then
		extend_close()
	else
		extend(0, 500)
	end
end

---------------------
-- Sweep Functions --
---------------------

function init() 
	reset()
end

function reset()
	pitch_reset()
	extend_reset()
end

function servo_wait()
	extend_wait()
	pitch_wait()
end

function palms_sweep()
	print "Sweeping Palms"
	extend(200, 500)
	task.sleep(.2)
	pitch(1000, 700)
	extend(850, 700)
	servo_wait()
	extend(600, 700)

end

function palms_retract()
	print "Retracting Palms"
	extend(300, 280)
	pitch(400, 400)
	servo_wait()
	pitch(0, 700)
	extend(0, 700)
end

function botguy_sweep()
	print "Sweeping Botguy"
	extend(200, 500)
	task.sleep(.2)
	pitch(1000, 700)
	extend(1000, 700)
	servo_wait()
	extend(700, 700)
end

function botguy_retract()
	print "Retracting Botguy"
	pitch(400, 400)
	
end
