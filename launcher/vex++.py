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

from typing import cast
import launcher as launcher
import os
import subprocess
from PySide6.QtWidgets import QVBoxLayout
from enum import Enum


class supportedOs(Enum):
  windows = 0
  linux = 1


def getGameLogLocation(
  settings: launcher.SettingsData, selectedOs: supportedOs, gameId: str # pyright: ignore[reportUnusedParameter]
) -> str:
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
      return ""
    case supportedOs.linux:
      return os.path.expanduser(
        "~/.local/share/godot/app_userdata/vex/logs"
      )


def linkAll(_from:str, to:str, names:list[str]):
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
  path:str,
  args:list[str],
  settings: launcher.SettingsData,
  selectedOs: supportedOs,
  requestedGameDataLocation: str,
) -> None:
  if len(args)==0:
    if settings.loadSpecificMapOnStart:
      args += ["--loadMap", cast(str, settings.nameOfMapToLoad)]
    if settings.startInOnlineLevelsScene:
      args += ["--loadOnlineLevels"]
    if settings.downloadMap:
      args += ["--downloadMap", cast(str,settings.nameOfMapToDownload)]

  match selectedOs:
    case supportedOs.windows:
      binary_name = "vex.console.exe" if settings.showConsole else "vex.exe"
      exe_path = os.path.join(path, "vex.exe")
      if os.path.isfile(exe_path):
        linkAll(
          path,
          requestedGameDataLocation,
          ["vex.exe", "vex.console.exe", "vex.pck"],
        )
        script_path = os.path.join(requestedGameDataLocation, binary_name)

        if settings.closeOnLaunch:
          os.execl(script_path, f'"{script_path}"', *args)
        else:
          _ = subprocess.Popen(
            [script_path] + args, cwd=requestedGameDataLocation
          )

    case supportedOs.linux:
      exe_path = os.path.join(path, "vex")
      if os.path.isfile(exe_path):
        os.chmod(exe_path, 0o755)
        linkAll(
          path,
          requestedGameDataLocation,
          ["vex", "vex.pck"],
        )
        script_path = os.path.join(requestedGameDataLocation, "vex")
        os.chmod(script_path, 0o755)

        if settings.closeOnLaunch:
          os.execl(script_path, script_path, *args)
        else:
          _ = subprocess.Popen(
            [script_path] + args, cwd=requestedGameDataLocation
          )


def getAssetName(_settings: launcher.SettingsData, selectedOs: supportedOs) -> str:
  match selectedOs:
    case supportedOs.windows:
      return "windows.zip"
    case supportedOs.linux:
      return "linux.zip"


def gameVersionExists(
  path:str, _settings: launcher.SettingsData, selectedOs: supportedOs
) -> bool:
  def isfile(p:str):
    return os.path.isfile(os.path.join(path, p))

  match selectedOs:
    case supportedOs.windows:
      return (isfile("vex.exe") and isfile("vex.pck")) or (
        isfile("windows/vex.exe") and isfile("windows/vex.pck")
      )
    case supportedOs.linux:
      return (isfile("vex") and isfile("vex.pck")) or (
        isfile("linux/vex") and isfile("linux/vex.pck")
      )


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
  mapNameInput.setEnabled(cast(bool,_self.settings.loadSpecificMapOnStart))

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
  dlmapNameInput.setEnabled(cast(bool,_self.settings.downloadMap))

  layout.addWidget(
    _self.newCheckbox(
      "Start in Online Levels Scene",
      False,
      "startInOnlineLevelsScene",
      onChange=mapNameInput.setEnabled,
    )
  )


from PySide6.QtWidgets import QMenu
from typing import Callable


def addContextMenuOptions(
  _self: launcher.Launcher,
  _data: launcher.listData,
  _menu: QMenu,
  _newAction: Callable[[], object],
) -> None:
  pass


def getImage(_version: str):
  return os.path.abspath("images/vex++.jpg")


def onGameVersionDownloadComplete(path: str, _version: str, selectedOs: supportedOs) -> None:
  match selectedOs:
    case supportedOs.windows:
      if os.path.isfile(os.path.join(path, "windows/vex.exe")):
        import shutil
        os.rename(os.path.join(path, "windows/vex.exe"), os.path.join(path, "vex.exe"))
        os.rename(
          os.path.join(path, "windows/vex.console.exe"),
          os.path.join(path, "vex.console.exe"),
        )
        os.rename(os.path.join(path, "windows/vex.pck"), os.path.join(path, "vex.pck"))
        shutil.rmtree(os.path.join(path, "windows"))
    case supportedOs.linux:
      if os.path.isfile(os.path.join(path, "linux/vex")):
        import shutil
        os.rename(os.path.join(path, "linux/vex"), os.path.join(path, "vex"))
        os.rename(os.path.join(path, "linux/vex.pck"), os.path.join(path, "vex.pck"))
        shutil.rmtree(os.path.join(path, "linux"))
        os.chmod(os.path.join(path, "vex"), 0o755)
    case _:
      pass

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
