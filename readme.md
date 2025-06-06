# VEX++

This is a game that i made to be an improvement to the games [vex](https://www.newgrounds.com/portal/view/609073), [vex 2](https://www.newgrounds.com/portal/view/620004), and [vex 3](https://www.newgrounds.com/portal/view/643827)

## Table of Contents

- [Game Controls](#game-controls)
- [Options](#options)
- [Settings](#settings)
- [Explanations](#explanations)
- [General Information](#general-information)

## Game Controls

### Editor Controls

- **show_keybinds**: can show and hide the control rebind menu while editing a level - control editor starts visible on the main menu

- **editor_select**: when pressed while hovering over a block it will select the block under your mouse cursor. move the mouse while pressed to move the selected block

- **editor_edit_special**: when pressed while hovering over a block it will bring up a menu for the currently hovered block
- **editor_scale**: hold this button to switch from moving blocks with editor_select to scaling blocks
- **editor_rotate**: hold this button to switch from moving blocks with editor_select to rotating blocks
- **editor_delete**: press this while selecting a block with editor_select to delete it from the level
- **duplicate_block**: press this to create a copy of the last selected block
- **editor_pan**: press this to enable pan mode, in which instead of moving the blocks with editor_select you scroll around the level instead
- **move_player_to_mouse**: when pressed the player will teleport to the mouse position
- **restart**: resets the player to the last collected checkpoint or the level start if no checkpoint was reached
- **full_restart**: resets the player to the level start
- **save**: saves the current level
- **load**: opens the menu to allow you to choose a new level to load
- **reload_map_from_last_save**: reloads the map from the level file and restores the player position to the last checkpoint or the level start if no checkpoint was reached
- **fully_reload_map**: reloads the map from the level file and resets the player to the level start
- **quit**: quits the game
- **toggle_hitboxes**: toggles hitboxes visibility on and off - sometimes won't update the hitboxes correctly, so to fix press reload_map_from_last_save/fully_reload_map and hitboxes will update correctly
- **new_map_folder**: press to create a new map, which can be a collection of levels all able to access each other through the "inner level" block
- **new_level_file**: press to create a new level, inside the current map folder
- **toggle_fullscreen**: toggles fullscreen temporarily and is reverted when reopening the game. to change the default screen mode go to the settings
- **toggle_pause**: toggles the moving blocks in the level - only meant for editing, and is not meant to be used to beat levels
- **editor_disable_grid_snap**: hold to set the grid snap to 1px to allow for more precise editing

### Play Controls

- **jump**: causes the player to jump and if the camera will refocus the player
- **down**: causes the player to crouch or slide while on the ground and if in the air will cause the player to be able to break glass when fell on
- **left**: causes the player to move left
- **right**: causes the player to move right

### Settings

- **blockPickerBlockSize**: the size of the block picker in pixels. changing this makes the blocks in the block picker and the block picker height equaly larger or smaller
- **autosaveInterval**: how long in seconds between autosaves. 0 is disabled
- **saveOnExit**: saves the level when opening the menu - make work on game close and on enter inner level
- **editorScrollSpeed**: changes the speed the camera moves at when using editor_pan
- **editorBarScrollSpeed**: changes the speed of scrolling through the editor bar. set negative to invert scroll direction
- **windowMode**: changes the default window mode (fullscreen/windowed)
- **smallerSaveFiles**: makes all save files smaller by removing unnessary padding, which also makes it harder to read
- **warnWhenOpeningLevelInOlderGameVersion**: when you open a level in an older version of the game, you will be warned that it may not work properly.
- **warnWhenOpeningLevelInNewerGameVersion**: when you open a level in an newer version of the game, you will be warned that it may not work properly.
- **editorBarOffset**: can be used to place the editor bar a the bottom of the screen instead of the top, or just shift it down a bit to prevent it from being covered by other programs while in fullscreen or when the window is otherwise at the top of the screen
- **blockGhostAlpha**: changes the alpha of the ghost blocks - used to show where a block is actualy placed suchas keys that have been collected, moving blocks that are moving, ect.
- **hoveredBlockGhostAlpha**: same as blockGhostAlpha but for when you hover over them and not working yet.
- **saveLevelOnWin**: save the level when you win it.
- **showHitboxes**: sets the default hitbox state for whenever entering a level
- **showIconOnSave**: shows a save icon when the level is saved. low opacity when save stared and fully visible when saving finished.
- **confirmKeyAssignmentDeletion**: adds a confirmation dialog before removing keys from the keybinds list.
- **allowRotatingAnything**: allows rotating any blocks regardless of if it is meant to be rotated or not.
- **allowScalingAnything**: allows scaling any blocks regardless of if it is meant to be rotated or not.
- **blockSnapGridSize**: the size of the grid that blocks will snap to when being moved or resized.
- **noCornerGrabsForScaling**: when grabing a block at a corner it will only resize the bnlock on the side that had less grab area. not appearing to work correctly yet.
- **allowCustomColors**: disabling this prevents levels from using custom colors.
- **showGridInEdit**: shows the grid in when in edit mode.
- **showGridInPlay**: shows the grid in when in play mode.