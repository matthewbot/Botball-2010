import "config"

local cbc = require "cbclua.cbc"
local botball = require "cbclua.botball"
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
	
	drive:rpiv{degrees = -4}
	task.sleep(4)
	drive:fd{inches = 39}
	task.sleep(2)
	drive:rturn{degrees = 54}
	motion.drive_sensor("right", "fd", "pvc", 800, 500)
	motion.drive_sensor("right", "fd", "no_pvc", 800, 400)
	if block then
		drive:fd{inches = 4}
	else
		drive:fd{inches = 6}
	end
	
	--[[drive:fd{inches = 38}
	drive:rturn{degrees = 40}
	drive:fd{inches = 24}]]--hit pvc of the island
end

function grab_our_leg(snow)
	snow = snow or false
	grabs.tribbles_pvc_bk(0.32)
	drive:bk{inches = 2.5}
	drive:rturn{degrees = 96}
	drive:fd{inches = 1}
	
	if snow == false  then
		local close_botguy, min_x_botguy, max_x_tribbles = camera.find_both()
			
		print("max_x_tribbles: " .. tostring(max_x_tribbles))
		print("min_x_botguy: " .. tostring(min_x_botguy) .. " close_botguy?: " .. tostring(close_botguy))
		
		compactor.open()
		motion.drive_sensor("right", "fd", "pvc", 650, 600)

		if min_x_botguy > -1 then
			if close_botguy == "not_close" and (min_x_botguy < 2) then    -- Added special case check
				print("          ")
				print("botguy close and to the left")
				drive:rpiv{degrees = 61}
				drive:fd{inches = 6}
				grabs.botguy_pvc()
			else
				print("          ")
				print("botguy close/ false and to the right")
				drive:fd{inches = 7}
				grabs.botguy_pvc()
				drive:fd{inches = 5}
				drive:bk{inches = 1.5}
				drive:lturn{degrees = 90}
				drive:fd{inches = 10}
			end
			botguy_grabbed = true
		elseif max_x_tribbles > -1 then
			if max_x_tribbles >= 2 and max_x_tribbles < 6 then
				print("          ")
				print("tribbles to the right")
				drive:fd{inches = 7}
				grabs.tribbles_pvc()
				drive:lpiv{degrees = -30}
				drive:rpiv{degrees = 37}
				drive:scooch{xdist = 0.5, dir = "bk"}
				drive:scooch{xdist = 0.25}
			elseif max_x_tribbles < 2 then
				print("          ")
				print("tribbles to the left")			
				drive:bk{inches = 2}
				drive:rpiv{degrees = 35}
				drive:fd{inches = 5}
				drive:rpiv{degrees = 30}
			end
		else
			print("          ")
			print("no botguy or tribbles")	
			drive:rpiv{degrees = 61}
		end
		
		if botguy_grabbed == true then
			return true
		end
	
		return false
	else
		compactor.open()
		motion.drive_sensor("right", "fd", "pvc", 650, 600)
		drive:rpiv{degrees = 61}
	end
	
	return
end

function go_into_middle(snow)  --middle = no touch zone
	snow = snow or false
	if snow == false then
		compactor.close()

		local close_botguy, min_x_botguy = camera.find_botguy()
		print("min_x_botguy: " .. tostring(min_x_botguy) .. " close_botguy?: " .. tostring(close_botguy))

		compactor.open()
		drive:fd{inches = 22}
		
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
	else
		drive:fd{inches = 26}
		grabs.botguy_pvc()
		drive:fd{inches = 5}
	end
end

function go_under_island()
	drive:bk{inches = 2}
	drive:lturn{degrees = 90}
	
	compactor.open()
	drive:fd{inches = 24}
	drive:rpiv{degrees = 175}
	drive:fd{inches = 24}
	drive:fd{inches = 10}
	grabs.botguy_pvc()
	drive:fd{inches = 5}
	drive:bk{inches = 6}
	drive:rturn{degrees = 90}
end


function go_home(where)
	if where == "leg" then
		drive:lturn{degrees = 192}
		drive:fd{inches = 19}
	else
		drive:fd{inches = 27.5}
	end
	
	drive:rpiv{degrees = -30}
	drive:lpiv{degrees = 37}
	--drive:bk{inches = 1}
	--drive:bk{inches = 8, speed = 400}
	
	motion.drive_sensor("left", "fd", "no_pvc", 900, 500)
	drive:fd{inches = 2.5}
	drive:lturn{degrees = 95}
	drive:bk{inches = 5, speed = 400}
	--botball.game_time_sleep(92)
	motion.drive_sensor("left", "fd", "pvc", 900, 400)
	motion.drive_sensor("left", "fd", "no_pvc", 900, 350)
	drive:fd{inches = 3}
	
	drive:lturn{degrees = 97}
	--botball.game_time_sleep(112)
	drive:fd{inches = 28}
	drive:rturn{degrees = 190}
	grabs.release()
end

function summit()
	goto_pvc_island()
	local return_home_early
	return_home_early = grab_our_leg()
	if return_home_early then
		print("go home early: " .. tostring(return_home_early))
		go_home("leg")
		return
	end
	
	go_into_middle()	
	go_home("middle")
end

function snow()
	goto_pvc_island()
	grab_our_leg(true)
	go_into_middle(true)
	go_under_island()
	go_home("snow")
end
--[[
function go_home()
	drive:fd{inches = 27.5}
--	motion.drive_sensor("left", "bk", "pvc", 900, 500)
	--drive:bk{inches = 13}
	drive:rpiv{degrees = -30}
	drive:lpiv{degrees = 37}
	drive:bk{inches = 1}
	--drive:bk{inches = 8, speed = 400}
	
	motion.drive_sensor("left", "fd", "no_pvc", 900, 500)
	drive:fd{inches = 2.5}
	drive:lturn{degrees = 95}
	drive:bk{inches = 5, speed = 400}
	botball.game_time_sleep(92)
	motion.drive_sensor("left", "fd", "pvc", 900, 400)
	motion.drive_sensor("left", "fd", "no_pvc", 900, 350)
	drive:fd{inches = 3}
	
	drive:lturn{degrees = 97}
	botball.game_time_sleep(112)
	drive:fd{inches = 28}
	drive:rturn{degrees = 190}
	grabs.release()
end
]]--

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
