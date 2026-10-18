# RedM UIAPPS — Native UI Examples and Lua Snippets for RedM Scripts

> A practical collection of **RedM UIAPPS scripts** — working Lua examples that show how to talk to the game's native UI layer using the DataBinding API. HUD elements, menus, overlays, scoreboards, and native UIApps like `fast_travel_menu`, `satchel`, and `shop`.
>
> **New: a full reference read from the game files.** Every app, launch entry, UI event, DataBinding path, list template and HUD context RDR2 ships — see [docs/](docs/) and [how it was made](docs/research.md).

**Looking for premium RedM scripts?** Browse the full catalog at **[lumanstudio.com](https://lumanstudio.com)** — production-ready RedM and FiveM scripts for VORP, RedEM:RP, and standalone servers.

---

## Table of Contents

- [What is UIAPPS in RedM](#what-is-uiapps-in-redm)
- [Why This Collection Exists](#why-this-collection-exists)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Included Examples](#included-examples)
- [Reference From the Game Files](#reference-from-the-game-files)
- [Native UIApps Reference](#native-uiapps-reference)
- [Beyond the 37 Apps](#beyond-the-37-apps)
- [UIScript Event Types](#uiscript-event-types)
- [Working With DataBinding](#working-with-databinding)
- [Event Handling Pattern](#event-handling-pattern)
- [Integration Tips](#integration-tips)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Compatibility](#compatibility)
- [Related RedM Scripts](#related-redm-scripts)
- [Support](#support)
- [License](#license)

---

## What is UIAPPS in RedM

**UIApps** (also written *UIAPPS*) are RedM's native front-end applications — the weapon wheel, satchel, map, shop browser, fast travel menu, pause menu, and dozens of other screens that ship with the game. Each one is a self-contained UI surface driven by a **hash name** and a **data container** populated through the DataBinding API.

When you write **RedM scripts** that need to touch game-native UI, you have two paths:

1. Build a full NUI overlay in HTML/CSS/JS.
2. Re-use the native UIApp the game already renders.

Path two is faster, looks consistent with the rest of RedM, and is what most production servers use for things like HUD readouts, menus, and minigame overlays. The trade-off is that the DataBinding API is sparsely documented — most knowledge lives in Discord pins, scattered gists, and reverse-engineering notes.

This repository collects the patterns in one place, as runnable Lua snippets.

## Why This Collection Exists

Most RedM scripts published on GitHub are finished products. What is missing is a library of **minimal, focused examples** that teach one UIAPPS concept per file — the kind of snippet you can read in a minute and lift into your own resource.

The goal here is not a framework. It is a reference. Read a file, copy what you need, adapt it. Every example is under a hundred lines and uses only RedM natives — no external dependencies.

## Features

- 19 standalone Lua examples for common RedM UIAPPS use cases
- A reference generated from the game's own `data/ui` files: 37 apps with their launch entries, 172 flow blocks, 277 UI events, 2,826 DataBinding paths, 458 list item templates and 96 HUD contexts
- Coverage of native UIApps: `fast_travel_menu`, `satchel`, `shop`, `hud_quick_select`, `translation_overlay`, and more
- DataBinding API patterns: containers, strings, ints, hashes, bools, item lists
- UIScript event handling examples with `eUIScriptEventType` hash table
- Pure RedM natives, no framework dependencies
- Compatible with **VORP**, **RedEM:RP**, and standalone RedM servers
- Free to reuse in personal or commercial RedM scripts

## Requirements

- RedM server (build 1311 or newer recommended)
- CFX server artifacts up to date
- Basic Lua knowledge
- Optional: VORP Core or RedEM:RP if you plan to integrate with those frameworks

## Installation

This is a collection of snippets, not a resource: there is no `fxmanifest.lua`, and several files register the same command names. Copy the file you need into your own resource's client scripts:

```lua
-- fxmanifest.lua of your resource
fx_version 'adamant'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_scripts { 'dataview.lua', 'fast_travel.lua' }
```

The examples that read UI events need `dataview.lua` from [meta-hub/redm-events](https://github.com/meta-hub/redm-events/blob/main/dataview.lua).

## Quick Start

Open any example file, read the top comment for the reference source, and trigger the behavior in-game. Most examples either register a chat command or run on resource start. For instance, `countdown.lua` registers `/textCountDown` — run it, watch the native countdown overlay tick down.

Here is the shortest possible UIAPPS example — showing the passive-mode icon near the radar:

```lua
local passiveIcon = DatabindingAddDataContainerFromPath("", "PassiveIcon")
local isVisible   = DatabindingAddDataBool(passiveIcon, "isVisible", true)
local setState    = DatabindingAddDataInt(passiveIcon, "setState", 1) -- max 3
```

Three lines — container, bool, int — and the game renders the icon. That is the shape of almost every UIAPPS interaction.

## Included Examples

| File | What It Shows |
|---|---|
| `bounty_top_right.lua` | Rendering a live bounty string in the top-right HUD with show/hide toggling |
| `countdown.lua` | Driving the native `MPCountdown` overlay from Lua, ticking a 10-second timer |
| `fast_travel.lua` | Launching the `FAST_TRAVEL_MENU` UIApp, populating it with dynamic items, and handling selection/exit events |
| `helperTextfields.lua` | Binding scoreboard-style helper labels (hits/misses, or any two-field pair) |
| `honor_level.lua` | Driving the honor level UI element with custom values |
| `horseStats.lua` | Binding horse stat values (health, stamina, bonding) into the native stats card |
| `money_hud.lua` | Writing to the Tithing money HUD — camp funds and player cash side by side |
| `passive_icon_near_radar.lua` | Showing the passive-mode indicator next to the minimap |
| `rank_bar.lua` | Driving `mp_rank_bar` — player name, rank number, and XP bar fill |
| `satchel.lua` | Interacting with the native `satchel` UIApp and reading its dataview |
| `scoreboard_top_right_corner.lua` | Scoreboard-style overlay pinned to the top-right corner |
| `shop.lua` | Launching the `shop` UIApp and populating it with items |
| `timer_top_center.lua` | Center-top timer overlay, useful for events and minigames |
| `translate.lua` | Using the `translation_overlay` UIApp for localized string rendering |
| `wanted.lua` | Driving the wanted-level UI system |
| `weapon_stats.lua` | Opening the weapon inspection flow (`PM_FLOW_WEAPON_INSPECT`) and binding stats |
| `hud_context.lua` | Turning HUD contexts on and off; the money HUD and the honor meter shown through `HUD_CTX_TITHING` and `HUD_CTX_HONOR_SHOW` |
| `flow_block_host.lua` | Hosting any flow block with an entry point, without its app — the shop item card through `shop_browsing` / `catalog_item_inspection` |
| `ui_events.lua` | A small helper that polls a UI event channel and hands each event to a callback |

The last three are built from the game-file reference and have not been run in game yet.

Each file is self-contained and can be copied out of the repo into your own RedM script.

## Reference From the Game Files

RDR2's UI is data: state machines (`flow/`), scenes (`screens/`), reusable widgets (`widgets/`), the HUD visibility tree and a list of apps, all PSO `.ymt` files under `data/ui` in the game archives. The pages in [`docs/`](docs/) are generated from those files with codexcli and [`tools/`](tools/):

| Page | What it answers |
|---|---|
| [docs/apps.md](docs/apps.md) | What each app is called, which flow it starts, its entry points with hashes for `LaunchUiappByHashWithEntry`, its event channels |
| [docs/datastore.md](docs/datastore.md) | Every DataBinding path a screen reads, what type it takes, and which screen reads it |
| [docs/events.md](docs/events.md) | Every event channel and the parameter hashes a screen or flow sends on it |
| [docs/templates.md](docs/templates.md) | The aliases for `DatabindingInsertUiItemToListFromContextStringAlias` and the widget each one builds |
| [docs/hud.md](docs/hud.md) | Which HUD slots each `HUD_CTX_*` context hides or shows |
| [docs/flows.md](docs/flows.md) | All 172 flow blocks, their entries and scenes |
| [docs/research.md](docs/research.md) | How the UI files fit together, and what is still unknown |

Some of what it settles: the magic numbers in community scripts are named entry points (`-702860656` is `catalog_item_inspection`, `-649639953` is `horse_stats_info_card`, both in `shop_browsing`), and `1670279562` in `money_hud.lua` is `HUD_CTX_TITHING`.

## Native UIApps Reference

These are the 37 app ids in `data/ui/applaunch/launchconditions.ymt`, the ones `LaunchUiappByHash` accepts. [docs/apps.md](docs/apps.md) has each one's flow and entry points:

```
abilities                 map
character_creator         mp_mission_info
collectors                naturalist
coupons                   opening_credits_sequence
crafting                  pause_menu
ending_credits            player_menu
fast_travel_menu          policies_menu
help_menu                 progress_menu
hub                       rewards
hud_quick_select          rockstar_editor
landing_page              role_progression
leaderboards              satchel
lobbies_menu              saveload_menu
                          settings_menu
                          shop_browsing
                          shop_menu
                          social_club_feed
                          social_club_login
                          stats_menu
                          store
                          trader
                          translation_overlay
                          virtual_keyboard
                          weapon_locker
```

Each UIApp expects a specific set of data-binding paths. [docs/datastore.md](docs/datastore.md) lists them per root container, with the value type.

## Beyond the 37 Apps

- **Any flow block can be shown from a script.** `_UIFLOWBLOCK_REQUEST` → `_UIFLOWBLOCK_ENTER` → `UI_STATE_MACHINE_CREATE` hosts a flow without its app; `weapon_stats.lua` and `flow_block_host.lua` do this. There are 172 flow blocks.
- **HUD widgets need their context.** A HUD widget is always loaded; it shows when its slot is visible, and a slot is visible when a context that shows it is on. [docs/hud.md](docs/hud.md) maps contexts to slots.
- **Lists take any alias the running flow registered**, and list items carry their own event channel and select hash, so a script can define events of its own.
- **Paths can be relative.** A widget sets a binding context and its children bind relative paths; `Tithing` → `CampFunds` → `dollars` is one path. The reference resolves these chains.

## UIScript Event Types

When a UIApp is running, it posts events into a per-app queue. Pull them with `EventsUiGetMessage` (or the equivalent native) and branch on the event hash:

```cpp
enum eUIScriptEventType : Hash
{
    UISCRIPTEVENTTYPE_INVALID                          = 0,
    UISCRIPTEVENTTYPE_ITEM_FOCUSED                     = 0x984750E7,
    UISCRIPTEVENTTYPE_ITEM_UNFOCUSED                   = 0xDA4D50F6,
    UISCRIPTEVENTTYPE_ITEM_SELECTED                    = 0xB841988C,
    UISCRIPTEVENTTYPE_NEW_ACTIVITY                     = 0x36FB9F7E,
    UISCRIPTEVENTTYPE_NEW_PAGE                         = 0x8445624D,
    UISCRIPTEVENTTYPE_TAB_PAGE_INCREMENT               = 0x29EB385C,
    UISCRIPTEVENTTYPE_TAB_PAGE_DECREMENT               = 0xD4E9057D,
    UISCRIPTEVENTTYPE_INDEX_CHANGED                    = 0x6EAEFEB9,
    UISCRIPTEVENTTYPE_INDEX_CHANGE_REQUESTED           = 0x462BEB80,
    UISCRIPTEVENTTYPE_ITEM_SELECTED_ACTION_SUCCEEDED   = 0xE29A8210,
    UISCRIPTEVENTTYPE_ITEM_HOLD_ACTION_STARTED         = 0x37104AFD,
    UISCRIPTEVENTTYPE_ITEM_HOLD_ACTION_CANCELLED       = 0x9BA74C01,
    UISCRIPTEVENTTYPE_DATA_ADJUSTABLE_CHANGED          = 0xBB5C7348,
    UISCRIPTEVENTTYPE_DATA_ADJUSTABLE_CHANGED_ABSOLUTE = 0x60624708,
    UISCRIPTEVENTTYPE_FEED_MESSAGE_INTERACTED          = 0xB018ED22,
    UISCRIPTEVENTTYPE_STICKY_FEED_CLEARED              = 0xE5733EE0,
    UISCRIPTEVENTTYPE_PAGED_COLLECTION_INITIALIZED     = 0xF8D8E7EA,
    UISCRIPTEVENTTYPE_PAGED_COLLECTION_REQUEST         = 0x15F05555,
    UISCRIPTEVENTTYPE_PAGED_COLLECTION_RESET           = 0xF9307213,
    UISCRIPTEVENTTYPE_ENTER_TRANSITION_COMPLETED       = 0x5DF51FC0,
    UISCRIPTEVENTTYPE_EXIT_TRANSITION_COMPLETED        = 0x7C0102D8,
    UISCRIPTEVENTTYPE_VIRTUAL_KEYBOARD_RESULT          = 0x73446E9B,
    UISCRIPTEVENTTYPE_PINNED_ITEM_VALIDATION           = 0x7D26E5FF,
};
```

In Lua, use the hash form directly — `ITEM_FOCUSED`, `ITEM_SELECTED`, etc. — and compare against the 32-bit int you read from the event buffer. The parameter hash at offset 16 (`FAST_TRAVEL_UI_EVENT_EXIT` and the like) tells which control sent it; [docs/events.md](docs/events.md) lists them per channel.

## Working With DataBinding

The DataBinding API is the glue between Lua and the native UI renderer. The basic shape is:

1. **Get or create a container** — `DatabindingAddDataContainerFromPath(parent, name)` or `DatabindingGetDataContainerFromPath(path)`.
2. **Attach fields** — `DatabindingAddDataString`, `DatabindingAddDataInt`, `DatabindingAddDataHash`, `DatabindingAddDataBool`, `DatabindingAddDataFloat`.
3. **Write updates** — `DatabindingWriteDataString`, `DatabindingWriteDataInt`, etc. These take the handle returned from the `Add` call.
4. **Clean up** — `DatabindingRemoveDataEntry` when the UI closes.

For lists (shops, fast-travel destinations, menus with dynamic rows) use `DatabindingAddUiItemList` and `DatabindingInsertUiItemToListFromContextStringAlias`. See `fast_travel.lua` for the complete pattern.

## Event Handling Pattern

The canonical pattern for reading UIApp events in Lua:

```lua
local msg = DataView.ArrayBuffer(8 * 4)
msg:SetInt32(0,  0)
msg:SetInt32(8,  0)
msg:SetInt32(16, 0)
msg:SetInt32(24, 0)

if EventsUiGetMessage(`hud_quick_select`, msg:Buffer()) ~= 0 then
    if msg:GetInt32(0) == `ITEM_FOCUSED` then
        -- handle focus
    end
end
```

`DataView` ships as a small helper from [meta-hub/redm-events](https://github.com/meta-hub/redm-events/blob/main/dataview.lua).

Reference implementation from [aaron1a12/wild](https://github.com/aaron1a12/wild/blob/9235aaa39696691ff26977ff1d2c18fe67971ef5/wild-core/client/cl_weaponWheel.lua#L28).

## Integration Tips

**With VORP.** UIApps and DataBinding do not conflict with VORP's menu system. Use UIApps for native RedM surfaces (satchel, shop, fast travel) and keep VORP menus for custom screens.

**With RedEM:RP.** Same layering. RedEM:RP handles inventory and character data; UIApps render the in-game UI around them. `weapon_stats.lua` in this repo is pulled directly from the redemrp_inventory pattern.

**Standalone.** Many of the smaller RedM scripts in production use UIApps exclusively with no framework. It is a valid architectural choice.

## Troubleshooting

**Container returns 0.** The container does not exist yet. Use `DatabindingAddDataContainerFromPath` instead of `Get…` on first call, or call `Add…` conditionally after a `Get` check.

**UIApp opens empty.** You did not populate its expected data container before launching it. Many UIApps read their data at launch time and do not refresh automatically — populate first, `LaunchUiappByHash` second.

**Events do not arrive.** Confirm the UIApp is actually running (`IsUiappRunningByHash`) and that you are polling with `EventsUiIsPending` / `EventsUiGetMessage` each frame.

**Changes do not appear.** Some UIApps cache on open. Close and re-launch after changing the container, or use `DatabindingWrite…` on an existing handle instead of `Add…` twice.

**HUD element does not show.** Its HUD slot is hidden. Enable a context that shows the slot — see [docs/hud.md](docs/hud.md) and `hud_context.lua`.

**List stays empty.** The alias passed to `DatabindingInsertUiItemToListFromContextStringAlias` must be one the running flow registered ([docs/templates.md](docs/templates.md)).

**HUD elements persist after you are done.** Call `DatabindingRemoveDataEntry` on each handle when cleaning up — otherwise the overlay stays visible.

## FAQ

**Can I use these examples in commercial RedM scripts?**
Yes. The repository is freely reusable — personal, open-source, or commercial RedM scripts.

**Does this work on FiveM?**
No. UIApps are RedM-specific. For FiveM scripts, NUI overlays are the equivalent path.

**Will these break on future RedM builds?**
UIScript event hashes are stable across recent builds. Individual DataBinding paths for UIApps can shift if Rockstar reships content — pin your server build and test updates on staging first.

**Where can I buy polished RedM scripts built on these patterns?**
**[Luman Studio](https://lumanstudio.com)** — premium FiveM and RedM scripts with documentation, updates, and support.

**Do I need VORP or RedEM:RP?**
No. Every example works on a standalone RedM server. Framework integration is optional.

## Compatibility

- RedM server build 1311+
- VORP Core (any recent version)
- RedEM:RP (any recent version)
- Standalone RedM servers

## Related RedM Scripts

- **[redm-cores](https://github.com/draobrehtom/redm-cores)** — percentage-based health, stamina, and dead-eye management library
- **[Luman Studio catalog](https://lumanstudio.com)** — premium FiveM and RedM scripts
- **[Luman Studio Tebex](https://lumanstudio.tebex.io)** — direct store
- **[meta-hub/redm-events](https://github.com/meta-hub/redm-events)** — `dataview.lua` helper used by most UIScript event examples
- **[aaron1a12/wild](https://github.com/aaron1a12/wild)** — excellent reference implementation for native UI patterns

## Support

- Website: **[lumanstudio.com](https://lumanstudio.com)**
- Store: **[lumanstudio.tebex.io](https://lumanstudio.tebex.io)**
- YouTube: **[@lumanstudio](https://www.youtube.com/@lumanstudio)**

Found a bug, have an example you want added, or spotted a native that changed? Open an issue.

## License

Free to use, modify, and redistribute in any RedM scripts, RedM servers, or commercial resources.
