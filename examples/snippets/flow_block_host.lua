-- Host any UI flow block from a script, without launching its app.
-- This is what weapon_stats.lua does for pm_flow_weapon_inspect; it works for the 172 flow blocks in docs/flows.md.
-- An entry is one of the flow's entry points (docs/apps.md, docs/flows.md); 0 takes the default.
-- Not tested in game for every flow: some expect data or a scene that only their app sets up.

local Flow = {}

-- Flow.Show('shop_browsing', 'catalog_item_inspection', 'my_shop_card')
function Flow.Show(flowId, entry, machineName)
    local block = Citizen.InvokeNative(0xC0081B34E395CE48, GetHashKey(flowId))     -- _UIFLOWBLOCK_REQUEST
    local timeout = GetGameTimer() + 5000
    while not Citizen.InvokeNative(0x10A93C057B6BD944, block) do                   -- _UIFLOWBLOCK_IS_LOADED
        if GetGameTimer() > timeout then return nil end
        Wait(0)
    end
    Citizen.InvokeNative(0x3B7519720C9DCB45, block, entry and GetHashKey(entry) or 0) -- _UIFLOWBLOCK_ENTER
    local machine = GetHashKey(machineName or ('script_' .. flowId))
    Citizen.InvokeNative(0x4C6F2C4B7A03A266, machine, block)                       -- UI_STATE_MACHINE_CREATE
    return { block = block, machine = machine }
end

function Flow.Close(handle)
    if handle then Citizen.InvokeNative(0x4EB122210A90E2D8, handle.machine) end    -- UI_STATE_MACHINE_DESTROY
end

-- Example: the shop's item card (the flow id of shop_browsing_main_flow.ymt is "shop_browsing").
-- Its data is under DynamicCatalogItems.CatalogItemInspection (docs/datastore.md), as in shop.lua.
RegisterCommand('flowcard', function()
    local root = DatabindingAddDataContainerFromPath('', 'DynamicCatalogItems')
    local card = DatabindingAddDataContainer(root, 'CatalogItemInspection')
    DatabindingAddDataBool(card, 'isVisible', true)
    DatabindingAddDataHash(card, 'itemLabel', `WEAPON_PISTOL_VOLCANIC`)
    DatabindingAddDataString(card, 'itemDescription', 'Shown by hosting the flow block directly.')
    DatabindingAddDataString(card, 'purchaseLabel', 'Buy')
    DatabindingAddDataInt(card, 'purchasePrice', 1000)

    local ui = Flow.Show('shop_browsing', 'catalog_item_inspection', 'flowcard')
    Wait(5000)
    Flow.Close(ui)
    DatabindingRemoveDataEntry(root)
end, false)

