 local servoutils = require "mb.servoutils"
 local drivemod = require "mb.drive"
 
 grip_servo = servoutils.SpeedControlServo{1}
 updown_servo = servoutils.SpeedControlServo{2}
 
 drivetrain = drivemod.CreateDriveTrain{}
 drive = drivemod.Drive{
	drivetrain = drivetrain,
	style = drivemod.Smooth{accel=20},
	topvel = 19
}
