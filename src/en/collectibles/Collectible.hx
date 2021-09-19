package en.collectibles;

import dn.Log;

class Collectible extends Entity {
	/**
	 * Coordinate of the collectible in the game.
	 * Uses LDTk grid coordinates for spawning into the project.
	 * @param x 
	 * @param y 
	 */
	public var max_sin:Float;

	public var elapsed:Float = 0;
	public var initialY:Float = 0;

	public function new(x:Int, y:Int) {
		super(x, y);
		setSprite();
		initialY = 0.5;
	}

	public function setSprite() {
		var tile = h2d.Tile.fromColor(0x70008f, 8, 8, 1);
		var g = new h2d.Graphics(spr);
		g.tile = tile;
		max_sin = tile.width * 0.5;
	}

	override public function update() {
		bounceAnim();
		super.update();
	}

	/**
	 * Bounces the collectible at the current position
	 * on the Y axis. This uses the YR value based on how far
	 		* it can go into the other grid columns.
	 */
	public function bounceAnim() {
		elapsed = (Game.ME.uftime) * (Math.PI / 180);
		yr = (M.fclamp(Math.abs(Math.sin(elapsed * 0.6)), 0.5, 0.9));
	}
}
