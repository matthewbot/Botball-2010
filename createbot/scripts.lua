local create = require "mb.create"
import "mb.create.script"

sweep_position = Script{
	drive_direct(500, 500),
	wait_dist(33),
	drive_direct(500, -500),
	wait_angle(-54),
	drive_direct(500, 500),
	wait_dist(32),
	drive_direct(500, -500),
	wait_angle(-4),
	drive_direct(0, 0),
}

