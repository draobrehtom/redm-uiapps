-- /matchhud   shows the HUD built by build.py and plays a short fake match on it. Run again to close.

local set, root = Store('MatchHud')
local WHITE, RED = 0, 3 -- indexes into PALETTE of tools/uiscene.py

-- every bound path exists before the scene opens
set('visible', true)
set('blue', '0'); set('red', '0'); set('timer', ''); set('timerColor', WHITE)
set('objective', ''); set('objectiveVisible', false); set('capture', 0.0)
for i = 1, 4 do set('feed' .. i, ''); set('feed' .. i .. 'Visible', false) end

local open = false

local function show()
    local block = Citizen.InvokeNative(0xC0081B34E395CE48, `match_hud_flow`, Citizen.ResultAsInteger()) -- _UIFLOWBLOCK_REQUEST
    while not Citizen.InvokeNative(0x10A93C057B6BD944, block) do Wait(0) end                       -- _UIFLOWBLOCK_IS_LOADED
    Citizen.InvokeNative(0x3B7519720C9DCB45, block, 0)                    -- _UIFLOWBLOCK_ENTER
    Citizen.InvokeNative(0x4C6F2C4B7A03A266, `match_hud_machine`, block)  -- UI_STATE_MACHINE_CREATE
end

local function hide()
    Citizen.InvokeNative(0x4EB122210A90E2D8, `match_hud_machine`)         -- UI_STATE_MACHINE_DESTROY
end

local feed = {}
local function kill(text)
    table.insert(feed, 1, text)
    for i = 1, 4 do
        set('feed' .. i, feed[i] or '')
        set('feed' .. i .. 'Visible', feed[i] ~= nil)
    end
end

RegisterCommand('matchhud', function()
    open = not open
    if not open then return hide() end
    CreateThread(function()
        show()
        set('objective', 'Hold the bank')
        set('objectiveVisible', true)
        local endsAt = GetGameTimer() + 60000
        while open and GetGameTimer() < endsAt do
            local left = math.ceil((endsAt - GetGameTimer()) / 1000)
            set('timer', ('%d:%02d'):format(left // 60, left % 60))
            set('timerColor', left <= 10 and RED or WHITE)
            set('capture', (60 - left) / 60)
            if left % 15 == 0 then kill(('Outlaw %d  x  Lawman %d'):format(left, 60 - left)) end
            set('blue', tostring((60 - left) // 15))
            Wait(250)
        end
    end)
end, false)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    hide()
    DatabindingRemoveDataEntry(root)
end)
