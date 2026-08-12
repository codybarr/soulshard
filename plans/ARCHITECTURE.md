# Architecture Plan: Godot 4 Top-Down Action RPG

## Chosen direction

Soulshard is a single-player, desktop-first **top-down / 3/4-view 2D action RPG** built in **Godot 4**. It uses deliberate pixel art or a low-resolution painted style, rather than 3D models rendered with a pixelated effect.

The game takes structural inspiration from *Forager*'s readable, compact world, but it is **not** a survival-crafting game or a metroidvania. Its loop is traditional action RPG progression:

> Explore handcrafted zones → defeat enemies and complete encounters → collect equipment and shards → refine a combat build → unlock stronger content.

The project is moving away from Three.js and 3D because asset rigging, animation retargeting, camera behavior, and 3D weapon presentation create disproportionate iteration cost. A fixed 2D camera, sprite animation, and authored weapon anchors make combat presentation more predictable and easier to tune.

## Why Godot 4

Godot is the chosen engine over LÖVE2D because it provides the editor workflows this project needs without requiring custom engine infrastructure:

- TileMap, collision, navigation, particles, UI, audio, and scene composition are first-class.
- Sprite-based character animation and weapon anchors are straightforward to inspect and author.
- Handcrafted zones and combat encounters can be assembled and tested quickly in the editor.
- GDScript supports small, focused, agent-friendly gameplay scripts.
- Native desktop builds are the initial target; web export can be evaluated later.

LÖVE2D would be viable for a code-first Lua project, but would require building too much level-editing, collision-authoring, animation-preview, and UI infrastructure ourselves.

## Technical stack

| Layer | Choice |
| --- | --- |
| Engine | Godot 4.x |
| Language | GDScript |
| Rendering | Godot 2D renderer; pixel-art or low-resolution painted assets |
| Physics | Godot `CharacterBody2D`, `Area2D`, and collision shapes |
| Levels | Godot scenes, TileMaps, and authored encounter data |
| UI | Godot `Control` nodes and theme resources |
| Local saves | Versioned JSON save files via a `SaveService` autoload |
| Initial deployment | Native desktop builds |

## Project structure

```text
autoload/
  GameState.gd          # Current session and persistent game state
  SaveService.gd        # Save/load, schema versions, migrations
  EventBus.gd           # Cross-system gameplay/UI events where needed

data/
  items/                # Item Resources or JSON definitions
  weapons/
  shards/
  enemies/
  encounters/
  quests/
scenes/
  player/
  enemies/
  world/
  zones/
  ui/
  effects/
scripts/
  combat/
  inventory/
  progression/
  quests/
  world/
art/
  sprites/
  tilesets/
  ui/
  effects/
```

Use Godot `Resource` definitions where inspector authoring is useful, with stable string IDs for anything persisted. JSON is acceptable for bulk content if it improves authoring or validation.

## Runtime model

### Player and combat

- Fixed top-down/3/4 camera; no free orbit camera.
- Directional movement with dodge, light combo, charged/heavy attack, and a spell.
- Model player and enemy actions as small, explicit state machines: idle, move, attack, dodge, hurt, dead, etc.
- Use `Area2D` hitboxes and hurtboxes activated only during authored attack windows.
- Attach weapon sprites/effects to named `Marker2D` anchors. Directional animation and anchor offsets, not 3D rigging, determine how a sword is held.
- Combat definitions own damage, timing, knockback, invulnerability frames, costs, and cooldowns; input and rendering do not hard-code those values.

### World and zones

Zones are handcrafted Godot scenes containing terrain, collision, spawn points, interactables, encounter definitions, and stable persistent IDs.

```text
scenes/zones/forest_ruins.tscn
  ├─ TileMapLayer terrain and decoration
  ├─ StaticBody2D collision
  ├─ SpawnPoints
  ├─ Encounters
  ├─ Interactables
  └─ Exit / checkpoint markers
```

Zones may be compact and interconnected, but progression should be driven chiefly by combat strength, quests, keys, and story objectives—not movement abilities in a metroidvania structure.

### RPG systems

The primary build system is shards: slotable modifiers analogous to materia that change weapons, spells, or passive behavior. Supplement this with weapon proficiency/leveling, constrained equipment slots, consumables, quests, vendors, elite encounters, and bosses.

Prefer a few meaningful build choices over inventory bloat or resource-grind crafting.

## Persistence

Save data is plain, versioned data—never nodes, physics objects, or other scene instances.

```gdscript
{
  "schema_version": 1,
  "updated_at": "ISO-8601 timestamp",
  "player": {
    "level": 1,
    "experience": 0,
    "health": 100,
    "stats": {},
    "weapon_id": "starter_sword",
    "weapon_progress": {},
    "equipped_shards": [],
    "inventory": []
  },
  "location": {
    "zone_id": "forest_ruins",
    "checkpoint_id": "entrance"
  },
  "world": {
    "opened_ids": [],
    "defeated_ids": [],
    "quest_states": {},
    "flags": {}
  }
}
```

Autosave at checkpoints, zone transitions, meaningful inventory changes, quest completion, and a modest debounced interval. Every persistent chest, pickup, enemy, door, and trigger needs a stable authored ID.

Cloud saves, authentication, and online features are explicitly deferred until the local action-RPG loop is proven fun.

## First vertical slice

Build one forest/ruin zone containing:

1. Directional movement, dodge, light combo, charged attack, and one spell.
2. One melee enemy and one ranged enemy with clear telegraphs and hit reactions.
3. Pickups, a checkpoint, and reliable local save/load.
4. One weapon with three shard slots.
5. Six to eight shards that make visible, testable combat changes.
6. A miniboss encounter.
7. A compact inventory/equipment screen.

**Exit criterion:** the player can make a build choice, feel it change combat, defeat the miniboss, quit, and resume at the latest checkpoint.

## Non-negotiable rules

1. Content and tuning values are data-driven.
2. Saves are versioned compatibility contracts; changes require migrations.
3. Persistent game objects have stable authored IDs.
4. Local saves work offline.
5. Gameplay state is separate from scene nodes and UI state.
6. Finish the vertical slice before expanding systems, content breadth, cloud services, or platform targets.
