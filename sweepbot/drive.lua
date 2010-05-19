import "config"

---------------------
-- Drive Functions --
---------------------

function drive_motors(lspeed, rspeed)
	ldrive:mav(lspeed)
	rdrive:mav(rspeed)
end

function drive_stop()
	ldrive:off()
	rdrive:off()
end

function drive_move(lspeed, rspeed, time)
	drive_motors(lspeed, rspeed)
	task.sleep(time)
	drive_stop()
end

function drive_fd(time, speed)
	speed = speed or 800
	drive_move(speed, speed, time)
end

function drive_bk(time, speed)
	speed = speed or 800
	drive_move(-speed, -speed, time)
end

function drive_lturn(time, speed)
	speed = speed or 800
	drive_move(-speed, speed, time)
end

function drive_rturn(time, speed)
	speed = speed or 800
	drive_move(speed, -speed, time)
end
