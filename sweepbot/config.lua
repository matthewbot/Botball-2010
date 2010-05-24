local cbc 			= require "cbclua.cbc"
local vision 		= require "cbclua.vision"
local servoutils 	= require "mb.servoutils"
local motorutils 	= require "mb.motorutils"

------------
-- Motors --
------------

ldrive 	= motorutils.JerkFixMotor{0}
rdrive 	= motorutils.JerkFixMotor{3}
dumper_motor = motorutils.JerkFixMotor{1}

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