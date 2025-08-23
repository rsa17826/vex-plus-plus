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

- **randomizeLevelModifiersOnLevelCreation**: 

- **minDistBeforeBlockDraggingStarts**: 

- **autoPanWhenClickingEmptySpace**: when dragging on an empty space, with no blocks on it, it will treat it as if editor_pan was pressed.

- **movingPathNodeMovesEntirePath**: 

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

- **allowCustomColors**: disabling this prevents levels from using custom colors.
### camera

- **cameraUsesDefaultRotationInEditor**: makes is so that when the editor ui is shown the camera is reset to default rotation instead of keeping the last rotation.

- **dontChangeCameraRotationOnGravityChange**: makes is so that when when the gravity changes the camera will not be rotated.

- **cameraRotationOnGravityChangeHappensInstantly**: makes is so that when the gravity changes the camera rotates instantly instead of rotating smoothly.
### theme

- **selectedBlockOutlineColor**: 

- **hoveredBlockOutlineColor**: 

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

- **showTotalActiveSignalCounts**: 

- **showWhatBlocksAreSendingSignals**: 

- **onlyShowActiveSignals**: only shows signals if the signal is active and being sent
### player

- **playerRespawnTime**: the time that the player takes to respawn after dying
### online level list

- **onlyShowLevelsForCurrentVersion**: the load online levels button only shows levels for the current version instead of for all versions.

- **loadOnlineLevelListOnSceneLoad**: when the online level list is loaded the level data will immediately be downloaded

- **autoExpandAllGroups**: the menu groups will all be open?
### debug

- **showHitboxes**: sets the default hitbox state for whenever entering a level

- **slowTime**: 
### misc

- **openExportsDirectoryOnExport**: if true, after exporting a level, it will open the exports directory.