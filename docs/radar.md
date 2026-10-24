# The default radar: size and position

For drawing around the game's radar from NUI. No native returns the radar's rectangle; these numbers come from
`screens/hud/hud.ymt`, `screens/hud/hud_persistent.xml`, `safeframe_configurations.ymt` and `stylescatalog.ymt`.
They match the redm-uiapps renderer; not yet checked against an in-game screenshot.

## Where it comes from

| Step | Value |
|---|---|
| HUD safe area `safeframe_hud` | 95 % of the width, 90 % of the height (player setting `display.hud.safeframePercentageX/Y`) |
| bottom-left cell of `GRD_CornerItems` (rows 8 : 3 : 1 : 6) | 7/18 of the safe height |
| `VB_BottomLeftCorner`, a viewbox | scales the 432 × 397 radar container to that height: `unit = H × 0.9 × 7/18 / 397` |
| radar `ACTUAL_RADAR_SIZE_*` | regular 245, expanded 334, simple 153 (× unit), bottom-left of the safe area |

## Regular radar, in pixels

| Screen | Size | Left | Top | Centre |
|---|---|---|---|---|
| 1920 × 1080 | 233.3 | 48 | 792.7 | 164.6, 909.4 |
| 2560 × 1440 | 311.0 | 64 | 1057.0 | 219.5, 1212.5 |
| 3840 × 2160 | 466.6 | 96 | 1585.4 | 329.3, 1818.7 |

Size ≈ 0.216 × screen height. The left margin follows the width (2.5 %), the bottom margin the height (5 %).

| Inside the radar | Share of the size |
|---|---|
| outer circle (ring, north arrow) | 1.0 |
| map disc | 0.910 |
| map edge (gutter) | 0.869 |
| radar + cores above it, height | 1.257 |

## Code

```js
// NUI. mode = GetMinimapType(): 1 regular, 2 expanded, 3 simple (0 off)
function radarRect(mode = 1, safeX = 0.95, safeY = 0.9, W = innerWidth, H = innerHeight) {
  const unit = (H * safeY * 7 / 18) / 397;
  const size = [0, 245, 334, 153][mode] * unit;
  const left = W * (1 - safeX) / 2;
  const bottom = H * (1 - safeY) / 2;
  return {
    left, top: H - bottom - size, size,
    cx: left + size / 2, cy: H - bottom - size / 2,
    r: size / 2,                       // outer circle
    mapR: size * 0.455,                // map disc
    coresTop: H - bottom - size * 1.257,
  };
}
```

```lua
-- client: tell the page the radar mode and whether it is hidden
local last
CreateThread(function()
    while true do
        local mode, hidden = GetMinimapType(), IsRadarHidden()
        local key = mode .. tostring(hidden)
        if key ~= last then
            last = key
            SendNUIMessage({ type = 'radar', mode = mode, hidden = hidden })
        end
        Wait(250)
    end
end)
```

## Caveats

- The player's HUD safe-zone slider moves the radar, and no RDR3 native reads it: keep `safeX` / `safeY` configurable.
- The radar size style has a `DPI_XXHigh` variant (350 instead of 245); when it applies is not known.
- A row under the map holds the GPS distance text; whether an active route lifts the radar is not checked.

To move the radar instead, see [examples/radar-top-right](../examples/radar-top-right).
