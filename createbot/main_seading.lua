local task = require "cbclua.task"
local create = require "mb.create"
local claw = require "claw"
local algorithm = require "algorithm"
local sponge = require "sponge"
import "config"

function main()
	claw.init()
	create.connect()
	sponge.reset()
	
	grab_pile(20)
	grab_pile(23)
	grab_pile(21)
	drive:fd{inches=11} -- wall lineup
	drive:fd{vel=8, time=1}
	
	drop_sponge(-42, "medium")
	drop_sponge(15, "small")
end
	
function grab_pile(fddist)
	task.async(function ()
		claw.down()
		task.sleep(.5)
		claw.open()
	end)
	
	drive:fd{inches=fddist}
--	task.sleep(2)
	claw.down_grab{wait=true}
--	task.sleep(2)
	claw.close()
	task.sleep(.8)
	claw.up_fling()
	task.sleep(.5)
	claw.release_basket()
	task.sleep(.2)
end

local sponge_queue = { "medium", "small", "large" }

function drop_sponge(fddist, cursponge)
	print("Dropping " .. cursponge .. " sponge")
	task.async(sponge.select, cursponge)
	
	local side
	if fddist > 0 then
		drive:fd{inches=fddist}
		side = algorithm.drive_to_oilslick("fd")
	else
		drive:bk{inches=-fddist}
		side = algorithm.drive_to_oilslick("bk")
	end
	print("Got oil slick on side " .. side)
	task.sleep(2)

	local turnamt
	local fddist = 2
	if cursponge == "small" then
		turnamt = -90
	elseif cursponge == "large" then
		turnamt = 90
		if side == "left" then
			side = "center-left"
			fddist = fddist + 5
		elseif side == "right" then
			side = "center-right"
			fddist = fddist + 5
		else
			fddist = fddist + 3
		end
	else
		turnamt = 0
		fddist = fddist + 1
	end
	
	if side == "center-left" then
		turnamt = turnamt - 7
	elseif side == "center-right" then
		turnamt = turnamt + 7
	elseif side == "left" then
		turnamt = turnamt - 40
		fddist = fddist + 2
	elseif side == "right" then
		turnamt = turnamt + 40
		fddist = fddist + 2
	end
	
	print("Turnamt", turnamt)
	print("Fddist", fddist)
	drive:fd{inches=fddist}
	turn(turnamt)
	sponge.release()
	task.async(sponge.reset)
	task.sleep(.5)
	turn(-turnamt)
end

function turn(amt)
	if amt > 0 then
		drive:lturn{degrees=amt}
	elseif amt < 0 then
		drive:rturn{degrees=-amt}
	end
end

