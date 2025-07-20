# VEX++

This is a game that i made to be an improvement to the games [vex](https://www.newgrounds.com/portal/view/609073), [vex 2](https://www.newgrounds.com/portal/view/620004), and [vex 3](https://www.newgrounds.com/portal/view/643827) by adding many new features.

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
- **editor_disable_grid_snap**: hold to set the grid snap to 1px to allow for more precise editing.
- **editor_box_select**: hold to create a box select that selects all blocks within it to allow moving them together
- **exit_inner_level**: when pressed while inside an inner level it will taky you up 1 level, if the level you are in has not been beaten before no data will be saved even if stars had been collected, if it has been beaten before then stars will be saved when exiting a level this way.
- **move_selected_left**: moves the last selected block 1 grid step left.
- **move_selected_right**: moves the last selected block 1 grid step right.
- **move_selected_up**: moves the last selected block 1 grid step up.
- **move_selected_down**: moves the last selected block 1 grid step down.
- **toggle_hide_non_ghosts**: when in editor and this is enabled all non ghost blocks are hidden.
- **block_z_up**: moves the block back in the list of nodes to make it render before the other blocks. the selected block is moved up until it is before 1 block that it is currently in front of and not just by 1.
- **block_z_down**: same as block_z_up but moves it down instead of up.
- **invert_single_axis_align**: hold while moving a block to invert the value of singleAxisAlignByDefault.
- **"CREATE NEW - _block name_"**: creates a new instance of _block name_ the same is if it was picked from the editor bar.

### Play Controls

- **jump**: causes the player to jump and if the camera will refocus the player
- **down**: causes the player to crouch or slide while on the ground and if in the air will cause the player to be able to break glass when fell on
- **left**: causes the player to move left
- **right**: causes the player to move right

### Settings

- **editorBarBlockSize**: the size of the block picker in pixels. changing this makes the blocks in the block picker and the block picker height equally larger or smaller
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
- **noCornerGrabsForScaling**: when grabbing a block at a corner it will only resize the bnlock on the side that had less grab area.
- **allowCustomColors**: disabling this prevents levels from using custom colors.
- **showGridInEdit**: shows the grid in when in edit mode.
- **showGridInPlay**: shows the grid in when in play mode.
- **showLevelLoadingProgressBar**: shows a progress bar for loading levels.
- **showLevelLoadingBehindProgressBar**: shows the blocks being placed when loading a level. otherwise shows a grey background behind the loading bar instead.
- **onlyShowLevelsForCurrentVersion**: the load online levels button only shows levels for the current version instead of for all versions.
- **deleteLastSelectedBlockIfNoBlockIsCurrentlySelected**: if false then to delete a block you must be currently selecting it, if true then pressing delete will always remove the block that was selected most recently.
- **mouseLockDistanceWhileRotating**: this is how far away the mouse will be from the center of the selected object while holding the editor_rotate key. higher numbers move the mouse farther away. set to 0 to disable.
- **boxSelectColor**: the color that the box select will be
- **editorBarPosition**: moves the editor bar to either top, bottom, left, or right of the screen
- **editorBarColumns**: the amount of columns in the editor bar. if you want a horizontal layout just make this number large and if using a vertical layout make this number small.
- **cameraRotationOnGravityChangeHappensInstantly**: makes is so that when the gravity changes the camera rotates instantly instead of rotating smoothly.
- **cameraUsesDefaultRotationInEditor**: makes is so that when the editor ui is shown the camera is reset to default rotation instead of keeping the last rotation.
- **dontChangeCameraRotationOnGravityChange**: makes is so that when when the gravity changes the camera will not be rotated.
- **blockGridSnapSize**: the size of the grid that blocks will snap to when being moved or resized.
- **singleAxisAlignByDefault**: if true blocks will only be movable along a single axis at a time by default. if false blocks can be moved freely.
- **newlyCreatedBlocksRotationTakesPlayerRotation**: if true when the player is rotated all new blocks that can be rotated will be rotated to the players current direction instead of the default direction, eg if the player has gravity upside down creating a checkpoint will create it upside down.
- **dontCollapseGroups**: if true the menu groups will not collapse when you click on them.
- **onlyExpandSingleGroup**: if true when expanding a group other expanded groups will be collapsed.
- **saveExpandedGroups**: saves which groups are currently expanded.
- **loadExpandedGroups**: loads which groups were previously saved as expanded.
- **menuOptionNameFormat**: reformats the menu option names in the selected way.

### block settings that apply to many blocks

- **color**: changes the modulate of the block
- **attachesToThings**: if true the block will be able to attach to most blocks that move
  - updown
  - downup
  - leftright
  - falling
  - donup
  - pushable box
  - bomb
  - bouncing buzsaw
  - solar
  - inverse solar
  - invisible
  - button deactivated wall
  - locked box
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

- **10x solar spike**: kills the player on contact if lights are on

  - rotatable
  - **settings**:
    - **color**
    - **attachesToThings**

- **10x inverse solar spike**: kills the player on contact if lights are off

  - rotatable
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

- **solar**: has solid collision when lights are on.

  - scalable
  - **settings**:
    - **color**

- **inverse solar**: has solid collision when lights are off.

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

- **bouncy**: has solid collision but when the player comes in contact with it from the top it will put the player in the bouncing state and bounce back up after a short period of time. the time and bounce height is determined by the blocks y size with bigger time and height from larger y scales. the player bounce direction is away from the top of the block so if the block is rotated, the bounce will be different.

  - scalable
  - rotatable
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

- **Gravity Down Lever**: when the player is inside the lever and presses down the player gravity will be halved or reverted to normal if it was halved before

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

- **light switch**: when the player comes in contact with this it will toggle the lights on/off which will disable/enable all solar blocks.

  - **settings**:
    - **color**
    - **attachesToThings**

- **blue only light switch**: when the player comes in contact with this it will toggle the lights on leaving only the solar blocks on.

  - **settings**:
    - **color**
    - **attachesToThings**

- **red only light switch**: when the player comes in contact with this it will toggle the lights off leaving only the inverse solar blocks on.

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

  -rotatable

  - **settings**:
    - **color**
    - **attachesToThings**

- **Rotating Buzzsaw**: kills the player on contact and will spin clockwise

  -rotatable

  - **settings**:
    - **color**
    - **attachesToThings**

- **Scythe**: kills the player on contact and will spin counterclockwise

  -rotatable

  - **settings**:
    - **color**
    - **attachesToThings**

- **star**: when the player collects this it will stay collected. the star counter in the top left shows the current number of stars collected and total for the current level. the inner levels will have their star counter on the block before entering.

  - **settings**:
    - **color**
    - **attachesToThings**

- **death boundary**: kills the player on contact

  -scalable

  - **settings**:
    - **color**

- **block death boundary**: kills most moving blocks on contact including collected keys and removes effects from the player when the player enters

  - scalable
  - effects removed are
    - speed lever
    - low gravity lever
    - high gravity lever
  - **settings**:
    - **color**

- **nowj**: prevents the player from walljumping, wallsliding, and wall hanging when in contact with the player

  - rotatable
  - scalable
  - **settings**:
    - **color**
    - **attachesToThings**

- **falling spike**: kills the player on contact when in line with the player it will start falling until hitting a solid block

  - rotatable
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

  - rotatable
  - **settings**:
    - **color**
    - **attachesToThings**

- **growing buzsaw**: kills the player on contact grows from 1x to 3x size then back to 1x, briefly pausing at 1x and 3x

  - scalable
  - **settings**:
    - **color**
    - **attachesToThings**

- **spark block/counterClockwise**: has solid collision, kills the player on contact with the spark that moves counterClockwise along the edge of the block when the spark contacts water, the wayer will become eletric and kill the player if the player is inside the water

  - scalable
  - **settings**:
    - **color**

- **spark block/clockwise**: has solid collision, kills the player on contact with the spark that moves clockwise along the edge of the block when the spark contacts water, the wayer will become eletric and kill the player if the player is inside the water

  - scalable
  - **settings**:
    - **color**

- **bomb**: like a pushable box but explodes when hit with a falling spike, falling to fast and colliging with the ground, being squished, or having a box, other bomb fall to fast on it, or being exploded by another bomb. when the player is inside of the explosion, they will be killed, when a block is in the explosion, it will be disabled. microwaves cant be exploded.

  - scalable
  - **settings**:
    - **color**

- **custom block**: loads a list of blocks from a file inside the custom blocks folder for the current level with a name of where. does nothing if the where is not set,

  - **settings**:
    - **where**: the path to the file in the custom blocks folder.

- **sticky floor**: makes the player not be able to jump while in contact with this and also prevents the player from regaining cyote time

  - scalable
  - rotatable
  - **settings**:
    - **attachesToThings**

- **arrow**: points at things; can be rotated

  - rotatable
  - **settings**:
    - **attachesToThings**

- **conveyer**: moves things on top of it in the direction of the arrows and momentum persists for a short time after leaving this block. works on pushable box, bomb and player, works both vertically and horizontally.

  - rotatable
  - scalable
  - **settings**:

- **oneway**: like a block in the direction it is facing and like air in all other directions.

  - rotatable
  - scalable
  - **settings**:

- **gravity rotator**: rotates gravity to face the direction of it points. is triggered by player/bomb/pushable box entering it.

  - rotatable
  - scalable
  - **settings**:

- **floor button**: when pressed by player/bomb/pushable box, toggles off all button deactivated walls that have the same buttonId as this. the button deactivated wall is reenabled when all buttons of the corisponding buttonId are depressed.

  - **settings**:
    - **buttonId**: unique identifier used to identify which things should be affected by this.

- **button deactivated wall**: active only whern no button sharing the same buttonId are pressed, and inactive otherwise.

  - scalable
  - **settings**:
    - **buttonId**: unique identifier for a set of buttons that can be used to deactivate this.

- **targeting laser**: when the player is in range the laser will apply heat, more heat is applied if the player is closer. when the player is in water heat will dissipate faster. if the heat ray hits a bomb the bomb will be exploded.

  - **settings**:

- **laser**: when the player is in range the laser will shoot projectiles in the direction it is facing, these projectiles have a cooldown and are destroyed on contact with solid blocks. if the projectile hits a bomb the bomb will be exploded. the red circle on the laser shows the current cooldown - fully red means ready to fire.

  - **settings**:
    - **maxCooldown**: maximum time between shots in seconds (default = 1.0)

- **Invisible**: gets less visible the closer the player is to it

  - **settings**:

### level flags

- **autoRun**: the player will auto run to the right to start, and will turn around when jumping off a wall slide, but not a wall hang.
- **jumpCount**: the player will have this many jumps. jumps are regained when landing on the ground or on a wall hang. jumps are lost when jumping off a wall hang, jumping from the ground or from in the air, but are not lost or gained when in a wall slide, so settings jump count to 0 will prevent the player from jumping from the ground, but not prevent walljumping or wall hanging.
- **changeSpeedOnSlopes**: if true when moving up a slope the player will be slower and when moving down a slope the player will be faster otherwise the player speed will be the same going up or down slopes.
- **canDoWallHang**: if false the player will not be able to hang on walls.
- **canDoWallSlide**: if false the player will not be able to slide down.
- **canDoWallJump**: if false the player will not be able to jump off walls.
