# Tools

Scripts that turn the game's UI files into the reference pages in [`docs/`](../docs).

| Script | Input | Output |
|---|---|---|
| `extract.py` | a folder of UI files converted to XML | `catalog.json`: apps, flows, entries, events, templates, DataBinding paths, HUD contexts, element trees of every screen |
| `gen_docs.py` | `catalog.json` | `docs/apps.md`, `flows.md`, `events.md`, `templates.md`, `hud.md`, `datastore.md` |

Both use only the Python standard library.

## Getting the XML

The UI files are PSO `.ymt` inside the game's `.rpf` archives. codexcli, the command-line build of CodeX, converts
them:

```powershell
$env:CODEX_GAME_DIR = 'D:\SteamLibrary\steamapps\common\Red Dead Redemption 2'

# 1. every UI file, in every archive
codexcli find "data\ui\" > uifiles.txt

# 2. keep the patched copy of each (update_4 > update_1 > data_0 > common_0) and write a list:
#    <path-in-rpf><TAB><output.xml>
# 3. convert them all with the archives opened once
codexcli xmlmany list.txt
```

The UI files are RBF (binary XML). Older codexcli builds lose two things when they write them as XML: the
`type="UIRectangle"` attribute that names an element's class (children came out as plain `<Item>`), and text
content, written as `<>VALUE</>`. Use a build with the `DataBag` fix: the classes are then real (`UIImage`, `UIMeter`,
`uiMaskBehavior` …) and the XML builds back into a `.ymt` with `codexcli fromxml <name>.rbf.xml <out.ymt>`.
`extract.py` still reads the older output.

## Building the catalog and the docs

```bash
python -I tools/extract.py path/to/xml catalog.json
python -I tools/gen_docs.py catalog.json docs
```

`extract.py` prints a summary:

```
 "files": 2236, "flows": 172, "apps": 37, "channels": 35, "eventParams": 277,
 "templates": 727, "datastorePaths": 2826, "hudSlots": 66, "hudContexts": 96, "ui": 1403
```

## Textures for previews

The Luman Studio reference page (`uiapps.html`) draws screens with the game's textures. `codexcli xml` on a
`.ytd` writes its textures as `.dds` next to the XML. A texture pack in a patch archive (`update_4.rpf\…\menu_textures.ytd`)
holds only the textures that changed, so extract the base pack first and the patches over it.
