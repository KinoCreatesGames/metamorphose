class IntroScene extends dn.Process {
  public var win:h2d.Flow;
  public var text:h2d.Text;
  public var padding:Int;
  public var textBuffer:String;
  public var allText:Array<String>;
  public var textIndex:Int;
  public var mask:h2d.Bitmap;
  public var isTyping:Bool;
  public var frameCount:Int;
  public var complete:Bool;
  public var completeScene:Bool;
  public var callBack:Void -> Void;

  public static inline var FRAME_DELAY:Int = 3;

  public function new(callBack:Void -> Void, ?text:Array<String>) {
    super(Game.ME);

    createRootInLayers(Game.ME.root, Const.DP_UI);
    this.callBack = callBack;
    allText = text != null ? text : [];
    complete = false;
    frameCount = FRAME_DELAY;
    textBuffer = '';

    root.filter = new h2d.filter.ColorMatrix();
    mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 0.6), root);

    root.under(mask);
    setupWindow();
    dn.Process.resizeAll();
  }

  public function setupWindow() {
    padding = 24;
    win = new h2d.Flow(root);
    win.borderHeight = 7;
    win.borderWidth = 7;
    win.enableInteractive = true;
    win.layout = Vertical;
    win.verticalSpacing = 2;
    win.minWidth = Std.int(w() / 2);
    win.minHeight = Std.int((h() / 3));
    textIndex = -1;
    isTyping = false;
    completeScene = false;

    // Setup Text Element
    text = new h2d.Text(Assets.fontMedium, win);
    text.x = padding;
    text.text = '';
    text.maxWidth = win.minWidth - (padding * 2);
    text.textColor = 0xffffff;
    text.textAlign = Center;

    win.interactive.onClick = (event) -> {
      if (!isTyping && !complete) {
        advanceText();
      } else {
        // Show all current text
        if (!complete) {
          showAllText();
        }
      }
      if (complete) {
        completeScene = true;
      }
    };
    // Initial Text Advance
    advanceText();
  }

  public function advanceText() {
    textIndex = M.iclamp(textIndex + 1, 0, allText.length - 1);
    // Start new set of text to type
    isTyping = true;
    textBuffer = '';
  }

  override function update() {
    super.update();
    if (complete && completeScene) {
      callBack();
      this.destroy();
    }
  }

  override function fixedUpdate() {
    super.fixedUpdate();
    if (isTyping) {
      frameCount--;
      if (frameCount == 0) {
        frameCount = FRAME_DELAY;
        updateText();
        isTyping = !(textBuffer == allText[textIndex]);

        if (!isTyping && textIndex == (allText.length - 1)) {
          complete = true;
        }
      }
    }
  }

  public function updateText() {
    var currentText = allText[textIndex];
    textBuffer = currentText.substring(0, textBuffer.length + 1);
    text.text = textBuffer;
  }

  public function showAllText() {
    var currentText = allText[textIndex];
    textBuffer = currentText;
    text.text = textBuffer;
    isTyping = !(textBuffer == allText[textIndex]);
    frameCount = FRAME_DELAY;
    if (!isTyping && textIndex == (allText.length - 1)) {
      complete = true;
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
}