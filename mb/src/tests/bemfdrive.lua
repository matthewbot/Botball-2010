local drivemod = require "mb.drive"
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
	style = drivemod.Smooth{}
}

