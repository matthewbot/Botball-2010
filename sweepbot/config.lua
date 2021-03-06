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
dumper_motor = motorutils.FixMotor{1}

drivetrain = drivemod.MotorDriveTrain{
	lmot = ldrive,
	rmot = rdrive,
	ticks = 92,
	rmult = 1.02,
	wb = 6.9
}

fdrivetrain = drivemod.MotorDriveTrain{
	lmot = ldrive,
	rmot = rdrive,
	ticks = 92,
	rmult = .97,
	wb = 7.2
}

drive = drivemod.Drive{
	drivetrain = drivetrain,
	style = drivemod.Smooth{accel=10, turnaccel=6},
	topvel = 7,
	topvel_turn = 2.8
}

fdrive = drivemod.Drive{
	drivetrain = fdrivetrain,
	style = drivemod.Smooth{accel=20},
	topvel = 10,
}

bdrive = drivemod.Drive{
	drivetrain = drivetrain,
	style = drivemod.BangBang(),
	topvel = 7,
}

------------
-- Servos --
------------

extend_servo 	= servoutils.RescaleServo{2, start_pos=2000, end_pos=500}
pitch_servo 	= servoutils.RescaleServo{1, start_pos=0, end_pos=1050}

------------
-- Vision --
------------

-------------
-- Sensors --
-------------

lrange = cbc.AnalogSensor{0, float = true}
rrange = cbc.AnalogSensor{1, float = true}
platform_range_sensor = cbc.AnalogSensor{2, float = true}
starting_light = cbc.AnalogSensor{3}

lwall_bumper = cbc.DigitalSensor{14}
rwall_bumper = cbc.DigitalSensor{15}
