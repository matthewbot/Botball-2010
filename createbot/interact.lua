import "config"
create = require "mb.create"

function dumptest()
	claw.close(); 
	task.sleep(1);
	claw.up{speed="full"}
	task.sleep(1);
	claw.release_basket();
	task.sleep(1);
	claw.down{wait=true}
	claw.open()
end

