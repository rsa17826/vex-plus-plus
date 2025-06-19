# VEX++

This is a game that i made to be an improvement to the games [vex](https://www.newgrounds.com/portal/view/609073), [vex 2](https://www.newgrounds.com/portal/view/620004), and [vex 3](https://www.newgrounds.com/portal/view/643827)

## Table of Contents

- [Game Controls](#game-controls)
- [Options](#options)
- [Settings](#settings)
- [Explanations](#explanations)
- [General Information](#general-information)

## extra info

- press editor_edit_special on a block in the block picker to modify the default options of that block that will be used when first placing it
- launcher not required, but allows easy access to any old version, and allows you to know when there is an update whenever opening the launcher.
- launcher also has a button to update the launcher

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
- **editor_box_select**: hold to create a box select that selects all blocks within it to allow moving them together

### Play Controls

- **jump**: causes the player to jump and if the camera will refocus the player
- **down**: causes the player to crouch or slide while on the ground and if in the air will cause the player to be able to break glass when fell on
- **left**: causes the player to move left
- **right**: causes the player to move right

### Settings

- **blockPickerBlockSize**: the size of the block picker in pixels. changing this makes the blocks in the block picker and the block picker height equally larger or smaller
- **autosaveInterval**: how long in seconds between autosaves. 0 is disabled
- **saveOnExit**: saves the level when opening the menu - make work on game close and on enter inner level
- **editorScrollSpeed**: changes the speed the camera moves at when using editor_pan
- **editorBarScrollSpeed**: changes the speed of scrolling through the editor bar. set negative to invert scroll direction
- **windowMode**: changes the default window mode (fullscreen/windowed)
- **smallerSaveFiles**: makes all save files smaller by removing unnecessary padding, which also makes it harder to read
- **warnWhenOpeningLevelInOlderGameVersion**: when you open a level in an older version of the game, you will be warned that it may not work properly.
- **warnWhenOpeningLevelInNewerGameVersion**: when you open a level in an newer version of the game, you will be warned that it may not work properly.
- **editorBarOffset**: can be used to place the editor bar a the bottom of the screen instead of the top, or just shift it down a bit to prevent it from being covered by other programs while in fullscreen or when the window is otherwise at the top of the screen
- **blockGhostAlpha**: changes the alpha of the ghost blocks - used to show where a block is actually placed suchas keys that have been collected, moving blocks that are moving, etc.
- **hoveredBlockGhostAlpha**: same as blockGhostAlpha but for when you hover over them and not working yet.
- **saveLevelOnWin**: save the level when you win it.
- **showHitboxes**: sets the default hitbox state for whenever entering a level
- **showIconOnSave**: shows a save icon when the level is saved. low opacity when save stared and fully visible when saving finished.
- **confirmKeyAssignmentDeletion**: adds a confirmation dialog before removing keys from the keybinds list.
- **allowRotatingAnything**: allows rotating any blocks regardless of if it is meant to be rotated or not.
- **allowScalingAnything**: allows scaling any blocks regardless of if it is meant to be rotated or not.
- **blockSnapGridSize**: the size of the grid that blocks will snap to when being moved or resized.
- **noCornerGrabsForScaling**: when grabbing a block at a corner it will only resize the bnlock on the side that had less grab area. not appearing to work correctly yet.
- **allowCustomColors**: disabling this prevents levels from using custom colors.
- **showGridInEdit**: shows the grid in when in edit mode.
- **showGridInPlay**: shows the grid in when in play mode.
- **showLevelLoadingProgressBar**: shows a progress bar for loading levels.
- **showLevelLoadingBehindProgressBar**: shows the blocks being placed when loading a level. otherwise shows a grey background behind the loading bar instead.
- **onlyShowLevelsForCurrentVersion**: the load online levels button only shows levels for the current version instead of for all versions.

### block settings that apply to many blocks

- **color**: changes the modulate of the block
- **attachesToThings**: if true the block will be able to attach to most blocks that move
  - updown
  - downup
  - leftright
  - falling
  - pushable box
  - ? might be more

### Blocks

- **basic**: has solid collision

  - scalable
  - **settings**:
    - **color**

- **single spike**: kills the player on contact

  - rotatable
  - **settings**:
    - **color**
    - **attachesToThings**

- **10x spike**: kills the player on contact

  - rotatable
    - i plan to replace this and the single spike with a scalable spike that tiles the spike texture instead
  - **settings**:
    - **color**
    - **attachesToThings**

- **updown**: has solid collision and moves up than down

  - **settings**:
    - **color**

- **downup**: has solid collision and moves down than up

  - **settings**:
    - **color**

- **leftright**: has solid collision and moves right than left

  - **settings**:
    - **color**

- **water**: when the player enters they are changed to swim mode and reverted to platformer mode on exit.

  - scalable
  - **settings**:
    - **color**
    - **attachesToThings**

- **solar**: has solid collision when lights are on, touch a lightswitch to turn the lights off.

  - scalable
  - **settings**:
    - **color**

- **slope**: has solid collision on the borders but not in the middle.

  - scalable
  - **settings**:
    - **color**

- **pushable box**: has solid collision and can be pushed by the player while the player is on ground and in platformer mode.

  - scalable
  - **settings**:
    - **color**

- **microwave**: has solid collision

  - scalable
  - **settings**:
    - **color**

- **locked box**: has solid collision but when the player comes in contact with it and has a key, the key and block are disabled.

  - scalable
  - **settings**:
    - **color**

- **glass**: has solid collision but when the player comes in contact with it from the top and is holding down and has downwards velocity, the glass breaks and is disabled.

  - scalable
  - **settings**:
    - **color**

- **falling**: has solid collision but when the player comes in contact with it from the top it will start to fall for ~2s before respawning.

  - scalable
  - **settings**:
    - **color**

- **bouncy**: has solid collision but when the player comes in contact with it from the top it will put the player in the bouncing state and bounce back up after a short period of time. the time and bounce height is determined by the blocks y size with bigger time and height from larger y scales.

  - scalable
  - **settings**:
    - **color**

- **inner level**: has solid collision but when the player crouches on top of it the player will be transported to a new level, which upon being beat will send the player back to the previous level on top of it.

  - scalable
  - **settings**:
    - **color**
    - **level**: the level that you will be sent to
    - **requiredLevelCount**: the amount of levels that you must beat before being able to enter this level

- **goal**: when the player reaches this block they win and if inside an inner level they will go back to the previous level else they will just be reset to the last saved checkpoint.

  - scalable
  - i plan to add better win effects for beating the main level
  - **settings**:
    - **color**
    - **attachesToThings**
    - **requiredLevelCount**: the amount of levels that you must beat before being able to win by touching this goal

- **buzsaw**: kills the player on contact

  - scalable
  - **settings**:
    - **color**
    - **attachesToThings**

- **bouncing buzsaw**: kills the player on contact and falls until hitting a solid block where it will start bouncing up until reaching the start height where it will start falling back down again

  - scalable
  - **settings**:
    - **color**

- **cannon**: NOT WORKING YET

  - rotatable cannons could be good
  - **settings**:
    - **color**
    - **attachesToThings**

- **checkpoint**: sets the player respawn location to this location

  - when collected will turn the lights back on
  - scalable
  - **settings**:
    - **color**
    - **attachesToThings**
    - **multiUse**: if true you can recollect this checkpoint else this checkpoint will only be collectable once

- **closing spikes**: kills the player on contact will open slowly then close quickly

  - scalable
  - **settings**:
    - **color**
    - **attachesToThings**

- **Gravity Down Lever**: when the player is inside the lever and presses down the player gravity will be halfed or reverted to normal if it was halved before

  - **settings**:
    - **color**
    - **attachesToThings**

- **Gravity Up Lever**: when the player is inside the lever and presses down the player gravity will be doubled or reverted to normal if it was doubled before

  - **settings**:
    - **color**
    - **attachesToThings**

- **speed Up Lever**: when the player is inside the lever and presses down the player speed will be doubled or reverted to normal if it was doubled before

  - **settings**:
    - **color**
    - **attachesToThings**

- **key**: when the player comes in contact with this it will start following the player until ised to unlock a locked box

  - **settings**:
    - **color**
    - **attachesToThings**

- **light switch**: when the player comes in contact with this it will disable all solar blocks

  - **settings**:
    - **color**
    - **attachesToThings**

- **Pulley**: when the player comes in contact with this it will move bring the player with it until there is no ceiling or wall in front of it where it will drop the player and return to the start location

  - when on Pulley you can press down to drop off of it
  - when on Pulley you can press up to become temporarily invincible
  - **settings**:
    - **color**
    - **attachesToThings**
    - **direction**
      - left: it will move left
      - left: it will move right
      - user: it will move whichever way the player was facing when entering it

- **Quadrant**: kills the player on contact and will spin clockwise

  - **settings**:
    - **color**
    - **attachesToThings**

- **Rotating Buzzsaw**: kills the player on contact and will spin clockwise

  - **settings**:
    - **color**
    - **attachesToThings**

- **Scythe**: kills the player on contact and will spin counterclockwise

  - **settings**:
    - **color**
    - **attachesToThings**

- **star**: when the player collects this it will stay collected

  - i plan to add a star counter to show how many stars you have collected and the total for current level and for all inner levels
  - i plan to make it so that it remembers which stars have been collected and not just if a star has been collected
  - **settings**:
    - **color**
    - **attachesToThings**

- **death boundary**: kills the player on contact

  - **settings**:
    - **color**

- **block death boundary**: kills most moving blocks on contact including collected keys and removes effects from the player when the player enters

  - effects removed are
    - speed lever
    - low gravity lever
    - high gravity lever
  - **settings**:
    - **color**

- **nowj**: prevents the player from walljumping, wallsliding, and wall hanging when in contact with the player

  - **settings**:
    - **color**
    - **attachesToThings**

- **falling spike**: kills the player on contact when in line with the player it will start falling until hitting a solid block

  - **settings**:
    - **color**
    - **attachesToThings**

- **portal**: when the player contacts this it will take the player to the first portal in the level with a portalId matching the portals targetId
  - **settings**:
    - **color**
    - **attachesToThings**
    - **portalId**: the id of this portal as used for finding an exit portal
    - **exitId**: the id this portal uses to find its exit portal
      - eg portalId = 1, exitId = 2, means that entering this portal will take the player to the portal with portalId = 2 and will be found with a portal set to have exitId = 1
- **pole**: when the player contacts this the player will be able to swing on it and jump off with jump or drop off with down. when jumping off if in the blue part of the indicator then the jump will gain height else it will be like a drop

  - **settings**:
    - **color**
    - **attachesToThings**

- **pole quadrant**: spins 4 poles

  - **settings**:
    - **color**
    - **attachesToThings**

- **growing buzsaw**: kills the player on contact grows from 1x to 3x size then back to 1x, briefly pausing at 1x and 3x

  - **settings**:
    - **color**
    - **attachesToThings**

- **spark counterClockwise**: has solid collision, kills the player on contact with the spark that moves counterClockwise along the edge of the block when the spark contacts water, the wayer will become eletric and kill the player if the player is inside the water

  - **settings**:
    - **color**

- **spark clockwise**: has solid collision, kills the player on contact with the spark that moves clockwise along the edge of the block when the spark contacts water, the wayer will become eletric and kill the player if the player is inside the water

  - **settings**:
    - **color**

- **bomb**: like a pushable box but explodes when hit with a falling spike, falling to fast and colliging with the ground, being squished, or having a box, other bomb fall to fast on it, or being exploded by another bomb. when the player is inside of the explosion, they will be killed, when a block is in the explosion, it will be disabled. microwaves cant be exploded.

  - **settings**:
    - **color**

- **custom block**: loads a list of blocks from a file inside the custom blocks folder for the current level with a name of where. does nothing if the where is not set,

  - **settings**:
    - **where**: the path to the file in the custom blocks folder.

- **sticky floor**: makes the player not be able to jump while in contact with this and also prevents the player from regaining cyote time

  - **settings**:
    - **attachesToThings**

- **arrow**: points at things; can be rotated

  - **settings**:
    - **attachesToThings**
