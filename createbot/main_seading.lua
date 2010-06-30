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
	grab_pile(23)
	drive:fd{inches=9} -- wall lineup
	drive:fd{vel=8, time=1}
	
	drop_sponge(-42, "medium")
	drop_sponge(15, "small")
	
	drive:fd{inches=15} -- wall lineup
	drive:fd{vel=8, time=1}
	drive:bk{inches=4}
	drive:rturn{degrees=90}
	drive:bk{vel=8, wait=create.bump}
	
	grab_pile(20)
	
	drop_sponge(-5, "large")
	
	drive:fd{inches=20} -- wall lineup
	drive:fd{vel=8, time=1}
	drive:bk{inches=4}
	drive:rturn{degrees=85}
	
	drive:fd{inches=33} -- line up against duck scoring area
	drive:fd{vel=8, time=1}
	drive:bk{inches=1}
	drive:lturn{degrees=75}
	claw.down{wait=true}
	claw.eject()
	
	claw.up()
	drive:bk{inches=10}
	drive:rturn{degrees=75}
	drive:fd{inches=37}
	drive:fd{vel=8, time=1}
	
	clean_ducks()
end

function clean_ducks()
	drive:bk{inches=11}
	drive:lturn{degrees=90}
	drive:fd{vel=8, time=1}
	drive:bk{inches=2.5}
	
	task.async(function ()
		task.sleep(.3)
		grip_servo(1400)
	end)
	claw.down_grab{wait=true}
	claw.close()
	task.sleep(.5)
	claw.lift{wait=true}
	drive:bk{inches=14}
	drive:bk{vel=8, wait=create.bump}
	drive:lturn{degrees=95}
	drive:bk{inches=7.25}
	claw.down{wait=true}
	claw.open{speed=700, wait=true}
	task.sleep(.5)
	
	task.async(function ()
		task.sleep(.3)
		claw.up()
		task.sleep(.4)
		claw.close()
	end)
	drive:bk{vel=8, wait=create.bump}
	drive:rturn{degrees=45}
	drive:fd{inches=12}
	drive:rturn{degrees=45}
	drive:fd{inches=10}
	drive:fd{vel=8, time=1}
	
	task.async(function ()
		task.sleep(.3)
		claw.open()
	end)
	claw.down_grab{wait=true}
	claw.close()
	task.sleep(.5)
	claw.lift{wait=true}
	
	drive:bk{inches=10}
	drive:lturn{degrees=90}
	drive:bk{inches=7.25}
	claw.down{wait=true}
	claw.open{speed=700, wait=true}
	drive:bk{vel=8, wait=create.bump}
	
	claw.up()
	task.sleep(.4)
	claw.close()
	drive:lturn{degrees=90}
	drive:fd{inches=10}
	drive:fd{vel=8, time=1}
end
	
function grab_pile(fddist, chargedelay)
	task.async(function ()
		claw.down()
		task.sleep(.5)
		claw.open()
	end)
	
	if chargedelay then
		task.sleep(chargedelay)
	end
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

function drop_sponge(chargedist, cursponge)
	print("Dropping " .. cursponge .. " sponge")
	task.async(sponge.select, cursponge)
	
	local side
	if chargedist > 0 then
		drive:fd{inches=chargedist}
		side = algorithm.drive_to_oilslick("fd")
	else
		drive:bk{inches=-chargedist}
		side = algorithm.drive_to_oilslick("bk")
	end
	print("Got oil slick on side " .. side)

	local turnamt
	local fddist = 1
	fddist = 2
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
		
		if chargedist < 0 then
			fddist = fddist - 3
		end
	else
		turnamt = 0
		fddist = fddist + 1
		
		if chargedist < 0 then
			fddist = fddist - 1
		end
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
	if fddist > 0 then
		drive:fd{inches=fddist}
	end
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

