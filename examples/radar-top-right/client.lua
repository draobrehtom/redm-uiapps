-- The radar in the top-right corner. /radar moves it there and back.
-- Our scene draws its own copy of the radar (the game's Minimap widget, copied in without MAP_REGISTER_WITH_HUD
-- and without the HUD visibility slot) and the cores; the game's radar is hidden with a HUD context.

local root = DatabindingAddDataContainerFromPath('', 'RadarCopy')
DatabindingAddDataBool(root, 'visible', true) -- the scene binds RadarCopy.visible
local moved = false

local function showCopy()
    local block = Citizen.InvokeNative(0xC0081B34E395CE48, `uiapps_radar_flow`, Citizen.ResultAsInteger()) -- _UIFLOWBLOCK_REQUEST
    local deadline = GetGameTimer() + 5000
    while not Citizen.InvokeNative(0x10A93C057B6BD944, block) do -- _UIFLOWBLOCK_IS_LOADED
        if GetGameTimer() > deadline then return false end
        Wait(0)
    end
    Citizen.InvokeNative(0x3B7519720C9DCB45, block, 0)                      -- _UIFLOWBLOCK_ENTER
    Citizen.InvokeNative(0x4C6F2C4B7A03A266, `uiapps_radar_machine`, block) -- UI_STATE_MACHINE_CREATE
    return true
end

local function setMoved(on)
    if on == moved then return end
    if on then
        if not showCopy() then return print('uiapps_radar_flow did not load') end
        Citizen.InvokeNative(0x4CC5F2FC1332577F, `HUD_CTX_HACK_RADAR_FORCE_HIDE`) -- _ENABLE_HUD_CONTEXT: hide the game radar
    else
        Citizen.InvokeNative(0x8BC7C1F929D07BF3, `HUD_CTX_HACK_RADAR_FORCE_HIDE`) -- _DISABLE_HUD_CONTEXT
        Citizen.InvokeNative(0x4EB122210A90E2D8, `uiapps_radar_machine`)          -- UI_STATE_MACHINE_DESTROY
    end
    moved = on
end

RegisterCommand('radar', function()
    CreateThread(function() setMoved(not moved) end)
end, false)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    setMoved(false)
    DatabindingRemoveDataEntry(root)
end)
