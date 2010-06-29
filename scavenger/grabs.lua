import "compactor"
import "config"

local task = require "cbclua.task"

local time_full = 25
--open, then extend

function tribbles() --need to alter when i find if motor or servo commands are blocking
	open()
	extend_full()
	close_half()
	close({wait = true})
	retract_full()
end

function tribbles_pvc()
	close_half()
	close()
end

function tribbles_pvc_full()
	grabs.tribbles_pvc()
	task.sleep(0.5)
	compactor.extend(0.5)
end

function tribbles_pvc_bk(inches)
	close_half({wait = true})
	drive:bk{inches = inches}
	close()
end


function botguy_pvc()
	extend_full()
	close_half()
	drive:bk{inches = 3}
	close()
end

function release()
	open()
	drive:bk{inches = 3}
end



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