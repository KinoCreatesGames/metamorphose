import dn.data.SavedData;
import hxd.snd.Manager;
import h2d.Flow;

class Settings extends dn.Process {
  var ct:dn.heaps.Controller.ControllerAccess;
  var mask:h2d.Bitmap;
  var padding:Int;
  var win:h2d.Flow;
  var volumeDisplay:h2d.Text;

  public var manager(get, never):Manager;

  public inline function get_manager() {
    return Manager.get();
  }

  public var game(get, never):Game;

  public inline function get_game() {
    return Game.ME;
  }

  public function new() {
    super(Game.ME);
    createRootInLayers(game.scroller, Const.DP_UI);
    loadSettings();
    setupSettingsWindow();
    dn.Process.resizeAll();
  }

  public function setupSettingsWindow() {
    win = new h2d.Flow(root);
    win.borderHeight = 7;
    win.borderWidth = 7;
    win.minWidth = Std.int(w() / 2);

    win.verticalSpacing = 16;
    win.layout = Horizontal;
  }

  public function addOptions() {
    // Add Volume Setting

    var volText = new h2d.Text(Assets.fontMedium, win);
    volText.text = Lang.t._('Volume');
    // Add buttons
    var volDown = new h2d.Text(Assets.fontMedium, win);
    volDown.text = Lang.t._('Down');
    var downInt = setupOption(volDown);
    volumeDisplay = new h2d.Text(Assets.fontMedium, win);

    volumeDisplay.text = Lang.t._('${manager.masterVolume * 100}');
    var volUp = new h2d.Text(Assets.fontMedium, win);
    volUp.text = Lang.t._('Up');
    var upInt = setupOption(volUp);
    upInt.onClick = (event) -> {
      manager.masterVolume = M.fclamp(manager.masterVolume + .1, 0, 1);
      volumeDisplay.text = Lang.t._('${manager.masterVolume * 100}');
      // Save Settings
      saveSettings();
    }
    downInt.onClick = (event) -> {
      manager.masterVolume = M.fclamp(manager.masterVolume - .1, 0, 1);
      volumeDisplay.text = Lang.t._('${manager.masterVolume * 100}');
      saveSettings();
    }
  }

  public function setupOption(text:h2d.Text) {
    text.center();
    var interactive = new h2d.Interactive(win.outerWidth, text.textHeight,
      text);
    interactive.onOut = (event) -> {
      text.alpha = 1;
    }
    interactive.onOver = (event) -> {
      text.alpha = 0.5;
    }
    interactive.x = text.alignCalcX();
    return interactive;
  }

  /**
   * Saves the Settings for the game which will be adjusted on game load
   * on the title screen if available.
   */
  public function saveSettings() {
    SavedData.save(SETTINGS, {
      volume: manager.masterVolume
    });
  }

  public function loadSettings() {
    if (SavedData.exists(SETTINGS)) {
      var data = SavedData.load(SETTINGS, {volume: Float});
      manager.masterVolume = cast data.volume;
    }
  }

  override function onResize() {
    super.onResize();
  }

  override function onDispose() {
    super.onDispose();
  }
}