-- HUD contexts: a HUD widget appears once a context that shows its slot is on.
-- Contexts and the slots they hide/show: docs/hud.md (from data/ui/hudvisibility/visibilityconditions.ymt).
-- Not tested in game yet: the context names and hashes come from the game files.

local function EnableHudContext(ctx)  Citizen.InvokeNative(0x4CC5F2FC1332577F, ctx) end -- _ENABLE_HUD_CONTEXT
local function DisableHudContext(ctx) Citizen.InvokeNative(0x8BC7C1F929D07BF3, ctx) end -- _DISABLE_HUD_CONTEXT

-- /hudctx HUD_CTX_TITHING      toggles a context by name
local on = {}
RegisterCommand('hudctx', function(_, args)
    local name = args[1] or 'HUD_CTX_TITHING'
    local ctx = GetHashKey(name)
    if on[name] then DisableHudContext(ctx) else EnableHudContext(ctx) end
    on[name] = not on[name]
    print(('%s %s (%d)'):format(name, on[name] and 'on' or 'off', ctx))
end, false)

-- The money HUD (widgets/hud/tithing) sits in HUD_VISIBILITY_SLOT_CAMP_SUPPLY, which HUD_CTX_TITHING shows.
-- HUD_CTX_TITHING = 1670279562, the number money_hud.lua passes.
RegisterCommand('moneyhud', function()
    local tithing = DatabindingAddDataContainerFromPath('', 'Tithing')
    DatabindingAddDataString(tithing, 'Supplies', 'Supplies 3/5')
    local funds = DatabindingAddDataContainer(tithing, 'CampFunds')
    DatabindingAddDataInt(funds, 'dollars', 69)
    DatabindingAddDataInt(funds, 'cents', 50)
    local cash = DatabindingAddDataContainer(tithing, 'PlayerCash')
    DatabindingAddDataInt(cash, 'dollars', 420)
    DatabindingAddDataInt(cash, 'cents', 15)
    EnableHudContext(`HUD_CTX_TITHING`)
end, false)

-- The honor meter (widgets/hud/honor_display) is shown by HUD_CTX_HONOR_SHOW; State is 1..16.
RegisterCommand('honor', function(_, args)
    local icons = DatabindingAddDataContainerFromPath('', 'RPGStatusIcons')
    local honor = DatabindingAddDataContainer(icons, 'HonorIcon')
    DatabindingAddDataInt(honor, 'State', tonumber(args[1]) or 12)
    EnableHudContext(`HUD_CTX_HONOR_SHOW`)
end, false)
