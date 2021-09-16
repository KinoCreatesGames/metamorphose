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
		win.padding = 24;
		setupTitleOptions();
	}

	public function setupTitleOptions() {
		var newGame = new h2d.Text(Assets.fontMedium, win);
		newGame.text = 'New Game';
		newGame.textColor = 0xffffff;
		var ngInt = new h2d.Interactive(win.outerWidth, newGame.textHeight, newGame);
		ngInt.onClick = (event) -> {
			complete = true;
		}
		ngInt.onOver = (event) -> {
			newGame.alpha = 0.5;
		}
		ngInt.onOut = (event) -> {
			newGame.alpha = 1;
		}

		#if hl
		var exit = new h2d.Text(Assets.fontMedium, win);
		exit.text = 'Exit';
		exit.textColor = 0xffffff;
		var exitInt = new h2d.Interactive(win.outerWidth, newGame.textHeight, exit);
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
}
