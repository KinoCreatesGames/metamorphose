import h2d.Flow.FlowAlign;
import hxd.snd.Channel;

class GameOver extends dn.Process {
  var game(get, never):Game;

  inline function get_game() {
    return Game.ME;
  }

  public var complete:Bool;
  public var bgm:Channel;

  public var win:h2d.Flow;
  public var titleText:h2d.Text;

  public function new() {
    super(Game.ME);
    createRootInLayers(Game.ME.scroller, Const.DP_UI);
    complete = false;

    setupGameOver();
    // Play Game Over Music
    bgm = hxd.Res.music.game_over.play(true);
    #if debug
    bgm.stop();
    #end
  }

  public function setupGameOver() {
    createWindow();
  }

  public function createWindow() {
    win = new h2d.Flow(root);
    var width = Std.int(w() / 3);
    win.borderHeight = 6;
    win.borderWidth = 6;
    win.verticalSpacing = 16;
    win.layout = Vertical;
    win.verticalAlign = FlowAlign.Middle;
  }

  public function setupText() {
    var title = new h2d.Text(Assets.fontLarge, root);
    title.text = Lang.t._('Game Over');
    title.center();
    titleText = title;

    // Configure Buttons on the game over scene
    setupOptions();
  }

  inline function setupOptions() {
    var options = [Lang.t._('Continue'), Lang.t._('To Title')];
    for (index in 0...options.length) {
      var text = options[index];
      var optInt = setupOption(text);
      switch (index) {
        case 0:
          //  Continue
          optInt.onClick = (event) -> {
            // Restart from previous Level and destroy this game over scene
            var level = Game.ME.level;
            if (level != null) {
              Game.ME.startLevel(Assets.projData.getLevel(level.data.uid));
              destroy();
            }
          }
        case 1:
          // To title
          optInt.onClick = (event) -> {
            Game.ME.level.destroy();
            destroy();
            new Title();
          }
        case _:
          // Do nothing
      }
    }
  }

  public function setupOption(text:String) {
    var option = new h2d.Text(Assets.fontMedium, win);
    option.text = text;
    option.center();
    var interactive = new h2d.Interactive(win.outerWidth, option.textHeight,
      option);
    interactive.onOut = (event) -> {
      option.alpha = 1;
    }
    interactive.onOver = (event) -> {
      option.alpha = 0.5;
    }
    interactive.x = option.alignCalcX();
    return interactive;
  }

  override function onDispose() {
    super.onDispose();
    bgm.stop();
  }

  override function onResize() {
    super.onResize();
    win.x = (w() / Const.UI_SCALE * 0.5 - win.outerWidth * 2.5);
    titleText.x = (w() / Const.UI_SCALE * 0.5
      - titleText.getSize().width * 2.5);
    win.y = (h() / Const.UI_SCALE * 0.5 - win.outerHeight * 0.5);
  }
}