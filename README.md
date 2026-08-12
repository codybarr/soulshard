# Soulshard

A desktop-first, top-down 2D action RPG built with Godot 4. Explore handcrafted zones, defeat readable encounters, and shape weapons with slotable shards.

## Requirements

- Godot **4.6 or newer**
- Native desktop environment (macOS, Windows, or Linux)

## Run

Open `project.godot` in Godot and press **F6/F5**, or run from the command line:

```bash
godot --path .
```

On macOS, if Godot is not in `PATH`:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

The current proving ground supports eight-direction movement with **WASD**, arrow keys, or the left stick. Use **J**, left mouse, or controller X for the three-hit sword combo; press again during an attack to queue the next cut. Training dummies validate hitboxes, damage, knockback, and hit-stop. Press **F3** for the debug overlay. The foundation screen remains available at `res://scenes/world/foundation.tscn` to exercise local save/load (**F5** / **F9**).

## Verify

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit-after 3
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://tests/foundation_smoke.tscn
```

The smoke test verifies default state creation plus a versioned JSON save/load round trip in `user://`.

## Architecture

- `autoload/` — `EventBus`, `GameState`, and `SaveService`
- `data/` — authored game definitions grouped by content domain
- `scenes/` — player, enemies, zones, world, UI, and effects
- `scripts/` — cross-scene gameplay domains
- `art/` — engine-ready sprites, tilesets, UI, and effects
- `plans/` — architecture and staged implementation plan

See [`plans/ARCHITECTURE.md`](plans/ARCHITECTURE.md) and [`plans/TODO.md`](plans/TODO.md).
