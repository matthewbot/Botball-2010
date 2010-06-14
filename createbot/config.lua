local servoutils = require "mb.servoutils"
local motorutils = require "mb.motorutils"
local drivemod = require "mb.drive"
 
grip_servo = servoutils.SpeedControlServo{1}
updown_servo = servoutils.SpeedControlServo{2}

drivetrain = drivemod.CreateDriveTrain{wb = 10.11, flip = true}
drive = drivemod.Drive{
	drivetrain = drivetrain,
	style = drivemod.Smooth{accel=20},
	topvel = 19
}

launch_motor = motorutils.FixMotor{1}

