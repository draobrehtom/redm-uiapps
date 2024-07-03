-- Ref: https://github.com/zelbeus/ricx_native_wanted_ui/blob/main/client.lua

Citizen.CreateThread(function()
    if Config.CustomTexts then 
        for i,v in pairs(Config.CustomTexts) do 
            if not GetLabelText(i) then 
                AddTextEntry(i, v)
            end
        end
    end
end)


local function CreateWantedText(id, cont, dat)
    local a = {}
    a[1] = DatabindingAddDataContainer(cont, id)
    a[2] = DatabindingAddDataBool(a[1], "showMessage", dat.showMessage)
    a[3] = DatabindingAddDataString(a[1], "upperLocText", dat.upperLocText)
    a[4] = DatabindingAddDataInt(a[1], "upperTextStyle", dat.upperTextStyle)
    a[5] = DatabindingAddDataString(a[1], "lowerText0", dat.lowerText0)
    a[6] = DatabindingAddDataString(a[1], "lowerText1", dat.lowerText1)
    a[7] = DatabindingAddDataString(a[1], "lowerText2", dat.lowerText2)
    a[8] = DatabindingAddDataString(a[1], "lowerText3", dat.lowerText3)
    a[9] = DatabindingAddDataString(a[1], "lowerRawText0", dat.lowerRawText0)
    a[10] = DatabindingAddDataString(a[1], "lowerRawText1", dat.lowerRawText1)
    a[11] = DatabindingAddDataString(a[1], "lowerRawText2", dat.lowerRawText2)
    a[12] = DatabindingAddDataString(a[1], "lowerRawText3", dat.lowerRawText3)
    a[13] = DatabindingAddDataInt(a[1], "switchLowerTextToIndex", dat.switchLowerTextToIndex)
    a[14] = DatabindingAddDataBool(a[1], "showKnownPulse", dat.showKnownPulse)
    a[15] = DatabindingAddDataBool(a[1], "showUnknownPulse", dat.showUnknownPulse)
    a[16] = DatabindingAddDataBool(a[1], "showShortWantedCooldown", dat.showShortWantedCooldown)
    a[17] = DatabindingAddDataBool(a[1], "showLongWantedCooldown", dat.showLongWantedCooldown)
    a[18] = DatabindingAddDataBool(a[1], "showWarningAnimation", dat.showWarningAnimation)
    return a
end

function WantedUI(ui_datas)

    local a = {}
    if not LocalPlayer.state.ricx_native_ui_wanted then 
        a.container = DatabindingAddDataContainerFromPath("", "wanted")
        a.f_1 = DatabindingAddDataBool(a.container, "showBountyHunterMessage", true)
        local dats = {
            [1] = {showMessage = true, upperLocText = "LAW_UI_WANTED_M", upperTextStyle = 0, lowerText0 = "1", lowerText1 = "2", lowerText2 = "3", lowerText3 = "4",
            lowerRawText0 = "r0", lowerRawText1 = "r1", lowerRawText2 = "r2", lowerRawText3 = "r3", switchLowerTextToIndex = 0, showKnownPulse = false,
            showShortWantedCooldown = false, showLongWantedCooldown = false, showWarningAnimation = true
            },
            [2] = {showMessage = false, upperLocText = "LAW_UI_WANTED_M", upperTextStyle = 0, lowerText0 = "1", lowerText1 = "2", lowerText2 = "3", lowerText3 = "4",
            lowerRawText0 = "r0", lowerRawText1 = "r1", lowerRawText2 = "r2", lowerRawText3 = "r3", switchLowerTextToIndex = 0, showKnownPulse = false,
            showShortWantedCooldown = false, showLongWantedCooldown = false, showWarningAnimation = false
            },
            [3] = {showMessage = false, upperLocText = "LAW_UI_WANTED_M", upperTextStyle = 0, lowerText0 = "1", lowerText1 = "2", lowerText2 = "3", lowerText3 = "4",
            lowerRawText0 = "r0", lowerRawText1 = "r1", lowerRawText2 = "r2", lowerRawText3 = "r3", switchLowerTextToIndex = 0, showKnownPulse = false,
            showShortWantedCooldown = false, showLongWantedCooldown = false, showWarningAnimation = false
            }
        }
        a.f_2 = CreateWantedText("firstMessage", a.container, dats[1])
        a.f_3 = CreateWantedText("secondMessage", a.container, dats[2])
        a.f_4 = CreateWantedText("thirdMessage", a.container, dats[3])
        Citizen.InvokeNative(0xC9CAEAEEC1256E54, -1618603322)
        LocalPlayer.state:set("ricx_native_ui_wanted", a, true)
    else
        a = LocalPlayer.state.ricx_native_ui_wanted
        a.f_1 = DatabindingAddDataBool(a.container, "showBountyHunterMessage", false)
        Citizen.InvokeNative(0xC9CAEAEEC1256E54, -1618603322)
    end
    
    self = {
        container = a,
        ui_data = ui_datas,
        updating = false,
        Update = function(newInfo)
            if not self.updating then 
                self.updating = true 
                if newInfo.showBountyHunterMessage ~= nil then 
                    ui_data.showBountyHunterMessage = newInfo.showBountyHunterMessage
                    DatabindingWriteDataBool(self.container.f_1, newInfo.showBountyHunterMessage)
                end
                if newInfo.f_2 or newInfo.f_3 or newInfo.f_4 then 
                    for i,v in pairs(newInfo) do 
                        if i == "f_2" or i == "f_3" or i == "f_4" then
                            if not ui_data then ui_data = {} end
                            if not ui_data[i] then ui_data[i] = {} end
                            for c,k in pairs(v) do 
                                if c == "showMessage" then 
                                    if k ~= nil then 
                                        ui_data[i].showMessage = k
                                        DatabindingWriteDataBool(self.container[i][2], k)
                                    end
                                end
                                if c == "upperLocText" then 
                                    if k ~= nil then 
                                        if Config.CustomTexts then 
                                            ui_data[i].upperLocText = GetLabelText(Config.CustomTexts[k])
                                            if not ui_data[i].upperLocText then 
                                                ui_data[i].upperLocText = k
                                            end
                                        else
                                            ui_data[i].upperLocText = k
                                        end
                                        DatabindingWriteDataString(self.container[i][3], k)
                                    end
                                end
                                if c == "upperTextStyle" then 
                                    if k ~= nil then 
                                        ui_data[i].upperTextStyle = k
                                        DatabindingWriteDataInt(self.container[i][4], k)
                                    end
                                end
                                if c == "lowerText0" then 
                                    if k ~= nil then 
                                        ui_data[i].lowerText0 = k
                                        DatabindingWriteDataString(self.container[i][5], k)
                                    end
                                end
                                if c == "lowerText1" then 
                                    if k ~= nil then 
                                        ui_data[i].lowerText1 = k
                                        DatabindingWriteDataString(self.container[i][6], k)
                                    end
                                end
                                if c == "lowerText2" then 
                                    if k ~= nil then 
                                        ui_data[i].lowerText2 = k
                                        DatabindingWriteDataString(self.container[i][7], k)
                                    end
                                end
                                if c == "lowerText3" then 
                                    if k ~= nil then 
                                        ui_data[i].lowerText3 = k
                                        DatabindingWriteDataString(self.container[i][8], k)
                                    end
                                end
                                if c == "lowerRawText0" then 
                                    if k ~= nil then 
                                        ui_data[i].lowerRawText0 = k
                                        DatabindingWriteDataString(self.container[i][9], k)
                                    end
                                end
                                if c == "lowerRawText1" then 
                                    if k ~= nil then 
                                        ui_data[i].lowerRawText1 = k
                                        DatabindingWriteDataString(self.container[i][10], k)
                                    end
                                end
                                if c == "lowerRawText2" then 
                                    if k ~= nil then 
                                        ui_data[i].lowerRawText2 = k
                                        DatabindingWriteDataString(self.container[i][11], k)
                                    end
                                end
                                if c == "lowerRawText3" then 
                                    if k ~= nil then 
                                        ui_data[i].lowerRawText3 = k
                                        DatabindingWriteDataString(self.container[i][12], k)
                                    end
                                end
                                if c == "switchLowerTextToIndex" then 
                                    if k ~= nil then 
                                        ui_data[i].switchLowerTextToIndex = k
                                        DatabindingWriteDataInt(self.container[i][13], k)
                                    end
                                end
                                if c == "showKnownPulse" then 
                                    if k ~= nil then 
                                        ui_data[i].showKnownPulse = k
                                        DatabindingWriteDataBool(self.container[i][14], k)
                                    end
                                end
                                if c == "showUnknownPulse" then 
                                    if k ~= nil then 
                                        ui_data[i].showUnknownPulse = k
                                        DatabindingWriteDataBool(self.container[i][15], k)
                                    end
                                end
                                if c == "showShortWantedCooldown" then 
                                    if k ~= nil then 
                                        ui_data[i].showShortWantedCooldown = k
                                        DatabindingWriteDataBool(self.container[i][16], k)
                                    end
                                end
                                if c == "showLongWantedCooldown" then 
                                    if k ~= nil then 
                                        ui_data[i].showLongWantedCooldown = k
                                        DatabindingWriteDataBool(self.container[i][17], k)
                                    end
                                end
                                if c == "showWarningAnimation" then 
                                    if k ~= nil then 
                                        ui_data[i].showWarningAnimation = k
                                        DatabindingWriteDataBool(self.container[i][18], k)
                                    end
                                end
                            end
                        end
                    end
                end
                self.updating = false 
            else
                print("wait til Wanted UI updated fully before changing")
            end
        end,
        Open = function()
            DatabindingWriteDataBool(self.container.f_1, true)
            DatabindingWriteDataBool(self.container.f_2[2], true)
        end,
        Close = function()
            ui_data = {}
            DatabindingWriteDataBool(self.container.f_1, false)
            DatabindingWriteDataBool(self.container.f_2[2], false)
        end
    }
    return self
end
