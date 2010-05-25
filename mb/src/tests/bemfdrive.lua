local drivemod = require "mb.drive"
local motorutils = require "mb.motorutils"
local cbc = require "cbclua.cbc"
local util = require "cbclua.util"
local task = require "cbclua.task"

lmot = cbc.Motor{0}
rmot = cbc.Motor{3}

drivetrain = drivemod.MotorDriveTrain{
	lmot = lmot,
	rmot = rmot,
	ticks = 100,
	rmult = 1,
	wb = 7
}

drive = drivemod.Drive{
	drivetrain = drivetrain,
	style = drivemod.Smooth{}
}

bdrive = drivemod.Drive{
	drivetrain = drivetrain,
	style = drivemod.BangBang()
}

function drive_error(inches, speed)
	local lenc, renc = drivetrain:get_encoders()
	
	drive:fd{inches=inches, speed=speed}
	
	local lnewenc, rnewenc = drivetrain:get_encoders()
	
	print("Distance error", inches - (lnewenc - lenc), inches - (rnewenc - renc))
	print("Veer error", (lnewenc - lenc) - (rnewenc - renc), (rnewenc - renc) - (lnewenc - lenc))
end
	
function find_top_speeds()
	print("Robot will travel at full speed for 2 seconds!")
	util.wait_continue()
	
	lmot:fd()
	rmot:fd()
	task.sleep(.5) -- let them get up to speed
	
	local lstart, rstart = drivetrain:get_encoders()
	task.sleep(1)
	local lend, rend = drivetrain:get_encoders()
	lmot:off()
	rmot:off()
	
	print("Top speeds", lend - lstart, rend - rstart)
end
	
	