local cbc 			= require "cbclua.cbc"
local vision 		= require "cbclua.vision"
local servoutils 	= require "mb.servoutils"
local motorutils 	= require "mb.motorutils"
local drivemod      = require "mb.drive"

------------
-- Motors --
------------

ldrive 	= motorutils.FixMotor{0}
rdrive 	= motorutils.FixMotor{3}

extend_motor = motorutils.FixMotor{2}

drivetrain = drivemod.MotorDriveTrain{
	lmot = ldrive,
	rmot = rdrive,
	ticks = 97,
	rmult = .99,
	wb = 7.3
}
drive = drivemod.Drive{
	drivetrain = drivetrain,
	style = drivemod.Smooth{accel=10},
	topvel = 7,
}

------------
-- Servos --
------------

door_servo 	= servoutils.RescaleServo{1, start_pos = 400, end_pos = 1350}

------------
-- Vision --
------------

-------------
-- Sensors --
-------------

out_sensor = cbc.DigitalSensor{8}
in_sensor = cbc.DigitalSensor{9}