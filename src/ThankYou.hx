import hxd.res.DynamicText.Key;
import h2d.Flow.FlowAlign;

class ThankYou extends dn.Process {
	var game(get, never):Game;

	inline function get_game() {
		return Game.ME;
	}

	public var ca:dn.heaps.Controller.ControllerAccess;

	public var complete:Bool;
	public var win:h2d.Flow;

	public function new() {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_UI);
		complete = false;
		ca = Main.ME.controller.createAccess("ThankYou");

		setupThankYou();
		dn.Process.resizeAll();
	}

	public function setupThankYou() {
		win = new h2d.Flow(root);
		var width = Std.int(w() / 3);
		win.backgroundTile = h2d.Tile.fromColor(0xff0000, width, 100, 0);
		win.borderHeight = 6;
		win.borderWidth = 6;
		win.verticalSpacing = 16;

		win.layout = Vertical;
		win.verticalAlign = FlowAlign.Middle;
		win.alpha = 0;
		setupText();
	}

	public function setupText() {
		var thanks = new h2d.Text(Assets.fontLarge, win);
		thanks.text = Lang.t._('Thank You For Playing!');
		thanks.center();
		var kino = new h2d.Text(Assets.fontMedium, win);
		kino.text = Lang.t._('KinoCreatesGames - Kino');
		kino.center();
	}

	override public function onResize() {
		super.onResize();
		win.x = (w() / Const.UI_SCALE * 0.5 - win.outerWidth * 1.1);
		win.y = (h() / Const.UI_SCALE * 0.5 - win.outerHeight * 0.5);
	}

	override public function update() {
		super.update();
		// Hit Escape to exit the credits screen
		if (win.alpha < 1) {
			win.alpha = M.lerp(win.alpha, 1.2, 0.05);
		}
		var exitCredits = ca.isKeyboardPressed(K.ESCAPE);
		if (exitCredits) {
			new Title();
			destroy();
		}
	}
}
