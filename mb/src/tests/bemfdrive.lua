local drivemod = require "mb.drive"
local motorutils = require "mb.motorutils"
local cbc = require "cbclua.cbc"

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
	style = drivemod.Smooth{accel=15}
}

function drive_error(inches, speed)
	local lenc, renc = drivetrain:getEncoders()
	
	drive:fd{inches=inches, speed=speed}
	drive:wait()
	
	local lnewenc, rnewenc = drivetrain:getEncoders()
	
	print("Distance error", inches - (lnewenc - lenc), inches - (rnewenc - renc))
	print("Veer error", (lnewenc - lenc) - (rnewenc - renc), (rnewenc - renc) - (lnewenc - lenc))
end
	

