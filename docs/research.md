# How RDR2's UI works

Read from the game files (`x64/data/ui/` in `data_0.rpf`, patched by `update_4.rpf`: 2,236 files, RBF `.ymt`).

## The files

| Folder | What it is |
|---|---|
| `applaunch/launchconditions.ymt` | the 37 app ids |
| `flow/` | state machines (`rage__fwuiFlowBlock`): entry points, sub-flows, which scenes to show, list aliases |
| `screens/` | scenes: element trees (`UIPanel`, `UIGrid`, `UIText`, `UIImage`, `UIMeter` …) on 1920×1080 |
| `widgets/` | pieces a scene instances by name: list items, meters, money values, the minimap |
| `ui_resources_bundles/` | which widget template each name loads (`hud/minimap` → `Minimap`) |
| `hudvisibility/visibilityconditions.ymt` | HUD slots and the contexts that hide / show them |
| `stylescatalog.ymt`, `styles/` | text and layout styles (`HUD_TEXT_BODY` …) |
| `safeframe_configurations.ymt` | the safe areas scenes attach to (`safeframe_hud`) |
| `colors.xml` | every `COLOR_*` (`0xAABBGGRR`) |

Some files are stored as the hash of their path: `widgets/0xc64d1515.ymt` is
`input3/sidemenu/pm/dynamic_text_header_multiline` (`joaat` of the path inside the folder).

## Data in, events out

```
Lua  ── DatabindingAdd* ──▶  ScriptDatastoreRoot.X.y  ──▶  element member (RawText, Visible, Value …)
Lua  ◀── EVENTS_UI_GET_MESSAGE (channel) ──  ScriptEventOp on an element / event state in a flow
```

```xml
<MemberBindings>
 <Item>
  <MemberName>RawText</MemberName>
  <Setup><Path>ScriptDatastoreRoot.FastTravel.description</Path><PathType>PATH_ABSOLUTE</PathType></Setup>
 </Item>
</MemberBindings>
```

Relative paths chain through binding contexts: `widgets/hud/tithing` sets `Tithing`, its panels `CampFunds`, the
money widget binds `dollars` → `Tithing.CampFunds.dollars`.

## Ways to show a screen

| How | Natives |
|---|---|
| an app | `LaunchUiappByHash`, `LaunchUiappByHashWithEntry` |
| any flow block | `_UIFLOWBLOCK_REQUEST` → `_IS_LOADED` → `_ENTER` → `UI_STATE_MACHINE_CREATE` |
| a HUD widget | `_ENABLE_HUD_CONTEXT` with a context that shows its slot |
| a scene on a model (posters, catalogue) | `UI_REQUEST_SCENE`, `UI_MOVIEVIEW_SET_RENDER_TARGET` (arguments not known yet) |

Script limits (RedM `gameconfig.xml`): 14 `UI_FLOWBLOCK`, 10 `UI_STATE_MACHINE`, 4 `UI_SCENE`, 128 `UI_OBJECT`.

Side menus are drawn inside a host scene: the flow shows `sidemenus/host`, then mounts the menu at a `ParentPath`
(`LEFT_HAND_MAIN.SIDEMENU_HOST…LM_MENU_HOST`).

## UI files in a resource (tested in RedM)

| Test | Result |
|---|---|
| `stream/hud.ymt`, `stream/tithing.ymt` replacing game files | ignored |
| a flow block with a new id | loaded |
| control: a flow block that exists nowhere | not loaded (handle 0) |
| a new flow showing a new scene | loaded and drawn |
| a new scene instancing game widgets (`Minimap`, `attribute_status_meters`) | drawn and live |
| that scene with `MAP_REGISTER_WITH_HUD` left in, then destroyed | game radar loses its round mask |
| without it and without the HUD visibility slot, game radar hidden with `HUD_CTX_HACK_RADAR_FORCE_HIDE` | radar moved |
| `data_file 'UI_STYLES_DATA'` with an edited style catalog | not tested yet |

So: no changing the game's UI, but any amount of UI of your own. See [cookbook](cookbook.md#your-own-screen) and
the [examples](../examples).

UI data file types in `RDR2.exe` (names by `joaat` without lower-casing): `UI_STYLES_DATA`,
`UI_LOCALISED_STYLES_DATA`, `UI_INPUT_CONTEXT_DATA`, `UI_BLIP_DATA`, `UI_MAP_DATA`, `UI_TRACKING_FILE`. Screens,
widgets and flows have none.

## Rebuilding the reference

```bash
codexcli find "data\ui\"                         # every UI file in every archive
codexcli xmlmany list.txt                       # patched copy of each → XML
python -I tools/extract.py xml/ catalog.json
python -I tools/gen_docs.py catalog.json docs/
```

Details: [tools/README.md](../tools/README.md).

## Not known yet

- App id → launcher flow is paired by name; `policies_menu` and `rockstar_editor` have no pair.
- 145 hashed file names are unresolved.
- Arguments of the render target natives.
