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


--- OR: https://discord.com/channels/846719561020473364/987235576308703292/1146012003983429642

local scoreboard = false
local function ScoreBoardUI(ui_data)
    if scoreboard then 
        scoreboard = false 
        return
    else
        scoreboard = true
    end

    local a = {}
    a.container = DatabindingAddDataContainerFromPath("", "helperTextfields");
    a.rawLabel0 = DatabindingAddDataString(a.container, "rawLabel0", ui_data.team1);
    a.rawLabel1 = DatabindingAddDataString(a.container, "rawLabel1", ui_data.team2);
    a.rawValue0 = DatabindingAddDataString(a.container, "rawValue0", tostring(ui_data.score1));
    a.rawValue1 = DatabindingAddDataString(a.container, "rawValue1", tostring(ui_data.score2));
    self = {
        container = a,
        ui_data = ui_data,
        updating = false,
        Update = function(newInfo)
            for i,v in pairs(newInfo) do 
                ui_data[i] = v 
                DatabindingWriteDataString(self.container[i], v)
            end
        end,
        Close = function()
            scoreboard = false
            DatabindingRemoveDataEntry(self.container.container)
        end
    }
    return self
end

Citizen.CreateThread(function()
    while true do
        local t = 1
        if scoreboard then 
            Citizen.InvokeNative(0xC9CAEAEEC1256E54, -66088566)
        else
            t = 500
        end
        Wait(t)
    end
end)

RegisterCommand("score_ui", function(source, args, raw)
    local score_data = {
        team1 = "TEAM 1",
        team2 = "TEAM 2",
        score1 = 1,
        score2 = 2,
    }
    local score_ui = ScoreBoardUI(score_data)
    Wait(0)
    score_ui.Update({rawLabel0 = "New Team 1", rawLabel1 = "New Team 2", rawValue0 = "0", rawValue1 = "0"})
    Wait(2000)
    score_ui.Update({rawValue0 = "1", rawValue1 = "0"})
    Wait(2000)
    score_ui.Update({rawValue0 = "1", rawValue1 = "1"})
    Wait(2000)
    score_ui.Update({rawValue0 = "2", rawValue1 = "1"})
    Wait(2000)
    score_ui.Update({rawValue0 = "3", rawValue1 = "1"})
    Wait(2000)
    score_ui.Close()
end)
