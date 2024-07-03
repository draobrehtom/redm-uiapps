-- Ref: https://discord.com/channels/192358910387159041/643437814104457217/1023938148243341432
local scoreboard = false
RegisterCommand("scoreboard", function(source, args, raw)
    TriggerEvent("scoreboard")
   
end)
RegisterNetEvent("scoreboard", function()
    if scoreboard then 
        scoreboard = false 
        return
    else
        scoreboard = true
    end
    local team1 = "TEAM 1"
    local team2 = "TEAM 2"
    local score1 = 1
    local score2 = 2

    local a = DatabindingAddDataContainerFromPath("", "helperTextfields");
    DatabindingAddDataString(a, "rawLabel0", team1);
    DatabindingAddDataString(a, "rawLabel1", team2);
    DatabindingAddDataString(a, "rawValue0", tostring(score1));
    DatabindingAddDataString(a, "rawValue1", tostring(score2));
    while scoreboard do 
        Citizen.Wait(1)
        Citizen.InvokeNative(0xC9CAEAEEC1256E54, -66088566)
    end
end)
