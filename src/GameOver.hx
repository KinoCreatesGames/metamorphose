import h2d.Flow.FlowAlign;
import hxd.snd.Channel;

class GameOver extends dn.Process {
  var game(get, never):Game;

  inline function get_game() {
    return Game.ME;
  }

  public var complete:Bool;
  public var bgm:Channel;
  public var mask:h2d.Bitmap;

  public var win:h2d.Flow;
  public var titleText:h2d.Text;

  public function new() {
    super(Game.ME);
    createRootInLayers(Game.ME.root, Const.DP_UI);
    complete = false;
    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 0.6), root);
    root.under(mask);
    // Resume Game Over Flag
    Game.ME.resumeGameOver = true;

    setupGameOver();
    // Play Game Over Music
    bgm = hxd.Res.music.game_over.play(true);
    #if debug
    bgm.stop();
    #end
    dn.Process.resizeAll();
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
    setupText();
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
              hxd.Res.sound.confirm.play();
              destroy();
            }
          }
        case 1:
          // To title
          optInt.onClick = (event) -> {
            Game.ME.level.destroy();
            hxd.Res.sound.confirm.play();
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
      hxd.Res.sound.select.play();
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
    if (mask != null) {
      var w = M.ceil(w());
      var h = M.ceil(h());
      mask.scaleX = w;
      mask.scaleY = h;
    }
    win.x = (w() * 0.5 - (win.outerWidth * 0.5));
    titleText.x = (w() * 0.5 - (titleText.getSize().width * 0.0));
    win.y = (h() * 0.5 - (win.outerHeight * 0.5));
  }
}