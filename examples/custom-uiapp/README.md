# A UI app of its own

A card drawn by the game's own UI, from a scene and a flow block that do not exist in RDR2. Both are streamed from
this resource. Copy the folder into `resources/`, `ensure custom-uiapp`, then `/myapp` or `/myapp any text`.


## Why it works

Tested in RedM (see [docs/research.md](../../docs/research.md#shipping-ui-files-in-a-resource)):

- a file that **replaces** a game UI file (`hud.ymt`, `tithing.ymt`) in `stream/` is ignored;
- a flow block and a scene with **new names** in `stream/` are loaded. A flow lists its scene as a streaming
  resource (`UIObjectSceneStreamingDependencyResource`) and shows it with `StateUIObjectStreamedSceneHost`.

## Files

| File | What it is |
|---|---|
| `src/luman_uiapp_scene.rbf.xml` | the scene: a panel with an ink background, a title, a divider, a text and a footer. The texts read `ScriptDatastoreRoot.LumanApp.title / body / footer` |
| `src/luman_uiapp_flow.rbf.xml` | the flow block `luman_uiapp_flow`: loads two game texture dictionaries and the scene, then shows it |
| `stream/*.ymt` | the two built with codexcli |
| `client.lua` | fills `LumanApp`, hosts the flow block, counts down in the title, closes on Backspace or after 20 s |

Build after editing a source (codexcli from the CodeX repository, commit 47fc097 or later):

```
codexcli fromxml src\luman_uiapp_scene.rbf.xml stream\luman_uiapp_scene.ymt
codexcli fromxml src\luman_uiapp_flow.rbf.xml stream\luman_uiapp_flow.ymt
```

## Making your own

- Give the flow (`<ID>`) and the scene (file name, `SceneName`, the resource `Name`) names no game file uses.
- Build the scene from the element types the game uses (`UIPanel`, `UIGrid`, `UIStackPanel`, `UIImage`, `UIText`,
  `UIRectangle`, `UIMeter` …) and its styles (`HEADER_MAIN`, `BODY`, `INK_BACKGROUND_COLOR` …); the reference pages
  and the game's own screens are the examples to copy from.
- Any texture dictionary the scene uses must be listed in the flow's `Resources`.
- Bind texts, visibility and values to `ScriptDatastoreRoot.<YourRoot>.*` and write them from Lua with `DATABINDING_*`.

Not tested yet: input handled by the scene itself (selectable items, `ScriptEventOp` events back to Lua), and
streamed widgets used as list item templates.
