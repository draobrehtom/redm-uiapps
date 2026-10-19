-- Read the events a UI app posts, by channel. The channels and their parameter hashes are in docs/events.md.
-- Message layout (EVENTS_UI_GET_MESSAGE, 0xE24E957294241444): event type at 0, parameter hash at 16,
-- the item's data container at 24. Needs DataView from https://github.com/meta-hub/redm-events (dataview.lua).

local UiEvents = {}

local TYPES = {
    [`ITEM_FOCUSED`] = 'focused',   -- UISCRIPTEVENTTYPE_ITEM_FOCUSED
    [`ITEM_SELECTED`] = 'selected', -- UISCRIPTEVENTTYPE_ITEM_SELECTED
}

-- UiEvents.Listen('FAST_TRAVEL_MENU', function(kind, param, item) ... end)
-- Polls every frame while the callback returns nothing; return false from it to stop.
function UiEvents.Listen(channel, callback)
    local ch = GetHashKey(channel)
    CreateThread(function()
        while true do
            while EventsUiIsPending(ch) do
                local msg = DataView.ArrayBuffer(8 * 4)
                if Citizen.InvokeNative(0xE24E957294241444, ch, msg:Buffer()) then
                    local kind = msg:GetInt32(0)
                    if callback(TYPES[kind] or kind, msg:GetInt32(16), msg:GetInt32(24)) == false then return end
                end
            end
            Wait(0)
        end
    end)
end

-- Example: print what the fast travel menu sends. FAST_TRAVEL_UI_EVENT_EXIT and FAST_TRAVEL_UI_EVENT_FILTER
-- are the parameters its screens and flows post (docs/events.md).
RegisterCommand('ftevents', function()
    UiEvents.Listen('FAST_TRAVEL_MENU', function(kind, param, item)
        if param == `FAST_TRAVEL_UI_EVENT_EXIT` then
            print('exit')
            CloseUiappByHash(`fast_travel_menu`)
            return false
        end
        print(kind, param, item ~= 0 and DatabindingReadDataIntFromParent(item, 'index') or '')
    end)
end, false)

