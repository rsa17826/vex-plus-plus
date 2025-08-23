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

- **randomizeLevelModifiersOnLevelCreation**: asdkasdkjllkjdas

- **minDistBeforeBlockDraggingStarts**: asdkasdkjllkjdas

- **autoPanWhenClickingEmptySpace**: when dragging on an empty space, with no blocks on it, it will treat it as if editor_pan was pressed.

- **movingPathNodeMovesEntirePath**: asdkasdkjllkjdas

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

- **selectedBlockOutlineColor**: asdkasdkjllkjdas

- **hoveredBlockOutlineColor**: asdkasdkjllkjdas

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

- **showTotalActiveSignalCounts**: asdkasdkjllkjdas

- **showWhatBlocksAreSendingSignals**: asdkasdkjllkjdas

- **onlyShowActiveSignals**: only shows signals if the signal is active and being sent
### player

- **playerRespawnTime**: the time that the player takes to respawn after dying
### online level list

- **onlyShowLevelsForCurrentVersion**: the load online levels button only shows levels for the current version instead of for all versions.

- **loadOnlineLevelListOnSceneLoad**: when the online level list is loaded the level data will immediately be downloaded

- **autoExpandAllGroups**: the menu groups will all be open?
### debug

- **showHitboxes**: sets the default hitbox state for whenever entering a level
### misc

- **openExportsDirectoryOnExport**: if true, after exporting a level, it will open the exports directory.


## Blocks


- **basic**: has solid collision

  - scale
  - canAttachToPaths

- **slope**: has solid collision on the borders but not in the middle.

  - scale
  - rotate
  - canAttachToPaths

- **path**: blocks that attach to this will be moved along the path

  - scale
  - rotate

  - **settings**:
    - **path**: a string of points separated by commas each being an x, then y, that are used to make the path. the points are relative to the path node, not global positions.
    - **endReachedAction**: what will happen when the block reaches the end of the path.
    - **startOnLoad**: when the level is loaded or the player dies the track will start immediately.
    - **startOnPress**: starts to move when a button with the same signalId is pressed.
    - **startWhilePressed**: starts to move when a button with the same signalId is pressed and pauses when the button is released.
    - **signalInputId**: asdkasdkjllkjdas
    - **restart**: onay available when using a button start mode.
    - **forwardSpeed**: the speed that blocks are moved at while going forward along the path.
    - **backwardSpeed**: the speed that blocks are moved at while going backwards along the path.
    - **addNewPoint**: asdkasdkjllkjdas

- **10x spike**: kills the player on contact

  - scale
  - rotate
  - canAttachToThings
  - canAttachToPaths

- **10x solar spike**: kills the player on contact if lights are on

  - scale
  - rotate
  - canAttachToThings
  - canAttachToPaths

- **10x inverse solar spike**: kills the player on contact if lights are off

  - scale
  - rotate
  - canAttachToThings
  - canAttachToPaths

- **invisible**: gets less visible the closer the player is to it

  - scale
  - canAttachToPaths

- **updown**: has solid collision and moves up than down

  - scale
  - canAttachToPaths

- **downup**: has solid collision and moves down than up

  - scale
  - canAttachToPaths

- **leftRight**: has solid collision and moves right than left

  - scale
  - canAttachToPaths

- **rightLeft**: has solid collision and moves than left right

  - scale
  - canAttachToPaths

- **growing block**: asdkasdkjllkjdas

  - scale
  - canAttachToPaths

- **gravity rotator**: rotates gravity to face the direction of it points. is triggered by player/bomb/pushable box entering it.

  - scale
  - rotate
  - canAttachToPaths

- **water**: when the player enters they are changed to swim mode and reverted to platformer mode on exit.

  - scale
  - canAttachToThings
  - canAttachToPaths

- **solar**: has solid collision when lights are on.

  - scale
  - canAttachToPaths

- **inverse solar**: has solid collision when lights are off.

  - scale
  - canAttachToPaths

- **pushable box**: has solid collision and can be pushed by the player while the player is on ground and in platformer mode.

  - scale
  - canAttachToPaths

- **microwave**: has solid collision

  - scale
  - canAttachToThings
  - canAttachToPaths

- **locked box**: has solid collision but when the player comes in contact with it and has a key, the key and block are disabled.

  - scale
  - canAttachToPaths

- **floor button**: when pressed by player/bomb/pushable box it will send a signal

  - canAttachToThings
  - canAttachToPaths

  - **settings**:
    - **signalOutputId**: asdkasdkjllkjdas

- **button deactivated wall**: active only whern its signal is off.

  - scale
  - canAttachToPaths

  - **settings**:
    - **signalInputId**: asdkasdkjllkjdas

- **glass**: has solid collision but when the player comes in contact with it from the top and is holding down and has downwards velocity, the glass breaks and is disabled.

  - scale
  - canAttachToPaths

- **falling**: has solid collision but when the player comes in contact with it from the top it will start to fall for ~2s before respawning.

  - scale
  - canAttachToPaths

- **donup**: asdkasdkjllkjdas

  - scale
  - canAttachToPaths

- **bouncy**: has solid collision but when the player comes in contact with it from the top it will put the player in the bouncing state and bounce back up after a short period of time. the time and bounce height is determined by the blocks y size with bigger time and height from larger y scales. the player bounce direction is away from the top of the block so if the block is rotated, the bounce will be different.

  - scale
  - rotate
  - canAttachToPaths

- **spark block/counterClockwise**: has solid collision, kills the player on contact with the spark that moves counterClockwise along the edge of the block when the spark contacts water, the wayer will become eletric and kill the player if the player is inside the water

  - scale
  - canAttachToPaths

- **spark block/clockwise**: has solid collision, kills the player on contact with the spark that moves clockwise along the edge of the block when the spark contacts water, the wayer will become eletric and kill the player if the player is inside the water

  - scale
  - canAttachToPaths

- **inner level**: has solid collision but when the player crouches on top of it the player will be transported to a new level, which upon being beat will send the player back to the previous level on top of it.

  - scale
  - canAttachToPaths

  - **settings**:
    - **level**: the level that you will be sent to
    - **requiredLevelCount**: the amount of levels that you must beat before being able to enter this level

- **goal**: when the player reaches this block they win and if inside an inner level they will go back to the previous level else they will just be reset to the last saved checkpoint.

  - scale
  - canAttachToThings
  - canAttachToPaths

  - **settings**:
    - **requiredLevelCount**: the amount of levels that you must beat before being able to enter this level

- **buzsaw**: kills the player on contact

  - scale
  - canAttachToThings
  - canAttachToPaths

- **bouncing buzsaw**: kills the player on contact and falls until hitting a solid block where it will start bouncing up until reaching the start height where it will start falling back down again

  - scale
  - canAttachToPaths

- **cannon**: NOT WORKING YET

  - canAttachToThings
  - canAttachToPaths

- **checkpoint**: sets the player respawn location to this location

  - rotate
  - canAttachToThings
  - canAttachToPaths

  - **settings**:
    - **multiUse**: if true you can recollect this checkpoint else this checkpoint will only be collectable once

- **closing spikes**: kills the player on contact will open slowly then close quickly

  - rotate
  - canAttachToThings
  - canAttachToPaths

- **gravity down lever**: when the player is inside the lever and presses down the player gravity will be halved or reverted to normal if it was halved before

  - canAttachToThings
  - canAttachToPaths

- **gravity up lever**: when the player is inside the lever and presses down the player gravity will be doubled or reverted to normal if it was doubled before

  - canAttachToThings
  - canAttachToPaths

- **speed up lever**: when the player is inside the lever and presses down the player speed will be doubled or reverted to normal if it was doubled before

  - canAttachToThings
  - canAttachToPaths

- **growing buzsaw**: kills the player on contact grows from 1x to 3x size then back to 1x, briefly pausing at 1x and 3x

  - scale
  - canAttachToThings
  - canAttachToPaths

- **key**: when the player comes in contact with this it will start following the player until ised to unlock a locked box

  - canAttachToThings
  - canAttachToPaths

- **light switch**: when the player comes in contact with this it will toggle the lights on/off which will disable/enable all solar blocks.

  - canAttachToThings
  - canAttachToPaths

- **red only light switch**: when the player comes in contact with this it will toggle the lights off leaving only the inverse solar blocks on.

  - canAttachToThings
  - canAttachToPaths

- **blue only light switch**: when the player comes in contact with this it will toggle the lights on leaving only the solar blocks on.

  - canAttachToThings
  - canAttachToPaths

- **pole**: when the player contacts this the player will be able to swing on it and jump off with jump or drop off with down. when jumping off if in the blue part of the indicator then the jump will gain height else it will be like a drop

  - canAttachToThings
  - canAttachToPaths

- **pole quadrant**: spins 4 poles

  - canAttachToThings
  - canAttachToPaths

- **pulley**: when the player comes in contact with this it will move bring the player with it until there is no ceiling or wall in front of it where it will drop the player and return to the start location

  - canAttachToThings

  - **settings**:
    - **direction**: asdkasdkjllkjdas

- **quadrant**: kills the player on contact and will spin clockwise

  - scale
  - rotate
  - canAttachToThings
  - canAttachToPaths

- **rotating buzzsaw**: kills the player on contact and will spin clockwise

  - scale
  - rotate
  - canAttachToThings
  - canAttachToPaths

- **scythe**: kills the player on contact and will spin counterclockwise

  - scale
  - rotate
  - canAttachToThings
  - canAttachToPaths

- **shurikan spawner**: asdkasdkjllkjdas

  - rotate
  - canAttachToThings
  - canAttachToPaths

- **star**: when the player collects this it will stay collected. the star counter in the top left shows the current number of stars collected and total for the current level. the inner levels will have their star counter on the block before entering.

  - canAttachToThings
  - canAttachToPaths

  - **settings**:
    - **unCollect**: asdkasdkjllkjdas

- **laser**: when the player is in range the laser will shoot projectiles in the direction it is facing, these projectiles have a cooldown and are destroyed on contact with solid blocks. if the projectile hits a bomb the bomb will be exploded. the red circle on the laser shows the current cooldown - fully red means ready to fire.

  - scale
  - canAttachToThings
  - canAttachToPaths

  - **settings**:
    - **maxCooldown**: maximum time between shots in seconds (default = 1.0)

- **targeting laser**: when the player is in range the laser will apply heat, more heat is applied if the player is closer. when the player is in water heat will dissipate faster. if the heat ray hits a bomb the bomb will be exploded.

  - canAttachToThings
  - canAttachToPaths

- **death boundary**: kills the player on contact

  - scale

- **block death boundary**: kills most moving blocks on contact including collected keys and removes effects from the player when the player enters

  - scale

- **noWJ**: prevents the player from walljumping, wallsliding, and wall hanging when in contact with the player

  - scale
  - rotate
  - canAttachToThings
  - canAttachToPaths

- **falling spike**: kills the player on contact when in line with the player it will start falling until hitting a solid block

  - rotate
  - canAttachToThings
  - canAttachToPaths

- **portal**: when the player contacts this it will take the player to the first portal in the level with a portalId matching the portals targetId

  - scale
  - canAttachToThings
  - canAttachToPaths

  - **settings**:
    - **portalId**: the id of this portal as used for finding an exit portal
    - **exitId**: the id this portal uses to find its exit portal

- **bomb**: like a pushable box but explodes when hit with a falling spike, falling to fast and colliging with the ground, being squished, or having a box, other bomb fall to fast on it, or being exploded by another bomb. when the player is inside of the explosion, they will be killed, when a block is in the explosion, it will be disabled. microwaves cant be exploded.

  - scale
  - canAttachToPaths

- **sticky floor**: makes the player not be able to jump while in contact with this and also prevents the player from regaining cyote time

  - scale
  - rotate
  - canAttachToThings
  - canAttachToPaths

- **arrow**: points at things; can be rotated

  - rotate
  - canAttachToThings
  - canAttachToPaths

- **conveyer**: moves things on top of it in the direction of the arrows and momentum persists for a short time after leaving this block. works on pushable box, bomb and player, works both vertically and horizontally.

  - scale
  - rotate
  - canAttachToPaths

- **oneway**: like a block in the direction it is facing and like air in all other directions.

  - scale
  - rotate
  - canAttachToPaths

- **undeath**: if the player collides with this block while flying bact to the spawnpoint the player will instead be revived right where the player collided with the block at. user restarts will bypass this block.

  - scale
  - canAttachToPaths

- **input detector**: when the player is pressing the set direction a signal will be emitted.

  - rotate

  - **settings**:
    - **action**: asdkasdkjllkjdas
    - **signalOutputId**: asdkasdkjllkjdas

- **player state detector**: asdkasdkjllkjdas

  - rotate

  - **settings**:
    - **state**: asdkasdkjllkjdas
    - **signalOutputId**: asdkasdkjllkjdas

- **not gate**: will invert a signal.


  - **settings**:
    - **signalInputId**: asdkasdkjllkjdas
    - **signalOutputId**: asdkasdkjllkjdas

- **and gate**: will send a signal only if both signals are on.


  - **settings**:
    - **signalAInputId**: asdkasdkjllkjdas
    - **signalBInputId**: asdkasdkjllkjdas
    - **signalOutputId**: asdkasdkjllkjdas

- **crumbling**: if the player collides with this block the block will start to crumble and be destroyed after a certain amount of time. only respawns on death.

  - scale
  - canAttachToPaths