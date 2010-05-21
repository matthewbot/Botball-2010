local task = require "cbclua.task"
local util = require "cbclua.util"
local table = require "table"

CommandQueue = create_class "CommandQueue"

function CommandQueue:construct(drivetrain)
	self.drivetrain = drivetrain
	self.queue = { }
	self.sig = task.Signal()
	self.topstate = { }
end

function CommandQueue:add(command)
	command:prepare(self.topstate)
	
	local altered = false
	if #self.queue > 0 then
		altered = command:alterQueue(self.queue)
	end
	
	if not altered then
		table.insert(self.queue, command)
	end
	
	self:start_task()
end

function CommandQueue:clear()
	self.queue = { }
	task.stop(self.task)
end

function CommandQueue:start_task()
	if self.task and self.task:get_state() ~= "stopped" then
		return
	end
	
	self.task = task.start(util.bind(self, "run"), "drive cq")
	self.task:register_cleanup(function ()
		self.queue = { }
	end)
end

function CommandQueue:run()
	while #self.queue >= 1 do
		local command = table.remove(self.queue, 1)
		command:run(self.drivetrain)
	end
end

-- Simple commands --

InlineCommand = create_class "InlineCommand"

function InlineCommand:construct(func)
	self.func = func
end

function InlineCommand:alterQueue(command)
end

function InlineCommand:run(drivetrain)
	return self.func(drivetrain)
end

SleepCommand = create_class "SleepCommand"

function SleepCommand:construct(time)
	self.time = time
end

function SleepCommand:alterQueue(queue)
	local topcommand = queue[#queue]
	if is_a(topcommand, SleepCommand) then
		topcommand.time = self.time + topcommand.time
		return true
	end
end

function SleepCommand:run(drivetrain)
	task.sleep(self.time)
end


