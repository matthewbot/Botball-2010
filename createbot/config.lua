local servoutils = require "mb.servoutils"
local motorutils = require "mb.motorutils"
local drivemod = require "mb.drive"
local cbc = require "cbclua.cbc"
 
grip_servo = servoutils.SpeedControlServo{1}
updown_servo = servoutils.SpeedControlServo{2}
pivot_servo = servoutils.SpeedControlServo{3}

drivetrain = drivemod.CreateDriveTrain{wb=10.2, flip = true}
drive = drivemod.Drive{
	drivetrain = drivetrain,
	style = drivemod.Smooth{accel=20, turnaccel=10, deaccel_fudge=0.3},
	topvel = 19,
	topvel_turn = 8
}
bdrive = drivemod.Drive{
	drivetrain = drivetrain,
	style = drivemod.BangBang(),
	topvel = 19
}

launch_motor = motorutils.FixMotor{1}
spool_motor = motorutils.FixMotor{2}
sponge_motor = motorutils.FixMotor{3, pid = {i=.3, d=0}}

sponge_reset = cbc.DigitalSensor{10}

