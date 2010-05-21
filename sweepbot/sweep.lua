import "config"

local servoutils = require "mb.servoutils"

---------------------
-- Pitch Functions --
---------------------

servoutils.build_functions{
	servo = pitch_servo,
	pitch_up = 1000,
	pitch_down = 0
}

function pitch(pos, speed)
	if speed == nil then
		pitch_servo:setpos(pos)
	else
		pitch_servo:setpos_speed(pos, speed)
	end
end
	
function pitch_off()
	pitch_servo:disable()
end

function pitch_wait()
	pitch_servo:wait()
end

----------------------
-- Extend Functions --
----------------------

servoutils.build_functions{
	servo = extend_servo,
	extend_open = 1000,
	extend_close = 0,
}

function extend(pos, speed)
	if speed == nil then
		extend_servo:setpos(pos)
	else
		extend_servo:setpos_speed(pos, speed)
	end
end

function extend_off()
	extend_servo:disable()
end

function extend_wait()
	extend_servo:wait()
end

------------------------
-- Combined Functions --
------------------------

function off()
	extend_off()
	pitch_off()
end

function reset()
	if pitch_servo:getpos() == -1 and extend_servo:getpos() == -1 then
		pitch_down()
		extend_close()
	else
		pitch_off()
		extend_off()
		error("Not safe to reset sweep while active! Please reset manually.", 2)
	end
end

function wait()
	extend_wait()
	pitch_wait()
end
