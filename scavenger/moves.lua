import "config"

local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local math = require "math"
local compactor = require "compactor"
local grabs = require "grabs"
local motion = require "motion"
local camera = require "camera"

local botguy_grabbed = false

--Scenario A
function goto_pvc_island(block)
	block = block or false
	
	task.sleep(4)
	drive:fd{inches = 39}
	task.sleep(2)
	drive:rturn{degrees = 54}
	motion.drive_sensor("right", "fd", "pvc", 800, 600)
	motion.drive_sensor("right", "fd", "no_pvc", 800, 350)
	if block then
		drive:fd{inches = 4}
	else
		drive:fd{inches = 6}
	end
	
	--[[drive:fd{inches = 38}
	drive:rturn{degrees = 40}
	drive:fd{inches = 24}]]--hit pvc of the island
end

function grab_our_leg()
	grabs.tribbles_pvc_bk(0.32)
	drive:bk{inches = 3}
	drive:rturn{degrees = 96}
	drive:fd{inches = 1}
	
	local close_botguy, min_x_botguy, max_x_tribbles = camera.find_both()
		
	print("max_x_tribbles: " .. tostring(max_x_tribbles))
	print("min_x_botguy: " .. tostring(min_x_botguy) .. " close_botguy?: " .. tostring(close_botguy))
	
	compactor.open()
	motion.drive_sensor("right", "fd", "pvc", 650, 600)

	if min_x_botguy > -1 then
		if close_botguy == false and (min_x_botguy < 2) then    -- Added special case check
			drive:rpiv{degrees = 61}
			grabs.botguy_pvc()
		elseif close_botguy == true then
			drive:fd{inches = 7}
			grabs.botguy_pvc()
			drive:fd{inches = 5}
		end
		botguy_grabbed = true
	elseif max_x_tribbles > -1 then
		if max_x_tribbles >= 2 and max_x_tribbles < 6 then
			drive:fd{inches = 7}
			grabs.tribbles_pvc()
			drive:lpiv{degrees = -30}
			drive:rpiv{degrees = 37}
			--local tribble_async = task.async(grabs.tribbles) --to stay or not to stay?
			drive:scooch{xdist = 0.75, dir = "bk"}
			--task.join(tribble_async)
			drive:scooch{xdist = 0.5}
		elseif max_x_tribbles < 2 then
			drive:bk{inches = 2}
			drive:rpiv{degrees = 35}
			drive:fd{inches = 5}
			drive:rpiv{degrees = 30}
		end
	else
		drive:rpiv{degrees = 61}
	end
end

	--[[else
	drive:bk{inches = 2}
	drive:rpiv{degrees = 35}
	drive:fd{inches = 5}
	drive:rpiv{degrees = 30}]]--

	
	--[[drive:scooch{xdist = -0.75}
	motion.drive_sensor("right", "fd", "pvc", 650, 600)
	drive:fd{inches = 7}
	grabs.tribbles_pvc()]]--

function go_into_middle()  --middle = no touch zone
	compactor.close()

	local close_botguy, min_x_botguy = camera.find_botguy()
	print("min_x_botguy: " .. tostring(min_x_botguy) .. " close_botguy?: " .. tostring(close_botguy))

	compactor.open()
	motion.drive_sensor("left", "fd", "pvc", 650, 500)
	drive:fd{inches = 14}
	
	if botguy_grabbed == true then
		grabs.botguy_pvc()
	elseif min_x_botguy > -1 then
		if min_x_botguy >= 2 and min_x_botguy < 6 then
			grabs.botguy_pvc()
			botguy_grabbed = true
		end
	else
		grabs.tribbles_pvc_full()
	end
	
	drive:fd{inches = 5}
end

function go_home()
	drive:bk{inches = 25}
--	motion.drive_sensor("left", "bk", "pvc", 900, 500)
	--drive:bk{inches = 13}
	drive:rpiv{degrees = 37}
	drive:lpiv{degrees = -30}
	drive:bk{inches = 4}
	
	cbc.a_button:wait()
	
	motion.drive_sensor("left", "fd", "no_pvc", 900, 500)
	drive:fd{inches = 3}
	drive:rturn{degrees = 95}
	drive:fd{inches = 5}
	motion.drive_sensor("right", "bk", "pvc", 900, 400)
	motion.drive_sensor("right", "bk", "no_pvc", 900, 350)
	drive:bk{inches = 6}
	
	cbc.a_button:wait()
	
	drive:rturn{degrees = 97}
	drive:fd{inches = 28}
	--drive:rturn{degrees = 190}
	--grabs.release()
end

function turn_180()
	drive:lturn{degrees = 90}
	drive:lturn{degrees = 90}
end

--Scenario C
function block(dist)
	goto_pvc_island(true)--22 inches to get close to the pvc of the island

	drive:rturn{degrees = 90}
	compactor.close()
	compactor.extend_full()
	
	dist = dist or 0
	if dist < 0 then
		drive:bk{inches = math.abs(dist)}
	else
		drive:fd{inches = dist}
	end
	
	door_servo:disable()
end
