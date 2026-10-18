-- A UI app of its own. The flow block luman_uiapp_flow and the scene luman_uiapp_scene do not exist in the game:
-- they are streamed from this resource. A new name loads; a file that replaces a game file does not.
-- /myapp [text]   shows the card; Backspace / Esc (INPUT_FRONTEND_CANCEL) or 20 s closes it.

local MACHINE = `luman_uiapp_machine`
local open = false

local function showApp(title, body, footer)
    if open then return end
    open = true

    -- the scene's texts read these paths: ScriptDatastoreRoot.LumanApp.title / body / footer
    local root = DatabindingAddDataContainerFromPath('', 'LumanApp')
    local hTitle = DatabindingAddDataString(root, 'title', title)
    DatabindingAddDataString(root, 'body', body)
    DatabindingAddDataString(root, 'footer', footer)

    local block = Citizen.InvokeNative(0xC0081B34E395CE48, `luman_uiapp_flow`, Citizen.ResultAsInteger()) -- _UIFLOWBLOCK_REQUEST
    local deadline = GetGameTimer() + 5000
    while not Citizen.InvokeNative(0x10A93C057B6BD944, block) do -- _UIFLOWBLOCK_IS_LOADED
        if GetGameTimer() > deadline then
            print('[custom-uiapp] luman_uiapp_flow did not load')
            DatabindingRemoveDataEntry(root)
            open = false
            return
        end
        Wait(0)
    end
    Citizen.InvokeNative(0x3B7519720C9DCB45, block, 0)       -- _UIFLOWBLOCK_ENTER
    Citizen.InvokeNative(0x4C6F2C4B7A03A266, MACHINE, block) -- UI_STATE_MACHINE_CREATE

    -- values can change while the app is open: count down in the title
    local closeAt = GetGameTimer() + 20000
    while GetGameTimer() < closeAt do
        if IsControlJustPressed(0, `INPUT_FRONTEND_CANCEL`) then break end
        local left = math.ceil((closeAt - GetGameTimer()) / 1000)
        DatabindingWriteDataString(hTitle, ('%s  (%d)'):format(title, left))
        Wait(0)
    end

    Citizen.InvokeNative(0x4EB122210A90E2D8, MACHINE)        -- UI_STATE_MACHINE_DESTROY
    DatabindingRemoveDataEntry(root)
    open = false
end

RegisterCommand('myapp', function(_, args)
    local text = #args > 0 and table.concat(args, ' ') or 'This card is a scene of its own, streamed from a resource.'
    CreateThread(function()
        showApp('Luman Studio', text, 'Backspace to close')
    end)
end, false)
