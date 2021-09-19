import en.collectibles.Heart;
import en.Hero;

class Level extends dn.Process {
	var game(get, never):Game;

	inline function get_game()
		return Game.ME;

	var fx(get, never):Fx;

	inline function get_fx()
		return Game.ME.fx;

	/** Level grid-based width**/
	public var cWid(get, never):Int;

	inline function get_cWid()
		return 16;

	/** Level grid-based height **/
	public var cHei(get, never):Int;

	inline function get_cHei()
		return 16;

	/** Level pixel width**/
	public var pxWid(get, never):Int;

	inline function get_pxWid()
		return cWid * Const.GRID;

	/** Level pixel height**/
	public var pxHei(get, never):Int;

	inline function get_pxHei()
		return cHei * Const.GRID;

	public var data:LDTkProj_Level;

	var invalidated = true;

	public function new(?level:LDTkProj_Level) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		if (level != null) {
			data = level;
		}
		createEntities();
	}

	public function createEntities() {
		for (player in data.l_Entities.all_Player) {
			trace('Created player, ${player.cx}, ${player.cy}');
			// TODO: Use cx, cy the grid coordinates for player spawning
			var hero = new Hero(player.cx, player.cy);
		}

		for (heart in data.l_Entities.all_Heart) {
			var heart = new Heart(heart.cx, heart.cy);
		}
	}

	/** TRUE if given coords are in level bounds **/
	public inline function isValid(cx, cy)
		return cx >= 0 && cx < cWid && cy >= 0 && cy < cHei;

	/** Gets the integer ID of a given level grid coord **/
	public inline function coordId(cx, cy)
		return cx + cy * cWid;

	/** Ask for a level render that will only happen at the end of the current frame. **/
	public inline function invalidate() {
		invalidated = true;
	}

	function render() {
		// Placeholder level render
		root.removeChildren();
		// Render Auto Layer
		var tileGroup = data.l_AutoTiles.render();

		root.addChild(tileGroup);
		// for (cx in 0...cWid)
		// 	for (cy in 0...cHei) {
		// 		var g = new h2d.Graphics(root);
		// 		if (cx == 0 || cy == 0 || cx == cWid - 1 || cy == cHei - 1)
		// 			g.beginFill(0xffcc00);
		// 		else
		// 			g.beginFill(Color.randomColor(rnd(0, 1), 0.5, 0.4));
		// 		g.drawRect(cx * Const.GRID, cy * Const.GRID, Const.GRID, Const.GRID);
		// 	}
	}

	// Collision detection against the level layout

	/**
	 * Collision detection between the elements on the level.  
	 * Level information is available to all entities to check.
	 * Returns true if the position overlaps a level tile 
	 * @param x 
	 * @param y 
	 */
	public function hasAnyCollision(x:Int, y:Int) {
		return data.l_AutoBase.getInt(x, y) > 0;
	}

	override public function update() {
		super.update();
		// Pause
		if (Game.ME.ca.isKeyboardPressed(K.ESCAPE)) {
			pause();
			new Pause();
		}
	}

	override function postUpdate() {
		super.postUpdate();

		if (invalidated) {
			invalidated = false;
			render();
		}
	}
}
