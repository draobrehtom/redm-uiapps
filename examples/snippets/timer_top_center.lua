--[[
Ref: https://discord.com/channels/192358910387159041/643437867044962304/1258037080618041476
https://pastebin.com/XQuLBM8U
https://imgur.com/a/w5m0yoY
]]

local TimerUI = {}

local function formatTime(seconds) -- 01:00 format
    local minutes = math.floor(seconds / 60) 
    seconds = seconds - minutes * 60
    return string.format("%02d:%02d",minutes,seconds)
end


function TimerUI:init()
    TimerUI.data = {}
    TimerUI.data.uiFlowblock = Citizen.InvokeNative(0xC0081B34E395CE48, -119209833) 

    local temp = 0
    while not UiflowblockIsLoaded(TimerUI.data.uiFlowblock) do 
        temp = temp + 1
        if temp > 10000 then 
            print('Failed To Load Flowblock')
            return 
        end
        Citizen.Wait(1) 
    end

    if not Citizen.InvokeNative(0x10A93C057B6BD944, TimerUI.data.uiFlowblock) --[[ UIFLOWBLOCK_IS_LOADED ]] then
        print("uiflowblock failed to load")
        return
    end

    TimerUI.data.container =  DatabindingAddDataContainerFromPath("", "centralInfoDatastore")

    -- Must be set empty else a default "Message" text will overlap the time
    DatabindingAddDataString(TimerUI.data.container, "timerMessageString", "")

    TimerUI.data.timer = DatabindingAddDataString(TimerUI.data.container, "timerString", "") 
    TimerUI.data.show = DatabindingAddDataBool(TimerUI.data.container, "isVisible", false)

    UiflowblockEnter(TimerUI.data.uiFlowblock, `cTimer`)

    -- maybe add in while loop to make sure machine is created
    if UiStateMachineExists(1546991729) == 0 then
        TimerUI.data.stateMachine = UiStateMachineCreate(1546991729, TimerUI.data.uiFlowblock)
    end 

    -- Time Variable
    TimerUI.data.time = 0

    return TimerUI.data.stateMachine
end

-- To stop earlier
function TimerUI:stopTimer() 
    self.data.time = 0
    DatabindingWriteDataBool(self.data.show, false)
end

---@param time integer -- in seconds
---@param low? integer -- seconds at which timer color will turn to red
function TimerUI:startTimer(time, low) -- in seconds
    if self.data == nil or UiStateMachineExists(1546991729) == 0 then return end
    DatabindingWriteDataBool(self.data.show, true)
    self.data.time = time or 60

    while self.data.time >=1 do
        DatabindingWriteDataString(self.data.timer ,formatTime(self.data.time))
        self.data.time = self.data.time - 1
        Wait(1000)
        if low and self.data.time <= low then
            DatabindingAddDataBool(self.data.container, "isTimerLow", true) -- Makes Timer Color as Red
        end
        if self.data.time <= 0 then
            TimerUI:finishTimer()
        end
    end
end

function TimerUI:finishTimer()
    UiStateMachineDestroy(1546991729)
    if DatabindingIsEntryValid(self.data.container) then
        print('Removed Container')
        DatabindingRemoveDataEntry(self.data.container)
    end
    if DatabindingIsEntryValid(self.data.timer) then
        print('Removed Timer String')
        DatabindingRemoveDataEntry(self.data.timer)
    end
    if DatabindingIsEntryValid(self.data.show) then
        print('Removed Show Bool')
        DatabindingRemoveDataEntry(self.data.show)
    end
end

-- Start Timer
RegisterCommand("startTime", function()
    TimerUI:init()
    TimerUI:startTimer(20, 5)
end)

-- Stop Timer in between
RegisterCommand("stopTime", function()
    TimerUI:stopTimer() 
end)
