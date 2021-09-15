package en;

/**
 * Base Enemy class that is used to as a base for any enemy type
 */
class Enemy extends Entity {
	public function new(x:Int, y:Int) {
		super(x, y);
		var graphics = new h2d.Graphics(spr);
		graphics.beginFill(0xff0000);
		graphics.drawRect(0, 0, 16, 16);
	}
}
