import "config"

local servoutils = require "mb.servoutils"
local control = require "mb.control"
local task = require "cbclua.task"

 extend_open_pos	= 500
 extend_close_pos 	= 2000
 pitch_up_pos		= 800
 pitch_down_pos		= 1500

---------------------
-- Pitch Functions --
---------------------

servoutils.build_functions{
	servo = pitch_servo,
	pitch_up = 800,
	pitch_down = 1500
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

function pitch_reset()
	pitch(0)
end

----------------------
-- Extend Functions --
----------------------

servoutils.build_functions{
	servo = extend_servo,
	extend_open = 800,
	extend_close = 1500
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

function extend_reset()
	extend(0)
end

---------------------
-- Sweep Functions --
---------------------

function init() 
	sweep_reset()
end

function sweep_reset()
	pitch_reset()
	extend_reset()
end

function first_palms_sweep()
	control.time_sequence{
		{0, extend, 300, 500},
		{0.5, pitch_speed, 1000},
		{1.5, extend, 1000, 400},
		{2, pitch_speed, 550},
		{3.3, extend, 920},
		{3.6, pitch_off}
	}
end

function first_palms_retract()
	control.time_sequence{
		{0, extend, 200, 500},
		{0.5, pitch_speed, -200},
		{5, pitch_off},
		{5.2, extend, 400, 500}
	}
	sweep_reset()
end

function botguy_sweep()
	control.time_sequence{
		{0, extend, 500, 600},
		{0.7, pitch_speed, 1000},
		{1.5, extend, 700, 700}, 
		{2.1, pitch_speed, 500},
		{2.5, pitch_off},
		{2.5, extend, 350, 500},
		{2.75, pitch_speed, -1000},
		{3.5, pitch_off}
	}
	
	
end

function botguy_retract()

	sweep_reset()
end

function second_palms_sweep()
end

function second_palms_retract()

	sweep_reset()
end