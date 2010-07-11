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
	tribbles_pvc()
	task.sleep(0.5)
	extend(0.5)
end

function tribbles_pvc_bk(inches)
	close_half({wait = true})
	drive:bk{inches = inches}
	close()
end


function botguy_pvc()
	extend_full()
	close_half()
	drive:bk{inches = 2.5}
	close()
	retract()
end

function release()
	open()
	drive:bk{inches = 3}
end