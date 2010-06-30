local task = require "cbclua.task"
import "arm"


function activate()					-- activates the arm for sweeping
	print "Activating"
	pitch(350, 400)
	wait()
	extend(400, 400)
	wait()
	pitch(150, 400)
	wait()
end

function init()					-- initializes and activatest the arm for sweeping
	reset()
	activate()
end

function palms_sweep()				-- sweeps palms
	pitch(850, 600)
	extend(700, 700)
	wait()
	extend(530, 400)
	wait()
end

function palms_retract()			-- retracts the palms
	extend(300, 460)
	pitch(200, 800)
	wait()
	pitch(100, 350)
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
	pitch(150, 300)
	extend(400, 300)
end

function palms()
	palms_sweep()
	task.sleep(.2)
	palms_retract()
end

function botguy()
	botguy_sweep()
	task.sleep(.2)
	botguy_retract()
end