import hxd.snd.Channel;

class Intro extends dn.Process {
  var ct:dn.heaps.Controller.ControllerAccess;
  var mask:h2d.Bitmap;
  var text:h2d.Text;
  var win:h2d.Flow;
  var padding:Int;
  var allMsgs:Array<String>;
  var msgIdx:Int;

  public var game(get, never):Game;

  public var bgm:Channel;

  public inline function get_game() {
    return Game.ME;
  }

  public function new(?msgText:Array<String>) {
    super(Game.ME);
    createRootInLayers(Game.ME.scroller, Const.DP_UI);
    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 0.6), root);
    root.filter = new h2d.filter.ColorMatrix(); // Pixel Perfect render
    root.under(mask);
    allMsgs = msgText == null ? [] : msgText;
    msgIdx = 0;
    // Add in intro music
    bgm = hxd.Res.music.intro_song.play(true);
    // Intro text show
    createMsgWindow();
    dn.Process.resizeAll();
  }

  public function createMsgWindow() {
    padding = 24;
    win = new h2d.Flow(root);
    win.enableInteractive = true;
    win.borderWidth = 7;
    win.borderHeight = 7;

    win.minHeight = Std.int(h() / 3);
    win.minWidth = Std.int(w());

    win.layout = Vertical;
    win.verticalSpacing = 2;

    // Setup Text
    text = new h2d.Text(Assets.fontMedium, win);
    text.x = padding;
    text.text = Lang.t._('Intro');
    text.maxWidth = win.minWidth - (padding * 2);
    text.textColor = 0xffffff;

    // Interactions
    win.interactive.onOver = (event) -> {
      // Do nothing for now
    };

    win.interactive.onClick = (event) -> {
      advanceText();
    };
  }

  public function sendMsg(text:String) {
    this.text.text = text;
  }

  /**
   * Advances the text within the game for the intro cutscene.
   */
  public function advanceText() {
    msgIdx++;
    if (msgIdx < allMsgs.length) {
      sendMsg(allMsgs[msgIdx]);
    }
  }

  override function onResize() {
    super.onResize();
    root.setScale(Const.UI_SCALE);
  }
}