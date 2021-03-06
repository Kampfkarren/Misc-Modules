--[[
	Timer Class
	
	Acts as a simple timer, with basic count up/count down capabilities, with events.
	
	Programmed by @Reshiram110
	
	Last updated : 10-17-2018 @ 2:03 AM EST
--]]

---------------------
-- Roblox Services --
---------------------
local RunService=game:GetService("RunService")

-------------
-- DEFINES --
-------------
local Timer={}



----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RunTimer
-- @Description : Runs the timer until the time position reaches Max_Time or Min_Time, or until Timer.Running is false.
--                Whether or not it increments/decrements the TimePosition is determined by Timer.Mode.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function RunTimer(Timer)
	Timer.IsRunning=true
	Timer.Events.Started:Fire()
	
	local LastStartTick=tick()
	
	while Timer.IsRunning do
		local Delta=RunService.Heartbeat:wait()
		
		if Timer.Mode=="Up" then
			Timer.TimePosition=math.min(Timer.TimePosition+Delta,Timer.MaxTime)
		elseif Timer.Mode=="Down" then
			Timer.TimePosition=math.max(Timer.TimePosition-Delta,Timer.MinTime)
		else --Invalid mode.
			warn("[Timer] Timer '"..Timer.Name.."' was set to an invalid mode : '"..Timer.Mode.."'")
			Timer.IsRunning=false
		end
		
		if tick()-LastStartTick>=Timer.TickInterval then --Fire the tick signal, the tick interval is up
			warn(Timer.TimePosition)
			Timer.Events.Tick:Fire()
			LastStartTick=tick()
		end
		
		if Timer.TimePosition==Timer.MaxTime or Timer.TimePosition==Timer.MinTime then Timer.IsRunning=false end
		print("TIME POSITION : "..Timer.TimePosition)
	end
	Timer.Events.Stopped:Fire()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : New
-- @Description : Creates a new instance of the timer class and returns it.
-- @Params : string "Name" - The name of the timer.
--           Number "Max_Time" - The maximum time value of the timer.
--           string "Timer_Mode" - The mode of the timer.
--           Number "Tick_Interval" - The interval (in seconds) to update the timer.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Timer.new(Name,Timer_Mode,Max_Time,Tick_Interval)
	local NewTimer={
		Name=Name or "Timer",
		MinTime=0,
		MaxTime=Max_Time or math.huge,
		TickInterval=Tick_Interval or 1,
		
		TimePosition=Max_Time or 0,
		Mode=Timer_Mode or "Down",
		IsRunning=false,
		
		Events={
			Started=Instance.new('BindableEvent'),
			Stopped=Instance.new('BindableEvent'),
			Tick=Instance.new('BindableEvent'),
		},
	}
	NewTimer.Started=NewTimer.Events.Started.Event
	NewTimer.Stopped=NewTimer.Events.Stopped.Event
	NewTimer.Tick=NewTimer.Events.Tick.Event
	if (NewTimer.Mode~="Down" and NewTimer.Mode~="Up") then NewTimer.Mode="Down" end
	
	setmetatable(NewTimer,{__index=Timer})
	
	return NewTimer
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Starts the timer.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Timer:Start()
	self:Reset()
	coroutine.wrap(RunTimer)(self)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Stop
-- @Description : Stops the timer.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Timer:Stop()
	if self.IsRunning then
		self.IsRunning=false
		self.Stopped:wait()
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Resume
-- @Description : Resumes the timer.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Timer:Resume()
	coroutine.wrap(RunTimer)(self)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Reset
-- @Description : Resets the timer.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Timer:Reset()
	self:Stop()
	if self.Mode=="Up" then
		self.TimePosition=self.MinTime
	elseif self.Mode=="Down" then
		self.TimePosition=self.MaxTime
	else --Invalid mode
		warn("[Timer] Timer '"..self.Name.."' was set to an invalid mode : '"..self.Mode.."'")
	end
end

return Timer
