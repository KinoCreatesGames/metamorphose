import h2d.Text.Align;
import h2d.Flow.FlowAlign;

class Title extends dn.Process {
	var game(get, never):Game;

	inline function get_game() {
		return Game.ME;
	}

	public var complete:Bool;
	public var win:h2d.Flow;

	public function new() {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_UI);
		complete = false;

		setupTitleWindow();
		// Start of the title sequence
	}

	public function setupTitleWindow() {
		win = new h2d.Flow(root);
		var width = Std.int(w() / 3);
		win.backgroundTile = h2d.Tile.fromColor(0xFF0000, width, 100, 0.);
		win.borderHeight = 6;
		win.borderWidth = 6;

		win.layout = Vertical;
		win.verticalAlign = FlowAlign.Middle;

		win.padding = 24;
		// Center at the bottom
		// win.x = ((w() / 2) - win.outerWidth / 2);
		setupTitleOptions();
		dn.Process.resizeAll();
	}

	public function setupTitleOptions() {
		var newGame = new h2d.Text(Assets.fontMedium, win);
		newGame.text = Lang.t._('New Game');
		newGame.textColor = 0xffffff;
		newGame.center();
		var ngInt = new h2d.Interactive(win.outerWidth, newGame.textHeight, newGame);
		// Handles the relocation of the x coordinate thanks to the alignment change
		ngInt.x = newGame.getSize().xMin;
		ngInt.onClick = (event) -> {
			complete = true;
		}
		ngInt.onOver = (event) -> {
			newGame.alpha = 0.5;
		}
		ngInt.onOut = (event) -> {
			newGame.alpha = 1;
		}

		var credits = new h2d.Text(Assets.fontMedium, win);
		credits.text = Lang.t._('Credits');
		credits.textColor = 0xffffff;
		credits.center();
		var crInt = new h2d.Interactive(win.outerWidth, credits.textHeight, credits);
		crInt.x = credits.getSize().xMin;
		crInt.onOver = (event) -> {
			credits.alpha = 0.5;
		}
		crInt.onOut = (event) -> {
			credits.alpha = 1;
		}
		crInt.onClick = (event) -> {
			// Go to credits scene
			this.destroy();
			new Credits();
		}

		#if hl
		var exit = new h2d.Text(Assets.fontMedium, win);
		exit.text = 'Exit';
		exit.textColor = 0xffffff;
		exit.center();
		var exitInt = new h2d.Interactive(win.outerWidth, newGame.textHeight, exit);
		exitInt.x = exit.getSize().xMin;
		exitInt.onClick = (event) -> {
			hxd.System.exit();
		}
		exitInt.onOver = (event) -> {
			exit.alpha = 0.5;
		}
		exitInt.onOut = (event) -> {
			exit.alpha = 1;
		}
		#end
	}

	override public function update() {
		super.update();
		if (complete) {
			Game.ME.startInitialGame();
			destroy();
		}
	}

	override public function onResize() {
		super.onResize();
		win.x = (w() / Const.UI_SCALE * 0.5 - win.outerWidth * 1.5);
		win.y = (h() / Const.UI_SCALE * 0.5 - win.outerHeight * 0.5);
	}
}
