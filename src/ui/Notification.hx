package ui;

class Notification extends dn.Process {
  public var win:h2d.Flow;
  public var text:h2d.Text;
  public var padding:Int;

  var ct:dn.heaps.Controller.ControllerAccess;
  var mask:h2d.Bitmap;

  public function new() {
    super(Game.ME);
    createRootInLayers(Game.ME.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // Pixel Perfect Rendering

    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 0.5), root);
    root.under(mask);

    padding = 16;
    win = new h2d.Flow(root);
    win.backgroundTile = h2d.Tile.fromColor(0xffffff, 32, 32);
    win.borderWidth = 8;
    win.borderHeight = 8;
    win.layout = Vertical;
    win.verticalSpacing = 2;
    win.padding = padding;
    setupText();

    dn.Process.resizeAll();
  }

  public function setupText() {
    text = new h2d.Text(Assets.fontMedium, win);
    text.text = '';
    text.maxWidth = win.minWidth - (padding * 2);
    text.textColor = 0xffffff;
  }

  public function clearContents() {
    win.removeChildren();
  }

  public function hide() {
    win.visible = false;
  }

  public function show() {
    win.visible = true;
  }

  /**
   * Sends a notification message to the screen and temporarily
   * pauses the gameplay.
   * @param msg 
   */
  public function notify(msg:String) {
    if (!win.visible) {
      Game.ME.pause();
      show();
    }
    // Send a message to the screen and show the window
    text.text = msg;
  }

  override function onResize() {
    super.onResize();
    if (mask != null) {
      mask.scaleX = w();
      mask.scaleY = h();
    }
    win.x = (w() * 0.5 - (win.outerWidth * 0.5));
    win.y = (h() - win.minHeight);
    win.reflow();
  }
}