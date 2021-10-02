import hxd.snd.Channel;
import dn.heaps.Controller.ControllerAccess;

class Pause extends dn.Process {
  public var ca:ControllerAccess;
  public var complete:Bool;
  public var win:h2d.Flow;
  public var titleText:h2d.Text;
  public var elapsed:Float = 0.;
  public var se:Channel;
  public var mask:h2d.Bitmap;

  public function new() {
    super(Game.ME);
    ca = Main.ME.controller.createAccess('pause');
    createRootInLayers(Game.ME.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix();
    complete = false;
    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 1), root);
    trace(mask);
    trace(mask.alpha);
    root.under(mask);
    win = new h2d.Flow(root);
    #if debug
    trace('Enter pause menu');
    #end
    setupPause();
    dn.Process.resizeAll();
  }

  public function setupPause() {
    win.layout = Vertical;
    setupTitleText();
    setupOptions();
  }

  inline function setupTitleText() {
    titleText = new h2d.Text(Assets.fontLarge, win);
    titleText.text = Lang.t._('Pause');
    titleText.center();
  }

  inline function setupOptions() {
    var options = [Lang.t._('Resume'), Lang.t._('Settings'), Lang.t._('To Title')];
    for (index in 0...options.length) {
      var text = options[index];
      var optInt = setupOption(text);
      switch (index) {
        case 0:
          // To Options
          optInt.onClick = (event) -> {
            Game.ME.resume();
            hxd.Res.sound.confirm.play();
            destroy();
          }
        case 1:
          // Settings
          optInt.onClick = (event) -> {
            Game.ME.resume();
            hxd.Res.sound.confirm.play();
            destroy();
            new Settings();
          }
        case 2:
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

  override public function update() {
    super.update();
    // Update alpha of Pause
    elapsed = (uftime % 180) * (Math.PI / 180);
    titleText.alpha = M.fclamp(Math.sin(elapsed) + 0.3, 0.3, 1);
    if (complete) {
      if (ca.isKeyboardPressed(K.ESCAPE)) {
        // Return to the previous scene without creating any
        // new instances
        // Play Leave
        se = hxd.Res.sound.pause_out.play();
        this.destroy();
      }
    }
  }

  override function onResize() {
    super.onResize();
    // Resize all elements to be centered on screen

    if (mask != null) {
      var w = M.ceil(w());
      var h = M.ceil(h());
      mask.scaleX = w;
      mask.scaleY = h;
    }
    win.x = (w() * 0.5 - (win.outerWidth * 0.5));
    win.y = (h() * 0.5 - (win.outerHeight * 0.5));
  }

  override function onDispose() {
    super.onDispose();
    se = null;
  }
}