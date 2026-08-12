extends Node

## Cross-scene lifecycle events only. Feature-local events belong on their owners.
signal game_saved(save_path: String)
signal game_loaded(save_path: String)
signal save_failed(message: String)
signal game_state_reset
