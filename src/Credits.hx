import hxd.res.DynamicText.Key;
import h2d.Flow.FlowAlign;

class Credits extends dn.Process {
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
		ca = Main.ME.controller.createAccess("title");

		setupCredits();
		dn.Process.resizeAll();
	}

	public function setupCredits() {
		win = new h2d.Flow(root);
		var width = Std.int(w() / 3);
		win.backgroundTile = h2d.Tile.fromColor(0xff0000, width, 100, 0);
		win.borderHeight = 6;
		win.borderWidth = 6;
		win.verticalSpacing = 16;

		win.layout = Vertical;
		win.verticalAlign = FlowAlign.Middle;
		setupText();
	}

	public function setupText() {
		var credits = new h2d.Text(Assets.fontLarge, win);
		credits.text = Lang.t._('Credits');
		credits.center();
		var kino = new h2d.Text(Assets.fontMedium, win);
		kino.text = Lang.t._('Kino - Game Design');
		kino.center();
		var jd = new h2d.Text(Assets.fontMedium, win);
		jd.text = Lang.t._('JDSherbert - Music');
		jd.center();
	}

	override public function onResize() {
		super.onResize();
		win.x = (w() / Const.UI_SCALE * 0.5 - win.outerWidth * 2.5);
		win.y = (h() / Const.UI_SCALE * 0.5 - win.outerHeight * 0.5);
	}

	override public function update() {
		super.update();
		// Hit Escape to exit the credits screen
		var exitCredits = ca.isKeyboardPressed(K.ESCAPE);
		if (exitCredits) {
			new Title();
			destroy();
		}
	}
}
