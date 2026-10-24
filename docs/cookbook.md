# Cookbook

Short recipes. Every name used here (apps, entries, contexts, paths, aliases, channels) is listed in the reference
pages next to this one.

- [Write values the UI reads](#write-values-the-ui-reads)
- [Show a HUD widget](#show-a-hud-widget)
- [Hide part of the game HUD](#hide-part-of-the-game-hud)
- [Draw around the radar from NUI](radar.md)
- [Launch an app, or one screen of it](#launch-an-app-or-one-screen-of-it)
- [Show any flow block](#show-any-flow-block)
- [Fill a list](#fill-a-list)
- [Read what the player does](#read-what-the-player-does)
- [Your own screen](#your-own-screen)
- [Bindings in your own scene](#bindings-in-your-own-scene)

## Write values the UI reads

```lua
local root = DatabindingAddDataContainerFromPath('', 'Tithing')      -- ScriptDatastoreRoot.Tithing
local funds = DatabindingAddDataContainer(root, 'CampFunds')          -- Tithing.CampFunds
local dollars = DatabindingAddDataInt(funds, 'dollars', 12)           -- Tithing.CampFunds.dollars

DatabindingWriteDataInt(dollars, 40)  -- later: write through the handle
DatabindingRemoveDataEntry(root)      -- when done
```

| The element binds | Write it with |
|---|---|
| `RawText` | `DatabindingAddDataString` |
| `Text` (a label) | `DatabindingAddDataHash` |
| `Visible`, `Enabled` | `DatabindingAddDataBool` |
| `Value` of a meter | float, `0x5154228273ADB9A6` (`_DATABINDING_ADD_DATA_FLOAT`) |
| a state / mode (converter) | `DatabindingAddDataInt` |

Paths per screen: [datastore.md](datastore.md).

## Show a HUD widget

HUD widgets are always loaded; one shows when a context shows its slot.

```lua
Citizen.InvokeNative(0x4CC5F2FC1332577F, `HUD_CTX_TITHING`)  -- _ENABLE_HUD_CONTEXT: money HUD
Citizen.InvokeNative(0x8BC7C1F929D07BF3, `HUD_CTX_TITHING`)  -- _DISABLE_HUD_CONTEXT
```

Contexts and the slots they show / hide: [hud.md](hud.md).

## Hide part of the game HUD

The same contexts hide slots too:

```lua
Citizen.InvokeNative(0x4CC5F2FC1332577F, `HUD_CTX_HACK_RADAR_FORCE_HIDE`)  -- radar gone, until disabled
```

## Launch an app, or one screen of it

```lua
LaunchUiappByHash(`fast_travel_menu`)
LaunchUiappByHashWithEntry(`shop_browsing`, `catalog_item_inspection`)  -- the entry is a screen of the app
CloseUiappByHash(`shop_browsing`)
```

Apps and their entries: [apps.md](apps.md).

## Show any flow block

A flow block can be shown without its app, and several at once (a script may hold 14).

```lua
local function showFlow(flow, machine, entry)
    local block = Citizen.InvokeNative(0xC0081B34E395CE48, GetHashKey(flow), Citizen.ResultAsInteger()) -- _UIFLOWBLOCK_REQUEST
    while not Citizen.InvokeNative(0x10A93C057B6BD944, block) do Wait(0) end                            -- _UIFLOWBLOCK_IS_LOADED
    Citizen.InvokeNative(0x3B7519720C9DCB45, block, entry or 0)        -- _UIFLOWBLOCK_ENTER
    Citizen.InvokeNative(0x4C6F2C4B7A03A266, GetHashKey(machine), block) -- UI_STATE_MACHINE_CREATE
end

showFlow('pm_flow_weapon_inspect', 'my_inspect')
-- close: Citizen.InvokeNative(0x4EB122210A90E2D8, `my_inspect`)       -- UI_STATE_MACHINE_DESTROY
```

All 172 flow blocks: [flows.md](flows.md).

## Fill a list

```lua
local data = DatabindingAddDataContainerFromPath('', 'FastTravel')
local list = DatabindingAddUiItemList(data, 'locationList')

local item = DatabindingAddDataContainer(data, 'item1')
DatabindingAddDataString(item, 'dynamic_list_item_raw_text_entry', 'Valentine')
DatabindingAddDataHash(item, 'dynamic_list_item_event_channel_hash', `FAST_TRAVEL_MENU`)
DatabindingAddDataBool(item, 'dynamic_list_item_enabled', true)
DatabindingAddDataInt(item, 'index', 1)  -- your own field, read back on select

DatabindingInsertUiItemToListFromContextStringAlias(list, -1, 'ft_dynamic_text_and_price', item)
```

The alias must be one the running flow registers: [templates.md](templates.md).

## Read what the player does

```lua
while EventsUiIsPending(`FAST_TRAVEL_MENU`) do
    local msg = DataView.ArrayBuffer(8 * 4)   -- dataview.lua from meta-hub/redm-events
    if Citizen.InvokeNative(0xE24E957294241444, `FAST_TRAVEL_MENU`, msg:Buffer()) then -- EVENTS_UI_GET_MESSAGE
        local kind, param, item = msg:GetInt32(0), msg:GetInt32(16), msg:GetInt32(24)
        if kind == `ITEM_SELECTED` then print(DatabindingReadDataIntFromParent(item, 'index')) end
        if param == `FAST_TRAVEL_UI_EVENT_EXIT` then CloseUiappByHash(`fast_travel_menu`) end
    end
end
```

Channels and parameters: [events.md](events.md).

## Your own screen

A resource can add flow blocks and scenes with **new names** in `stream/` (files that replace game UI files are
ignored). The flow loads the scene and shows it:

```xml
<rage__fwuiFlowBlock>
 <ID>my_flow</ID>
 <EntryPoints><Item><ID>default_entry_point</ID><Target>my_scene_host</Target></Item></EntryPoints>
 <ExitPoints><Item><ID>exit_to_game</ID></Item></ExitPoints>
 <FlowRoot>
  <ID>resource_load</ID>
  <State type="rage__StateResourceLoader">
   <Resources>
    <Item type="rage__fwuiTextureDictionaryDependencyResource"><Name>generic_textures</Name></Item>
    <Item type="UIObjectSceneStreamingDependencyResource"><Name>my_scene</Name></Item>
   </Resources>
  </State>
  <Children>
   <Item>
    <ID>my_scene_host</ID>
    <State type="StateUIObjectStreamedSceneHost"><SceneName>my_scene</SceneName></State>
   </Item>
  </Children>
 </FlowRoot>
</rage__fwuiFlowBlock>
```

Show it with `showFlow('my_flow', 'my_machine')` from above. Build the XML into `.ymt` with
`codexcli fromxml my_flow.rbf.xml stream\my_flow.ymt`.

Or write it in Python with [tools/uiscene.py](../tools/uiscene.py):

```python
from uiscene import Scene, flow

s = Scene('MyHud')  # binds ScriptDatastoreRoot.MyHud.*
s.add(s.panel('PAN_Box', [
    s.ink('IMG_Bg'),
    s.text('TXT_Title', 'title', 'HUD_TEXT_SUB_HEADER', 'CENTER', h='HALIGN_STRETCH', t=12),
    s.meter('METER_Progress', 'progress', fill='COLOR_GOLD', w=260, ht=10, h='HALIGN_CENTER', t=60),
], h='HALIGN_CENTER', w=320, ht=90, t=40))
s.write('src/my_scene.rbf.xml')
flow('my_flow', 'my_scene', 'src/my_flow.rbf.xml')
```

Working resources: [custom-uiapp](../examples/custom-uiapp), [scene-builder](../examples/scene-builder),
[radar-top-right](../examples/radar-top-right).

## Bindings in your own scene

```xml
<Item type="UIText">
 <Name>TXT_Score</Name>
 <Style>HUD_TEXT_SUB_HEADER</Style>
 <MemberBindings>
  <Item>
   <MemberName>RawText</MemberName>
   <Setup><Path>ScriptDatastoreRoot.MyHud.score</Path><PathType>PATH_ABSOLUTE</PathType></Setup>
  </Item>
  <Item>
   <MemberName>Color</MemberName>
   <Setup><Path>ScriptDatastoreRoot.MyHud.scoreColor</Path><PathType>PATH_ABSOLUTE</PathType></Setup>
   <Converter type="rage__fwuiIntHashStringDictionaryConversion">   <!-- int -> colour -->
    <Default>COLOR_WHITE</Default>
    <Dictionary><Item key="0">COLOR_WHITE</Item><Item key="1">COLOR_RED</Item></Dictionary>
   </Converter>
  </Item>
 </MemberBindings>
</Item>
```

- Create every bound entry before the scene opens.
- Game widgets can be pulled in by name (`<Instancing><Item type="UITemplateInstancingItem"><Type>Minimap</Type>`)
  when the flow lists their template (`UITemplateStreamingDependencyResource`, see `ui_resources_bundles/*.ymt`).
- Styles (fonts, sizes, colours) are the game's: `HUD_TEXT_BODY`, `HUD_TEXT_SUB_HEADER`, `HUD_LOCATION_TEXT`,
  `HUD_WANTED_UPPERTEXT`, `MP_DEATH_SCREEN_BODY`, `EXTRA_LARGE_HEADER` …
