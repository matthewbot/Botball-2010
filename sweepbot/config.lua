local cbc 			= require "cbclua.cbc"
local vision 		= require "cbclua.vision"
local servoutils 	= require "mb.servoutils"
local motorutils 	= require "mb.motorutils"
local drivemod      = require "mb.drive"

------------
-- Motors --
------------

ldrive 	= motorutils.JerkFixMotor{0, pid={d=0}}
rdrive 	= motorutils.JerkFixMotor{1, pid={d=0}}
dumper_motor = motorutils.JerkFixMotor{2}

print("blah", ldrive, rdrive)
drivetrain = drivemod.MotorDriveTrain{
	lmot = ldrive,
	rmot = rdrive,
	ticks = 100,
	rmult = 1,
	wb = 7
}
drive = drivemod.Drive{
	drivetrain = drivetrain,
	style = drivemod.Smooth{accel=10},
	topvel = 3,
}

------------
-- Servos --
------------

extend_servo 	= servoutils.RescaleServo{2, start_pos=2000, end_pos=500}
pitch_servo 	= servoutils.RescaleServo{1, start_pos=0, end_pos=1050}

------------
-- Vision --
------------

green_channel = vision.Channel(0)

-------------
-- Sensors --
-------------

lrange = cbc.AnalogSensor{0, float = true}
rrange = cbc.AnalogSensor{1, float = true}
wall_bumper = cbc.DigitalSensor{15}