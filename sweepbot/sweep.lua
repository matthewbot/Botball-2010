import "config"

local control = require "mb.control"
local task = require "cbclua.task"

local extend_open_pos	= 600
local extend_close_pos 	= 1650
local pitch_time		= 2.5


---------------------
-- Pitch Functions --
---------------------

function pitch_speed(speed)
	lpitch:mav(speed)
	rpitch:mav(speed)
end

function pitch_up()
	pitch_speed(1000)
	task.sleep(pitch_time)
	pitch_off()
end

function pitch_down()
	if pitch_down_switch() then
		pitch_speed(-1000)
		task.wait_while(pitch_down_switch)
		pitch_reset()
	else
		pitch_reset()
	end
end
	
function pitch_off()
	lpitch:off()
	rpitch:off()
end

function pitch_reset()
	if pitch_down_switch() then
		pitch_speed(-1000)
		task.wait_while(pitch_down_switch)
	end
	pitch_speed(1000)
	task.sleep(0.5)
	pitch_off()
	task.sleep(.2)
	pitch_speed(-300)
	task.wait_while(pitch_down_switch)
	task.sleep(.6)
	pitch_off()
end
	
----------------------
-- Extend Functions --
----------------------

function extend(pos, speed)
	local position = extend_close_pos - pos / 1000 * (extend_close_pos - extend_open_pos)
	
	if speed == nil then
		extend_servo:setpos(position)
	else
		extend_servo:setpos_speed(position, speed)
	end
end

function extend_open()
	extend(1000, 550)
end

function extend_close()
	extend(0, 550)
end
	
function extend_off()
	extend_servo:disable()
end

function extend_reset()
	extend(0)
end
	
-------------	
-- Fligger --
-------------

function fligger(pos, speed)
	if speed then
		fligger_servo:setpos_speed(pos, speed)
	else
		fligger_servo:setpos(pos)
	end
end

function fligger_up()
	fligger(50)
end

function fligger_down()
	fligger(1000, 500)
end

---------------------
-- Sweep Functions --
---------------------

function init() 
	fligger_up()
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