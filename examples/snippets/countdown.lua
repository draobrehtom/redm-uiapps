-- Ref: https://discord.com/channels/192358910387159041/643437867044962304/1255254880101335152
RegisterCommand("textCountDown", function()
    local timer = 10 -- 10 Second timer.
    
    local container = DatabindingAddDataContainerFromPath("", "MPCountdown")
    local dataString = DatabindingAddDataString(container, "Timer", timer)
    local dataBoolean = DatabindingAddDataBool(container, "showTimer", true)
    
    for i = timer, 1, -1 do
        DatabindingWriteDataString(dataString, i)
        Citizen.Wait(1000)
    end

    if UiStateMachineExists(190275865) then
        UiStateMachineDestroy(190275865)
    end

    if DatabindingIsEntryValid(dataString) then
        DatabindingRemoveDataEntry(dataString)
    end

    if DatabindingIsEntryValid(dataBoolean) then
        DatabindingWriteDataBool(dataBoolean, false);
        DatabindingRemoveDataEntry(dataBoolean)
    end

    if DatabindingIsEntryValid(container) then
        DatabindingRemoveDataEntry(container)
    end
end, false)
