-- Ref: redemrp_inventory / https://discord.com/channels/192358910387159041/643437814104457217/805394367383732265
function ShowWeaponStats()
    local PlayerPed = PlayerPedId()
    local WeaponObject = GetObjectIndexFromEntityIndex(GetCurrentPedWeaponEntityIndex(PlayerPed , 0))
    local _, WeaponHash = GetCurrentPedWeapon(PlayerPed, true, 0, true)
    local Block = RequestFlowBlock(GetHashKey("PM_FLOW_WEAPON_INSPECT"))
    local Container = DatabindingAddDataContainerFromPath("" , "ItemInspection")
    -- exports["redemrp_weaponmods"]:GetWeaponStats(Container, WeaponHash)
    DatabindingAddDataBool(Container, "Visible", true)
    DatabindingAddDataString(Container, "tipText", GetLabelText(WeaponObject))
    DatabindingAddDataHash(Container, "itemLabel", WeaponHash)
    Citizen.InvokeNative(0x10A93C057B6BD944 ,Block)
    Citizen.InvokeNative(0x3B7519720C9DCB45	,Block, 0)
    Citizen.InvokeNative(0x4C6F2C4B7A03A266 ,-813354801, Block)
    Citizen.CreateThread(function()
        Wait(1000)
        while true do
            Wait(100)
            if not Citizen.InvokeNative(0x6AA3DCA2C6F5EB6D, PlayerPedId()) then
                Citizen.InvokeNative(0x4EB122210A90E2D8, -813354801)
                break
            end
        end
    end)
end
