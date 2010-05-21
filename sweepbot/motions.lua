local task = require "cbclua.task"
import "sweep"

function activate()
	pitch(250, 400)
	wait()
	extend(400, 400)
	wait()
	pitch(150, 400)
	wait()
end

function palms_sweep()
	pitch(850, 600)
	extend(700, 700)
	wait()
	extend(530, 400)
	wait()
end

function palms_retract()
	print "Retracting Palms"
	extend(300, 460)
	pitch(200, 800)
	wait()
	pitch(150, 400)
	extend(400, 400)
	wait()
end

function botguy_sweep()
	pitch(900, 600)
	extend(1000, 700)
	wait()
	extend(800, 400)
	wait()
end

function botguy_retract()
	pitch(400, 400)
	extend(525, 400)
	wait()
	pitch(150, 400)
	extend(400, 400)
end
