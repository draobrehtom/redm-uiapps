# How RDR2's UI works, read from the game files

The reference pages in this folder are generated from the game's own UI data. This page explains where that data
lives, how it fits together, and what it means for RedM scripts.

## Where the UI lives

Everything is under `x64/data/ui/` in the archives (`data_0.rpf`, patched by `update_4.rpf`): 2,236 files once the
patched copy of each is taken. They are PSO `.ymt` files plus a few XML files.

| Folder | Root type | What it is |
|---|---|---|
| `applaunch/launchconditions.ymt` | `LaunchConditions` | The 37 app ids and which apps must be closed before each one launches |
| `flow/` | `rage::fwuiFlowBlock` | State machines. A launcher flow sets the HUD, input and feedback context, then shows scenes. Entry points, exit points, sub-flows, list templates |
| `screens/` | `UIPanel`, `UIGrid`, `UIMovieView` … | Scenes: element trees laid out on a 1920×1080 canvas |
| `widgets/` | same | Reusable pieces a screen instances: list items, meters, money values, wheel slots |
| `datastore/` | `rage::fwuiDatastoreEntry` | Data the game ships itself (credits, help articles) |
| `value_conversion/`, `animations/`, `styles/` | | Converters, UI animations, text and colour styles |
| `hudvisibility/visibilityconditions.ymt` | `uiHudVisibilityNode` | The HUD slot tree and the contexts that hide or show each slot |
| `inputcontexts/` | | Which inputs a menu takes |
| `colors.xml` | | Every `COLOR_*` name. The `value` is `0xAABBGGRR`; the `r g b a` attributes are given too |

Some files are stored under the hash of their name (`widgets/0xc64d1515.ymt`). The hash is `joaat` of the path
inside its folder: `0xc64d1515` is `input3/sidemenu/pm/dynamic_text_header_multiline`. `extract.py` recovers 51 of
them by hashing every string found in the UI files.

## How a screen gets its data

An element binds a member (its text, visibility, texture, colour, a meter value) to a path:

```xml
<MemberBindings>
  <Item>
    <MemberName>RawText</MemberName>
    <Setup><Path>ScriptDatastoreRoot.FastTravel.description</Path><PathType>PATH_ABSOLUTE</PathType></Setup>
  </Item>
</MemberBindings>
```

`ScriptDatastoreRoot` is where `DatabindingAddDataContainerFromPath("", "FastTravel")` creates its container. A path
can also be relative to a binding context set higher up — `widgets/hud/tithing` sets the context `Tithing`, its child
panels set `CampFunds` and `PlayerCash`, and the instanced `money_value` widget binds `dollars` and `cents`. That is
why `money_hud.lua` writes `Tithing.CampFunds.dollars`. `datastore.md` lists these resolved paths, 2,826 of them.

What the member is tells the value's type: `RawText` takes a string, `Text` a label hash, `Visible` and `Enabled` a
bool, `Value`, `Minimum` and `Maximum` a number. A path that drives an animation or a converter (`HonorIcon.State`,
1–16) takes an int.

## How a script launches a screen

- **An app**: `LaunchUiappByHash(app)` or `LaunchUiappByHashWithEntry(app, entry)`. The entry is one of the launcher
  flow's entry points. The numbers in community scripts are these: `-702860656` is `catalog_item_inspection` and
  `-649639953` is `horse_stats_info_card`, both entries of `shop_browsing`. `apps.md` lists every entry.
- **Any flow block**, without its app: `_UIFLOWBLOCK_REQUEST(flow)` → `_UIFLOWBLOCK_IS_LOADED` →
  `_UIFLOWBLOCK_ENTER(block, entry)` → `UI_STATE_MACHINE_CREATE(name, block)`. `weapon_stats.lua` does this with
  `pm_flow_weapon_inspect`. `flows.md` lists 172 flow blocks.
- **A HUD widget**: it is always loaded; it shows once its slot is visible. `_ENABLE_HUD_CONTEXT(HUD_CTX_TITHING)`
  shows the camp supply slot the money widget sits in. `hud.md` lists what each of the 96 contexts hides and shows.

## How a screen talks back

Two kinds of data send events to scripts:

- `ScriptEventOp` behaviours on elements: an `EventChannel` and a `HashParameter`, sent when the element is selected.
- Event states in flows: `<Channel>FAST_TRAVEL_MENU</Channel><Event><Type>UISCRIPTEVENTTYPE_ITEM_SELECTED</Type><HashParameter>FAST_TRAVEL_UI_EVENT_EXIT</HashParameter></Event>`.

The channel is what `EventsUiIsPending` and `EVENTS_UI_GET_MESSAGE` take. The message has the event type at offset
0, the parameter hash at 16 and the item's data container at 24. `events.md` lists 35 channels and 277 parameters.

List items made from a template carry their own channel and hash (`dynamic_list_item_event_channel_hash`,
`dynamic_list_item_select_hash`), so a script can make up events of its own.

## Lists

A list element has an `ItemCreator` behaviour bound to a path (`FastTravel.locationList`). Items are added with
`DatabindingInsertUiItemToListFromContextStringAlias(list, -1, alias, item)`. The alias must be one the running flow
registered:

```xml
<Item>
  <Name>input3/sidemenu/pm/dynamic_text_and_price</Name>
  <Template><Id>ft_dynamic_text_and_price</Id></Template>
</Item>
```

`templates.md` lists 458 alias–widget pairs. The same aliases appear as `Instancing` types inside screens, which is
how a screen pulls a widget in (`pm_header_item` is `core/menu_header`).

## Side menus and their hosts

Most menus are drawn inside a host scene. The flow shows `sidemenus/host`, then the app's root scene at
`ParentPath` `LEFT_HAND_MAIN.SIDEMENU_HOST.SCREEN_DIVIDER.VB_LHM_SCALE.LM_MENU_HOST`, then its page inside the root.
The catalog records this as `mounts`: for each scene, the host and the parent path.

## Script limits and render targets

RedM's `gameconfig.xml` ([citizenfx/fivem](https://github.com/citizenfx/fivem/blob/master/data/client_rdr/citizen/common/data/gameconfig.xml))
sets how many UI resources one script may hold at a time: 14 `UI_FLOWBLOCK`, 10 `UI_STATE_MACHINE`, 4 `UI_SCENE` and
128 `UI_OBJECT`. Hosting flow blocks from a script is therefore a supported pattern, with room for several at once.

The same list names `UI_SCENE`, which scripts request directly with `UI_REQUEST_SCENE` (`0xB6857100F8FD433C`) and point
at a render target with `UI_MOVIEVIEW_SET_RENDER_TARGET` (`0x51DE09A2196BD951`). Scenes with a
`uiRenderTargetModelBehavior` are drawn onto a model's texture instead of the screen — the catalogue book, posters,
newspapers. Their render targets are named in the data (`catalogue01x_ct` and others; the reference page marks these
scenes). The arguments of these two natives are not documented yet.

## Shipping UI files in a resource

Tested in RedM on 2026-10-18 with a test resource (files built with codexcli):

| Test | Result |
|---|---|
| `stream/hud.ymt` replacing the HUD scene (radar moved to the top right) | **ignored** |
| `stream/tithing.ymt` replacing the money widget (icons coloured red) | **ignored** |
| `stream/luman_test_flow.ymt`, a flow block with a new id, hosted with `_UIFLOWBLOCK_REQUEST` | **loaded** |
| control: requesting a flow block that exists nowhere | not loaded (handle 0) |
| `stream/luman_scene_flow.ymt` + `stream/luman_test_scene.ymt`: a new flow showing a new scene with a red marker | **loaded, marker shown** |

So a resource cannot change the game's UI files, but it can add UI of its own: new flow blocks and new scenes are
streamed by name. A flow lists its scene as `UIObjectSceneStreamingDependencyResource` and shows it with
`StateUIObjectStreamedSceneHost`. [examples/custom-uiapp](../examples/custom-uiapp) is a working card built this way.

Screens, widgets and flows have no data file type. The data file types the game does have (read from the enum table
in `RDR2.exe`; names resolved by `joaat` without lower-casing) include `UI_STYLES_DATA`, `UI_LOCALISED_STYLES_DATA`,
`UI_INPUT_CONTEXT_DATA`, `UI_BLIP_DATA`, `UI_MAP_DATA` and `UI_TRACKING_FILE`. Whether a style catalog given as
`data_file 'UI_STYLES_DATA'` is used is being tested.

## Reproducing the data

See [`tools/README.md`](../tools/README.md). The short version:

```bash
codexcli find "data\ui\"                # every UI file, in every archive
codexcli xmlmany list.txt              # convert the patched copy of each to XML
python -I tools/extract.py xml/ catalog.json
python -I tools/gen_docs.py catalog.json docs/
```

## What is not known yet

- The app id → launcher flow pairing is in code. `gen_docs.py` pairs them by name (file name or flow block id);
  `policies_menu` and `rockstar_editor` are not paired.
- Text bound with `Text` takes a label hash; the strings themselves are in the game's `.gxt2` files, which are not
  part of this catalog.
- 145 hashed file names are still unresolved.
