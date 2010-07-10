local create = require "mb.create"
import "mb.create.script"

--[[sweep_position = Script{
	drive_direct(500, 500),
	wait_dist(31),
	drive_direct(0, 0),
	wait_time(.3),
	drive_direct(250, 0),
	wait_angle(-75),
	drive_direct(0, 0),
	wait_time(.3),
	drive_direct(500, 500),
	wait_dist(28),
}]]

sweep_position = Script{
	drive_direct(500, 500),
	wait_dist(36),
	drive_direct(0, 0),
	wait_time(.1),
	drive_direct(400, 0),
	wait_angle(-84),
	drive_direct(0, 0),
	wait_time(.1),
	drive_direct(500, 500),
	wait_dist(27),
	drive_direct(0, 0)
}

