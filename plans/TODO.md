# Soulshard Development TODO — Godot 4 Action RPG

Build in order. Every completed stage must remain playable, save cleanly, and avoid introducing broad systems before the core action-RPG loop is fun.

- [x] **1. Create the Godot 4 foundation**
  - Create a Godot 4 project targeting native desktop builds.
  - Establish the project layout from `plans/ARCHITECTURE.md`.
  - Add `GameState`, `SaveService`, and any minimal event bus as autoloads.
  - Configure pixel-art / low-resolution painted rendering, input actions, base UI theme, and a debug overlay.
  - Remove the Three.js/Vite prototype only after the Godot project runs successfully.

- [ ] **2. Build the player movement and presentation slice**
  - [x] Implement directional top-down movement with `CharacterBody2D` and responsive facing.
  - [x] Add a fixed top-down/3/4 follow camera.
  - [x] Add placeholder idle and move presentation states; defer dodge, hurt, and death behavior to the combat slice.
  - [x] Use named `Marker2D` weapon anchors and directional offsets so sword orientation is explicit and easy to tune.
  - [x] Add solid world collision and a small test room (procedural placeholder art; TileMap deferred until terrain authoring).

- [ ] **3. Establish data-driven combat**
  - [x] Create authored definitions for the starter sword combo timings, damage, knockback, and hit-stop.
  - [x] Implement a light-attack three-hit combo, damage, knockback, and hit-stop.
  - [ ] Implement charged/heavy attack and dodge invulnerability; one spell is complete.
  - [x] Use `Area2D` hitboxes/hurtboxes activated only during authored attack windows; do not use distance-only hits.
  - [x] Keep the player action flow explicitly gated between movement and attack states; add enemy action states with the enemy slice.
  - [ ] Add combat debug controls for hitboxes, active action, damage events, and time scale.

- [ ] **4. Make a readable enemy encounter**
  - Implement one melee enemy: idle, pursue, telegraph, attack, recovery, hurt, death, and respawn.
  - Implement one ranged enemy with a clear projectile attack.
  - Tune enemy contact, attack wind-ups, player invulnerability frames, knockback, and resource costs.
  - Create a compact combat arena and verify the fight is enjoyable before adding broader systems.

- [ ] **5. Build the first handcrafted zone**
  - Create the forest/ruin zone with TileMaps, collision, spawn points, interactables, exits, and stable persistent IDs.
  - Add pickups, a checkpoint, basic enemy encounters, and a zone transition seam.
  - Persist player location, checkpoint, pickup state, and persistent defeated-enemy state.
  - Implement versioned local JSON saves and at least one migration test.

- [ ] **6. Validate the shard and weapon-progression loop**
  - Add one weapon with three shard slots.
  - Implement six to eight shards that visibly modify weapon, spell, or passive behavior.
  - Add minimal weapon proficiency/leveling.
  - Build a compact inventory/equipment UI for equipping shards and using consumables.
  - Ensure build choices are meaningful without relying on survival crafting or inventory bloat.

- [ ] **7. Finish the vertical slice**
  - Create a miniboss with a readable multi-step encounter.
  - Add a basic reward, vendor or reward-selection moment, and a return/checkpoint flow.
  - Play through: start → choose/equip shards → fight both enemy types → defeat miniboss → save → quit → resume.
  - Fix feel, readability, and save/load failures before adding quests, more zones, more gear, cloud saves, or web deployment.

- [ ] **8. Expand only after the slice is proven**
  - Add more handcrafted zones, quests, enemy families, elites, bosses, vendors, and constrained equipment choices.
  - Add content validation for IDs and definitions.
  - Evaluate cloud saves, authentication, and web export only when the local single-player game is stable and fun.
