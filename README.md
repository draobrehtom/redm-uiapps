# RedM UI apps

Lua examples and a full reference for RDR2's native UI in RedM: HUD widgets, menus, lists, events, and
**UI of your own** that the game draws.

By **[Luman Studio](https://lumanstudio.com)** · [Tebex](https://lumanstudio.tebex.io) · [YouTube](https://www.youtube.com/@lumanstudio)

## Quick start

```lua
-- an icon next to the radar: one container, two values
local icon = DatabindingAddDataContainerFromPath('', 'PassiveIcon')
DatabindingAddDataBool(icon, 'isVisible', true)
DatabindingAddDataInt(icon, 'setState', 1)
```

```lua
-- the money HUD: fill its paths, switch its HUD context on
local t = DatabindingAddDataContainerFromPath('', 'Tithing')
DatabindingAddDataInt(DatabindingAddDataContainer(t, 'PlayerCash'), 'dollars', 56)
Citizen.InvokeNative(0x4CC5F2FC1332577F, `HUD_CTX_TITHING`) -- _ENABLE_HUD_CONTEXT
```

```lua
-- an app at one of its screens
LaunchUiappByHashWithEntry(`shop_browsing`, `catalog_item_inspection`)
```

More in the **[cookbook](docs/cookbook.md)**: lists, events, hosting any flow block, hiding HUD parts, your own
screens.

## Your own UI

A resource can stream **new** flow blocks and scenes; the game loads and draws them. Files that replace the game's
own UI files are ignored.

```
my-resource/
  fxmanifest.lua
  client.lua           -- fills ScriptDatastoreRoot.MyHud.*, shows the flow
  stream/my_flow.ymt   -- loads the scene, shows it
  stream/my_scene.ymt  -- texts, images, meters bound to MyHud.*
```

```python
# tools/uiscene.py writes the scene; codexcli fromxml builds the .ymt
s = Scene('MyHud')
s.add(s.text('TXT_Title', 'title', 'HUD_TEXT_SUB_HEADER', 'CENTER', h='HALIGN_CENTER', t=40))
s.write('src/my_scene.rbf.xml')
flow('my_flow', 'my_scene', 'src/my_flow.rbf.xml')
```

| Example | What it is | In game |
|---|---|---|
| [custom-uiapp](examples/custom-uiapp) | a card with a title, a text and a countdown (`/myapp`) | ✅ |
| [radar-top-right](examples/radar-top-right) | the radar and cores moved to the top right (`/radar`) | ✅ |
| [scene-builder](examples/scene-builder) | a match HUD written in Python: scores, timer, bar, kill feed (`/matchhud`) | not yet |

## Snippets

Single files in [examples/snippets](examples/snippets): copy one into your resource's `client_scripts`.
The ones reading UI events need [`dataview.lua`](https://github.com/meta-hub/redm-events/blob/main/dataview.lua).

| File | Shows |
|---|---|
| `passive_icon_near_radar.lua` | passive-mode icon next to the radar |
| `money_hud.lua` | camp funds and cash (Tithing HUD) |
| `honor_level.lua` | honor meter |
| `rank_bar.lua` | `mp_rank_bar`: name, rank, XP fill |
| `countdown.lua` | `MPCountdown` overlay |
| `timer_top_center.lua` | timer at the top centre |
| `bounty_top_right.lua` | bounty text at the top right |
| `scoreboard_top_right_corner.lua` | score lines at the top right |
| `helperTextfields.lua` | two helper labels (hits / misses) |
| `wanted.lua` | wanted level |
| `fast_travel.lua` | `fast_travel_menu` with a list and its events |
| `shop.lua` | `shop` app with items |
| `satchel.lua` | `satchel` app |
| `horseStats.lua` | horse stats card |
| `weapon_stats.lua` | weapon inspect card (`pm_flow_weapon_inspect`) |
| `translate.lua` | `translation_overlay` |
| `hud_context.lua` ¹ | HUD contexts on and off |
| `flow_block_host.lua` ¹ | any flow block without its app |
| `ui_events.lua` ¹ | a helper that reads an event channel |

¹ written from the reference, not run in game yet.

## Reference

Generated from the game's `data/ui` files ([how](docs/research.md)):

| Page | Lists |
|---|---|
| [apps.md](docs/apps.md) | 37 apps, their flows and entry points (with hashes) |
| [flows.md](docs/flows.md) | 172 flow blocks, entries, scenes |
| [datastore.md](docs/datastore.md) | 2,826 DataBinding paths, their type, who reads them |
| [templates.md](docs/templates.md) | 458 list aliases and the widget each builds |
| [events.md](docs/events.md) | 35 event channels and 277 parameters |
| [hud.md](docs/hud.md) | 96 HUD contexts and the slots they show / hide |

Magic numbers from community scripts, named: `-702860656` = `catalog_item_inspection`, `-649639953` =
`horse_stats_info_card` (both `shop_browsing`), `1670279562` = `HUD_CTX_TITHING`.

## Tools

| | |
|---|---|
| [tools/uiscene.py](tools/uiscene.py) | write scenes and flow blocks from Python |
| [tools/extract.py](tools/extract.py), [gen_docs.py](tools/gen_docs.py), [labels.py](tools/labels.py) | rebuild the reference from the game files |
| [CodeX](https://github.com/luman-studio/codex) `codexcli` | `.ymt` ↔ XML (`xml`, `fromxml`), exact for every file in `data\ui` |

See [tools/README.md](tools/README.md).

## Event types

```cpp
UISCRIPTEVENTTYPE_ITEM_FOCUSED            = 0x984750E7
UISCRIPTEVENTTYPE_ITEM_UNFOCUSED          = 0xDA4D50F6
UISCRIPTEVENTTYPE_ITEM_SELECTED           = 0xB841988C
UISCRIPTEVENTTYPE_NEW_PAGE                = 0x8445624D
UISCRIPTEVENTTYPE_TAB_PAGE_INCREMENT      = 0x29EB385C
UISCRIPTEVENTTYPE_TAB_PAGE_DECREMENT      = 0xD4E9057D
UISCRIPTEVENTTYPE_INDEX_CHANGED           = 0x6EAEFEB9
UISCRIPTEVENTTYPE_ITEM_HOLD_ACTION_STARTED = 0x37104AFD
UISCRIPTEVENTTYPE_DATA_ADJUSTABLE_CHANGED = 0xBB5C7348
UISCRIPTEVENTTYPE_VIRTUAL_KEYBOARD_RESULT = 0x73446E9B
```

In Lua compare with `` `ITEM_SELECTED` `` etc. Message layout: type at offset 0, parameter hash at 16, item container
at 24.

## Troubleshooting

| Problem | Fix |
|---|---|
| HUD widget does not show | its slot is hidden: enable a context that shows it ([hud.md](docs/hud.md)) |
| app opens empty | fill its paths before launching it |
| list stays empty | use an alias the running flow registers ([templates.md](docs/templates.md)) |
| your scene does not load | new names only; every texture dictionary and widget template it uses in the flow's `Resources` |
| overlay stays after you are done | `DatabindingRemoveDataEntry` the container, destroy the state machine |

## Credits and license

Event handling from [aaron1a12/wild](https://github.com/aaron1a12/wild), `dataview.lua` from
[meta-hub/redm-events](https://github.com/meta-hub/redm-events). Related: [redm-cores](https://github.com/draobrehtom/redm-cores).

Free to use, modify and redistribute, in personal or commercial resources.
