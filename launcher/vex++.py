# @name a
# @regex (?<=[^\s])  #
# @replace  #
# @endregex
# @regex settings \(launcher\.SettingsData\): _description_
# @replace settings (launcher.SettingsData): The current settings object containing user-defined flags
# @endregex
# @regex selectedOs \(supportedOs\): _description_
# @replace selectedOs (supportedOs): The users currently selected os
# @endregex

import launcher
import os
import subprocess
from PySide6.QtWidgets import QVBoxLayout
from enum import Enum


class supportedOs(Enum):
  windows = 0
  # linux = 1


def getGameLogLocation(
  settings: launcher.SettingsData, selectedOs: supportedOs, gameId: str
):
  """returns the location of the game logs or false if no game logs exist

  Args:
    settings (launcher.SettingsData): The current settings object containing user-defined flags
    selectedOs (supportedOs): The users currently selected os
    gameId (str): _description_

  Returns:
    _type_: _description_
  """
  match selectedOs:
    case supportedOs.windows:
      appdata = os.getenv("APPDATA")
      if appdata is not None:
        return os.path.join(appdata, "godot/app_userdata/vex/logs")
    # case supportedOs.linux
    #   return "~/.local/share/godot/app_userdata/<GAME NAME>/logs"


def linkAll(_from, to, names):
  """updates a set of hardlinks

  Args:
    _from (str): dir
    to (str): dir
    names (list[str]): list of filenames
  """
  for name in names:
    if os.path.exists(os.path.join(to, name)):
      os.remove(os.path.join(to, name))
    os.link(os.path.join(_from, name), os.path.join(to, name))


def gameLaunchRequested(
  path,
  args,
  settings: launcher.SettingsData,
  selectedOs: supportedOs,
  requestedGameDataLocation: str,
) -> None:
  if settings.loadSpecificMapOnStart:
    args += ["--loadMap", settings.nameOfMapToLoad]
  if settings.startInOnlineLevelsScene:
    args += ["--loadOnlineLevels"]
  if settings.downloadMap:
    args += ["--downloadMap", settings.nameOfMapToDownload]

  match selectedOs:
    case supportedOs.windows:
      exe = os.path.join(path, "vex.exe")
      print("requestedGameDataLocation", requestedGameDataLocation)
      if os.path.isfile(exe):
        linkAll(
          path,
          requestedGameDataLocation,
          ["vex.exe", "vex.console.exe", "vex.pck"],
        )
        if settings.closeOnLaunch:
          script_path = os.path.join(
            requestedGameDataLocation,
            "vex.console.exe" if settings.showConsole else "vex.exe",
          )
          os.execl(script_path, f'"{script_path}"', *args)
        else:
          subprocess.Popen(
            [os.path.join(requestedGameDataLocation, "vex.exe")] + args,
            cwd=requestedGameDataLocation,
          )

    # case supportedOs.linux:
    #   exe = os.path.join(path, "vex.sh")
    #   if os.path.isfile(exe):
    #     subprocess.Popen([exe] + args, cwd=path)


def getAssetName(settings: launcher.SettingsData, selectedOs: supportedOs) -> str:
  return "windows.zip"


def gameVersionExists(
  path, settings: launcher.SettingsData, selectedOs: supportedOs
) -> bool:
  def isfile(p):
    return os.path.isfile(os.path.join(path, p))

  match selectedOs:
    case supportedOs.windows:
      return (isfile("vex.exe") and isfile("vex.pck")) or (
        isfile("windows/vex.exe") and isfile("windows/vex.pck")
      )
    # case supportedOs.linux:
    #   return isfile("vex.sh") and isfile("vex.pck")


def addCustomNodes(_self: launcher.Launcher, layout: QVBoxLayout) -> None:
  mapNameInput = _self.newLineEdit('Enter map name or "NEWEST"', "nameOfMapToLoad")
  layout.addWidget(
    _self.newCheckbox(
      "Show Console",
      True,
      "showConsole",
    )
  )
  layout.addWidget(
    _self.newCheckbox(
      "Load Specific Map on Start",
      False,
      "loadSpecificMapOnStart",
      onChange=mapNameInput.setEnabled,
    )
  )
  layout.addWidget(mapNameInput)
  mapNameInput.setEnabled(_self.settings.loadSpecificMapOnStart)

  dlmapNameInput = _self.newLineEdit("Enter map name", "nameOfMapToDownload")
  layout.addWidget(
    _self.newCheckbox(
      "Download Specific Map on Start",
      False,
      "downloadMap",
      onChange=dlmapNameInput.setEnabled,
    )
  )
  layout.addWidget(dlmapNameInput)
  dlmapNameInput.setEnabled(_self.settings.downloadMap)

  layout.addWidget(
    _self.newCheckbox(
      "Start in Online Levels Scene",
      False,
      "startInOnlineLevelsScene",
      onChange=mapNameInput.setEnabled,
    )
  )


from PySide6.QtWidgets import QMenu
from typing import Callable, Dict, List, Any


def addContextMenuOptions(
  _self: launcher.Launcher,
  data: launcher.ItemListData,
  menu: QMenu,
  newAction: Callable,
) -> None:
  pass


def getImage(version: str):
  return os.path.abspath("images/vex++.jpg")


def onGameVersionDownloadComplete(path: str, version: str):
  if os.path.isfile(os.path.join(path, "windows/vex.exe")):
    # if game in wrong folder move it to the correct one
    import shutil

    os.rename(os.path.join(path, "windows/vex.exe"), os.path.join(path, "vex.exe"))
    os.rename(
      os.path.join(path, "windows/vex.console.exe"),
      os.path.join(path, "vex.console.exe"),
    )
    os.rename(os.path.join(path, "windows/vex.pck"), os.path.join(path, "vex.pck"))
    shutil.rmtree(os.path.join(path, "windows"))


launcher.loadConfig(
  launcher.Config(
    getImage=getImage,
    WINDOW_TITLE="Vex++ Launcher",
    SHOULD_USE_HARD_LINKS=True,
    CAN_USE_CENTRAL_GAME_DATA_FOLDER=True,
    GH_USERNAME="rsa17826",
    GH_REPO="vex-plus-plus",
    LAUNCHER_ASSET_NAME="launcher.zip",
    getGameLogLocation=getGameLogLocation,
    gameLaunchRequested=gameLaunchRequested,
    getAssetName=getAssetName,
    gameVersionExists=gameVersionExists,
    addCustomNodes=addCustomNodes,
    addContextMenuOptions=addContextMenuOptions,
    onGameVersionDownloadComplete=onGameVersionDownloadComplete,
    supportedOs=supportedOs,
  )
)
