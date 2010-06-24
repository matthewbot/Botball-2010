local create = require "mb.create"
import "mb.create.script"

sweep_position = Script{
	drive_direct(500, 500),
	wait_dist(33),
	drive_direct(500, 0),
	wait_angle(-57),
	drive_direct(500, 500),
	wait_dist(28),
}
