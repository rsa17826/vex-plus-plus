# VEX++

This is a game that i made to be an improvement to the games [vex](https://www.newgrounds.com/portal/view/609073), [vex 2](https://www.newgrounds.com/portal/view/620004), and [vex 3](https://www.newgrounds.com/portal/view/643827) by adding many new features.

## Table of Contents

- [Game Controls](#game-controls)
- [Options](#options)
- [Settings](#settings)
- [Explanations](#explanations)
- [General Information](#general-information)
- [command line arguments](#command-line-arguments)

## extra info

- press editor_edit_special on a block in the block picker to modify the default options of that block that will be used when first placing it
- launcher not required, but allows easy access to any old version, and allows you to know when there is an update whenever opening the launcher.
- launcher also has a button to update the launcher

<!-- start auto -->
<!-- 
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property
    - **path**: a string of points separated by commas each being an x, then y, that are used to make the path. the points are relative to the path node, not global positions.
    - **endReachedAction**: what will happen when the block reaches the end of the path.
    - **startOnLoad**: when the level is loaded or the player dies the track will start immediately.
    - **startOnPress**: starts to move when a button with the same signalId is pressed.
    - **startWhilePressed**: starts to move when a button with the same signalId is pressed and pauses when the button is released.
    - **signalInputId**: the id of the signal it is listening for
    - **restart**: only available when using a button start mode.
    - **forwardSpeed**: the speed that blocks are moved at while going forward along the path.
    - **backwardSpeed**: the speed that blocks are moved at while going backwards along the path.
    - **addNewPoint**: creates a new point right after this in the path
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **signalOutputId**: the id that will be sent
    - **level**: the level that you will be sent to
    - **requiredLevelCount**: the amount of levels that you must beat before being able to enter this level
    - **multiUse**: if true you can recollect this checkpoint else this checkpoint will only be collectable once
    - **direction**: the direction it will move, user means the direction the player is facing when grabbing it
    - **unCollect**: temporarily uncollects the star
    - **maxCooldown**: maximum time between shots in seconds (default = 1.0)
    - **portalId**: the id of this portal as used for finding an exit portal
    - **exitId**: the id this portal uses to find its exit portal
    - **action**: the action to detect
    - **state**: the state to detect
    - **signalAInputId**: a signal to detect
    - **signalBInputId**: other signal to detect
 -->

## Controls

- **show_keybinds**: can show and hide the control rebind menu while editing a level - control editor starts visible on the main menu
- **jump**: causes the player to jump and if the camera will refocus the player
- **down**: causes the player to crouch or slide while on the ground and if in the air will cause the player to be able to break glass when fell on
- **left**: causes the player to move left
- **right**: causes the player to move right
- **editor_select**: when pressed while hovering over a block it will select the block under your mouse cursor. move the mouse while pressed to move the selected block
- **editor_edit_special**: when pressed while hovering over a block it in the block picker will allow you to edit defaults for that block
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
- **editor_disable_grid_snap**: hold to set the grid snap to 1px to allow for more precise editing.
- **editor_box_select**: hold to create a box select that selects all blocks within it to allow moving them together
- **move_selected_left**: moves the last selected block 1 grid step left.
- **move_selected_right**: moves the last selected block 1 grid step right.
- **move_selected_up**: moves the last selected block 1 grid step up.
- **move_selected_down**: moves the last selected block 1 grid step down.
- **exit_inner_level**: when pressed while inside an inner level it will taky you up 1 level, if the level you are in has not been beaten before no data will be saved even if stars had been collected, if it has been beaten before then stars will be saved when exiting a level this way.
- **toggle_hide_non_ghosts**: when in editor and this is enabled all non ghost blocks are hidden.
- **block_z_up**: moves the block back in the list of nodes to make it render before the other blocks. the selected block is moved up until it is before 1 block that it is currently in front of and not just by 1.
- **block_z_down**: same as block_z_up but moves it down instead of up.
- **invert_single_axis_align**: hold while moving a block to invert the value of singleAxisAlignByDefault.
- **edit_level_mods**: press to toggle the level mod editor on and off.
- **save_current_location_as_last_checkpoint**: when pressed will save the players current location as a temporary checkpoint
- **copy_block_position**: copies the last selected blocks position
- **copy_block_scale**: copies the last selected blocks scale
- **copy_block_rotation**: copies the last selected blocks rotation
- **paste_block_position**: sets the rotation of the current block to that of the last copied rotation
- **paste_block_scale**: sets the last selected blocks scale to the last copied scale
- **paste_block_rotation**: sets the last selected blocks rotationthat the last copied rotation
- **"CREATE NEW - _block name_"**: creates a new instance of _block name_ the same is if it was picked from the editor bar.

## Settings

### editor bar

- **editorBarBlockSize**: the size of the block picker in pixels. changing this makes the blocks in the block picker and the block picker height equally larger or smaller
- **editorBarScrollSpeed**: changes the speed of scrolling through the editor bar. set negative to invert scroll direction
- **editorBarOffset**: can be used to place the editor bar a the bottom of the screen instead of the top, or just shift it down a bit to prevent it from being covered by other programs while in fullscreen or when the window is otherwise at the top of the screen
- **editorBarColumns**: the amount of columns in the editor bar. if you want a horizontal layout just make this number large and if using a vertical layout make this number small.
- **editorBarPosition**: moves the editor bar to either top, bottom, left, or right of the screen

### grid

- **showGridInEdit**: shows the grid in when in edit mode.
- **blockGridSnapSize**: the size of the grid that blocks will snap to when being moved or resized.
- **showGridInPlay**: shows the grid in when in play mode.

### save

- **autosaveInterval**: how long in seconds between autosaves. 0 is disabled
- **saveOnExit**: saves the level when opening the menu - make work on game close and on enter inner level
- **smallerSaveFiles**: makes all save files smaller by removing unnecessary padding, which also makes it harder to read
- **saveLevelOnWin**: save the level when you win it.
- **showIconOnSave**: shows a save icon when the level is saved. low opacity when save stared and fully visible when saving finished.

### window

- **windowMode**: changes the default window mode (fullscreen/windowed)

### warnings

- **warnWhenOpeningLevelInOlderGameVersion**: when you open a level in an older version of the game, you will be warned that it may not work properly.
- **warnWhenOpeningLevelInNewerGameVersion**: when you open a level in an newer version of the game, you will be warned that it may not work properly.
- **confirmKeyAssignmentDeletion**: adds a confirmation dialog before removing keys from the keybinds list.

### editor settings

- **randomizeLevelModifiersOnLevelCreation**: when creating a new level the level modifiers will be set randomly
- **minDistBeforeBlockDraggingStarts**: the distance the mouse has to move before the block will be moved or scaled
- **autoPanWhenClickingEmptySpace**: when dragging on an empty space, with no blocks on it, it will treat it as if editor_pan was pressed.
- **movingPathNodeMovesEntirePath**: if true moving this will move the entire path, if false it will only move the first point
- **newlyCreatedBlocksRotationTakesPlayerRotation**: if true when the player is rotated all new blocks that can be rotated will be rotated to the players current direction instead of the default direction, eg if the player has gravity upside down creating a checkpoint will create it upside down.
- **deleteLastSelectedBlockIfNoBlockIsCurrentlySelected**: if false then to delete a block you must be currently selecting it, if true then pressing delete will always remove the block that was selected most recently.
- **mouseLockDistanceWhileRotating**: this is how far away the mouse will be from the center of the selected object while holding the editor_rotate key. higher numbers move the mouse farther away. set to 0 to disable.
- **editorScrollSpeed**: changes the speed the camera moves at when using editor_pan
- **noCornerGrabsForScaling**: when grabbing a block at a corner it will only resize the bnlock on the side that had less grab area.
- **blockGhostAlpha**: changes the alpha of the ghost blocks - used to show where a block is actually placed suchas keys that have been collected, moving blocks that are moving, etc.
- **singleAxisAlignByDefault**: if true blocks will only be movable along a single axis at a time by default. if false blocks can be moved freely.

### limits

- **allowRotatingAnything**: allows rotating any blocks regardless of if it is meant to be rotated or not.
- **allowScalingAnything**: allows scaling any blocks regardless of if it is meant to be rotated or not.

### camera

- **cameraUsesDefaultRotationInEditor**: makes is so that when the editor ui is shown the camera is reset to default rotation instead of keeping the last rotation.
- **dontChangeCameraRotationOnGravityChange**: makes is so that when when the gravity changes the camera will not be rotated.
- **cameraRotationOnGravityChangeHappensInstantly**: makes is so that when the gravity changes the camera rotates instantly instead of rotating smoothly.

### theme

- **selectedBlockOutlineColor**: the outline color of the currently selected block
- **hoveredBlockOutlineColor**: the outline color of the current hovered block
- **blockOutlineSize**: the size of the block outline both for hover and select
- **boxSelectColor**: the color that the box select will be
- **pathColor**: the color of the path created in the level editor by the path block.
- **levelTilingBackgroundPath**: this image will be tiled across the level.
- **editorBackgroundPath**: path to the background image for the editor.
- **editorBackgroundScaleToMaxSize**: if true the background image will scale to fit the screen.
- **editorStickerPath**: path to the sticker image for the editor.
- **toastStayTime**: how long the toast stays on screen in seconds.
- **theme**: the theme used for the entire application.

### info

- **showHoveredBlocksList**: if true will show a list of the blocks under the mouse
- **showLevelModsWhileEditing**: if true the level modifiers will be shown in the editor
- **showLevelModsWhilePlaying**: if true the level modifiers will be shown while playing
- **showUnchangedLevelMods**: if true the level modifiers will be shown even if the value is the same as the default
- **showLevelLoadingProgressBar**: shows a progress bar for loading levels.
- **showLevelLoadingBehindProgressBar**: shows the blocks being placed when loading a level. otherwise shows a grey background behind the loading bar instead.
- **showPathBlockInPlay**: the path block, showing where the path starts, will be visible in play mode.
- **showPathLineInPlay**: the path line, showing the path attached blocks will travel, will be visible in play mode.
- **showPathEditNodesInPlay**: the path edit nodes, showing where each segment of the the path is at, will be visible in play mode.

### signal display

- **showSignalList**: if true a list of all signals, the blocks that are sending the signals and weather or not the signal is active
- **showTotalActiveSignalCounts**: adds a number showing the total amount of signals that are currently sending on each signal id
- **showWhatBlocksAreSendingSignals**: adds an image of the block that is sending on each signal id and a number showing the amount of blocks of the same type that are sending the signal
- **onlyShowActiveSignals**: only shows signals if the signal is active and being sent

### player

- **playerRespawnTime**: the time that the player takes to respawn after dying

### online level list

- **onlyShowLevelsForCurrentVersion**: the load online levels button only shows levels for the current version instead of for all versions.
- **loadOnlineLevelListOnSceneLoad**: when the online level list is loaded the level data will immediately be downloaded
- **autoExpandAllGroups**: when loading an online level list, all groups are expanded, if false only the group for the current game version is expanded

### debug

- **showHitboxes**: sets the default hitbox state for whenever entering a level

### misc

- **openExportsDirectoryOnExport**: if true, after exporting a level, it will open the exports directory.

## Blocks

- **basic**: has solid collision

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **slope**: has solid collision on the borders but not in the middle.

  - scalable
  - rotatable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **path**: a string of points separated by commas each being an x, then y, that are used to make the path. the points are relative to the path node, not global positions.

  - scalable
  - rotatable
  - **settings**:
    - **path**: a string of points separated by commas each being an x, then y, that are used to make the path. the points are relative to the path node, not global positions.
    - **endReachedAction**: what will happen when the block reaches the end of the path.
    - **startOnLoad**: when the level is loaded or the player dies the track will start immediately.
    - **startOnPress**: starts to move when a button with the same signalId is pressed.
    - **startWhilePressed**: starts to move when a button with the same signalId is pressed and pauses when the button is released.
    - **signalInputId**: the id of the signal it is listening for
    - **restart**: only available when using a button start mode.
    - **forwardSpeed**: the speed that blocks are moved at while going forward along the path.
    - **backwardSpeed**: the speed that blocks are moved at while going backwards along the path.
    - **addNewPoint**: creates a new point right after this in the path
    - **color**: sets the modulate property

- **10x spike**: kills the player on contact

  - scalable
  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **10x solar spike**: kills the player on contact if lights are on

  - scalable
  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **10x inverse solar spike**: kills the player on contact if lights are off

  - scalable
  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **invisible**: gets less visible the closer the player is to it

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **updown**: has solid collision and moves up than down

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **downup**: has solid collision and moves down than up

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **leftRight**: has solid collision and moves right than left

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **rightLeft**: has solid collision and moves than left right

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **growing block**: grows and shrinks

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **gravity rotator**: rotates gravity to face the direction of it points. is triggered by player/bomb/pushable box entering it.

  - scalable
  - rotatable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **water**: when the player enters they are changed to swim mode and reverted to platformer mode on exit.

  - scalable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **solar**: has solid collision when lights are on.

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **inverse solar**: has solid collision when lights are off.

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **pushable box**: has solid collision and can be pushed by the player while the player is on ground and in platformer mode.

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **microwave**: has solid collision

  - scalable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **locked box**: has solid collision but when the player comes in contact with it and has a key, the key and block are disabled.

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **floor button**: when pressed by player/bomb/pushable box it will send a signal

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **signalOutputId**: the id that will be sent
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **button deactivated wall**: active only whern its signal is off.

  - scalable
  - canAttachToPaths
  - **settings**:
    - **signalInputId**: the id of the signal it is listening for
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **glass**: has solid collision but when the player comes in contact with it from the top and is holding down and has downwards velocity, the glass breaks and is disabled.

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **falling**: has solid collision but when the player comes in contact with it from the top it will start to fall for ~2s before respawning.

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **donup**: like a falling block, but in reverse

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **bouncy**: has solid collision but when the player comes in contact with it from the top it will put the player in the bouncing state and bounce back up after a short period of time. the time and bounce height is determined by the blocks y size with bigger time and height from larger y scales. the player bounce direction is away from the top of the block so if the block is rotated, the bounce will be different.

  - scalable
  - rotatable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **spark block/counterClockwise**: has solid collision, kills the player on contact with the spark that moves counterClockwise along the edge of the block when the spark contacts water, the wayer will become eletric and kill the player if the player is inside the water

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **spark block/clockwise**: has solid collision, kills the player on contact with the spark that moves clockwise along the edge of the block when the spark contacts water, the wayer will become eletric and kill the player if the player is inside the water

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **inner level**: has solid collision but when the player crouches on top of it the player will be transported to a new level, which upon being beat will send the player back to the previous level on top of it.

  - scalable
  - canAttachToPaths
  - **settings**:
    - **level**: the level that you will be sent to
    - **requiredLevelCount**: the amount of levels that you must beat before being able to enter this level
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **goal**: when the player reaches this block they win and if inside an inner level they will go back to the previous level else they will just be reset to the last saved checkpoint.

  - scalable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **requiredLevelCount**: the amount of levels that you must beat before being able to enter this level
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **buzsaw**: kills the player on contact

  - scalable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **bouncing buzsaw**: kills the player on contact and falls until hitting a solid block where it will start bouncing up until reaching the start height where it will start falling back down again

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **cannon**: NOT WORKING YET

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **checkpoint**: sets the player respawn location to this location

  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **multiUse**: if true you can recollect this checkpoint else this checkpoint will only be collectable once
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **closing spikes**: kills the player on contact will open slowly then close quickly

  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **gravity down lever**: when the player is inside the lever and presses down the player gravity will be halved or reverted to normal if it was halved before

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **gravity up lever**: when the player is inside the lever and presses down the player gravity will be doubled or reverted to normal if it was doubled before

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **speed up lever**: when the player is inside the lever and presses down the player speed will be doubled or reverted to normal if it was doubled before

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **growing buzsaw**: kills the player on contact grows from 1x to 3x size then back to 1x, briefly pausing at 1x and 3x

  - scalable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **key**: when the player comes in contact with this it will start following the player until ised to unlock a locked box

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **light switch**: when the player comes in contact with this it will toggle the lights on/off which will disable/enable all solar blocks.

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **red only light switch**: when the player comes in contact with this it will toggle the lights off leaving only the inverse solar blocks on.

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **blue only light switch**: when the player comes in contact with this it will toggle the lights on leaving only the solar blocks on.

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **pole**: when the player contacts this the player will be able to swing on it and jump off with jump or drop off with down. when jumping off if in the blue part of the indicator then the jump will gain height else it will be like a drop

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **pole quadrant**: spins 4 poles

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **pulley**: when the player comes in contact with this it will move bring the player with it until there is no ceiling or wall in front of it where it will drop the player and return to the start location

  - canAttachToThings
  - **settings**:
    - **direction**: the direction it will move, user means the direction the player is facing when grabbing it
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **color**: sets the modulate property

- **quadrant**: kills the player on contact and will spin clockwise

  - scalable
  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **rotating buzzsaw**: kills the player on contact and will spin clockwise

  - scalable
  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **scythe**: kills the player on contact and will spin counterclockwise

  - scalable
  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **shurikan spawner**: spawns a set of 3 shuricans which

  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **star**: when the player collects this it will stay collected. the star counter in the top left shows the current number of stars collected and total for the current level. the inner levels will have their star counter on the block before entering.

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **unCollect**: temporarily uncollects the star
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **laser**: when the player is in range the laser will shoot projectiles in the direction it is facing, these projectiles have a cooldown and are destroyed on contact with solid blocks. if the projectile hits a bomb the bomb will be exploded. the red circle on the laser shows the current cooldown - fully red means ready to fire.

  - scalable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **maxCooldown**: maximum time between shots in seconds (default = 1.0)
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **targeting laser**: when the player is in range the laser will apply heat, more heat is applied if the player is closer. when the player is in water heat will dissipate faster. if the heat ray hits a bomb the bomb will be exploded.

  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **death boundary**: kills the player on contact

  - scalable
  - **settings**:
    - **color**: sets the modulate property

- **block death boundary**: kills most moving blocks on contact including collected keys and removes effects from the player when the player enters

  - scalable
  - **settings**:
    - **color**: sets the modulate property

- **noWJ**: prevents the player from walljumping, wallsliding, and wall hanging when in contact with the player

  - scalable
  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **falling spike**: kills the player on contact when in line with the player it will start falling until hitting a solid block

  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **portal**: when the player contacts this it will take the player to the first portal in the level with a portalId matching the portals targetId

  - scalable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **portalId**: the id of this portal as used for finding an exit portal
    - **exitId**: the id this portal uses to find its exit portal
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **bomb**: like a pushable box but explodes when hit with a falling spike, falling to fast and colliging with the ground, being squished, or having a box, other bomb fall to fast on it, or being exploded by another bomb. when the player is inside of the explosion, they will be killed, when a block is in the explosion, it will be disabled. microwaves cant be exploded.

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **sticky floor**: makes the player not be able to jump while in contact with this and also prevents the player from regaining cyote time

  - scalable
  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **arrow**: points at things; can be rotated

  - rotatable
  - canAttachToThings
  - canAttachToPaths
  - **settings**:
    - **canAttachToThings**: allows the block to attach to other things that are not paths, for paths change **canAttachToPaths**
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **conveyer**: moves things on top of it in the direction of the arrows and momentum persists for a short time after leaving this block. works on pushable box, bomb and player, works both vertically and horizontally.

  - scalable
  - rotatable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **oneway**: like a block in the direction it is facing and like air in all other directions.

  - scalable
  - rotatable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **undeath**: if the player collides with this block while flying bact to the spawnpoint the player will instead be revived right where the player collided with the block at. user restarts will bypass this block.

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

- **input detector**: when the player is pressing the set direction a signal will be emitted.

  - rotatable
  - **settings**:
    - **action**: the action to detect
    - **signalOutputId**: the id that will be sent
    - **color**: sets the modulate property

- **player state detector**: sends a signal if the player is in the specified state

  - rotatable
  - **settings**:
    - **state**: the state to detect
    - **signalOutputId**: the id that will be sent
    - **color**: sets the modulate property

- **not gate**: will invert a signal.

  - **settings**:
    - **signalInputId**: the id of the signal it is listening for
    - **signalOutputId**: the id that will be sent
    - **color**: sets the modulate property

- **and gate**: will send a signal only if both signals are on.

  - **settings**:
    - **signalAInputId**: a signal to detect
    - **signalBInputId**: other signal to detect
    - **signalOutputId**: the id that will be sent
    - **color**: sets the modulate property

- **crumbling**: if the player collides with this block the block will start to crumble and be destroyed after a certain amount of time. only respawns on death.

  - scalable
  - canAttachToPaths
  - **settings**:
    - **canAttachToPaths**: allows this block to attach to paths
    - **color**: sets the modulate property

<!-- end auto -->

<!--
- \*\*.*[\r\s\n]+-\*
-->

## command line arguments

- **--loadMap**
  - when opening the game it loads a map by name or NEWEST to load the newest map.
- **--loadOnlineLevels**
  - opens the online levels list when starting the game.

## extra

### custom editor bar block placements

to reorder the blocks in the editor bar, create a file called `editorBar.sds` and if using the launcher, place it in the `game data` folder otherwise just place it in the game's directory.
[example file](./editorBar.sds)
