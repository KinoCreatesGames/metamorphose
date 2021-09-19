import dn.heaps.Controller.ControllerAccess;

class Pause extends dn.Process {
	public var ca:ControllerAccess;
	public var complete:Bool;
	public var win:h2d.Flow;
	public var titleText:h2d.Text;
	public var elapsed:Float = 0.;

	public function new() {
		super(Game.ME);
		ca = Main.ME.controller.createAccess('pause');
		createRootInLayers(Game.ME.scroller, Const.DP_UI);
		complete = false;
		win = new h2d.Flow(root);

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
						destroy();
					}
				case 1:
				// Settings
				case 2:
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
		var interactive = new h2d.Interactive(win.outerWidth, option.textHeight, option);
		interactive.onOut = (event) -> {
			option.alpha = 1;
		}
		interactive.onOver = (event) -> {
			option.alpha = 0.5;
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
				this.destroy();
			}
		}
	}

	override function onResize() {
		super.onResize();
		// Resize all elements to be centered on screen
		win.x = (w() / Const.UI_SCALE * 0.5 - win.outerWidth * 4.5);
		win.y = (h() / Const.UI_SCALE * 0.5 - win.outerHeight * 1.25);
	}
}
