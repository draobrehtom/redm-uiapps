# Radar in the top-right corner

`ensure radar-top-right`, then `/radar` to move the radar and the cores to the top right, again to move them back.

A resource cannot change `hud.ymt` (RedM ignores replaced UI files), so the radar is drawn a second time by a scene
of our own and the game's one is hidden:

```lua
-- 1. show our scene (flow block uiapps_radar_flow, stream/)
local block = Citizen.InvokeNative(0xC0081B34E395CE48, `uiapps_radar_flow`, Citizen.ResultAsInteger())
while not Citizen.InvokeNative(0x10A93C057B6BD944, block) do Wait(0) end
Citizen.InvokeNative(0x3B7519720C9DCB45, block, 0)
Citizen.InvokeNative(0x4C6F2C4B7A03A266, `uiapps_radar_machine`, block)

-- 2. hide the game's radar
Citizen.InvokeNative(0x4CC5F2FC1332577F, `HUD_CTX_HACK_RADAR_FORCE_HIDE`)
```

The scene is the radar block of `screens/hud/hud.ymt` aligned top-right, with the game's `Minimap` widget copied in
and two things taken out of it:

```xml
<!-- widgets/hud/minimap.ymt -->
<MapFlags>MAP_REGISTER_WITH_HUD MAP_CIRCLE MAP_AUTO_ZOOM MAP_EDGE_CLAMPING MAP_THREAT_INDICATION</MapFlags>
<Item type="uiBehaviorHudVisibilityAnimation"><SlotType>HUD_VISIBILITY_SLOT_RADAR</SlotType> ...

<!-- our copy -->
<MapFlags>MAP_CIRCLE MAP_AUTO_ZOOM MAP_EDGE_CLAMPING MAP_THREAT_INDICATION</MapFlags>
```

| Left in | What happens (tested in RedM) |
|---|---|
| `MAP_REGISTER_WITH_HUD` | the copy takes the HUD's map registration; when it closes, the game radar loses its round mask |
| `HUD_VISIBILITY_SLOT_RADAR` | hiding the game radar (`DisplayRadar(false)` or the context) hides the copy too |
| both taken out | the copy is live, the game radar can be hidden, closing the copy leaves it intact |

The cores still come from the game's `attribute_status_meters` widget, instanced by name. The flow lists every widget
template the scene uses, copied from `ui_resources_bundles/hud_resources.ymt`:

```xml
<Item type="UITemplateStreamingDependencyResource">
 <Name>hud/minimap_compass_detail</Name>
 <Template><Id>MinimapCompassDetail</Id></Template>
</Item>
```

Sources are in `src/`; rebuild with `codexcli fromxml src\<name>.rbf.xml stream\<name>.ymt`.
