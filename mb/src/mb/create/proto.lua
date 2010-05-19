local bit = require "cbclua.bit"

-- names come from create OI

Start = 128
Safe = 131
Full = 132
Demo = 136
Drive = 137
DriveDirect = 145
LEDs = 139
Song = 140
PlaySong = 141
Sensors = 142
QueryList = 149
Stream = 148
PauseResumeStream = 150
Script = 152
PlayScript = 153
WaitTime = 155
WaitDistance = 156
WaitAngle = 157
WaitEvent = 158

BumpsAndWheelDrops = 7
ZeroSensorByteA = 15
Buttons = 18
Voltage = 22
WallSignal = 27
CliffLeftSignal = 28
CliffFrontLeftSignal = 29
CliffFrontRightSignal = 30
CliffRightSignal = 31
OIMode = 35
LeftEncoder = 43
RightEncoder = 44

Advance = bit.flag(3)
Play = bit.flag(1)

BumpRight = bit.flag(0)
BumpLeft = bit.flag(1)
WheeldropRight = bit.flag(2)
WheeldropLeft = bit.flag(3)
WheeldropCaster = bit.flag(4)
