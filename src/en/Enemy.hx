package en;

/**
 * Base Enemy class that is used to as a base for any enemy type
 */
class Enemy extends Entity {
	public var health:Int = 3;

	public function new(x:Int, y:Int) {
		super(x, y);
		var graphics = new h2d.Graphics(spr);
		graphics.beginFill(0xff0000);
		graphics.drawRect(0, 0, 16, 16);
	}

	public function takeDamage(value:Int = 1) {
		health = M.iclamp(health - value, 0, M.T_INT32_MAX);
		if (health == 0) {
			// Die
			this.destroy();
		}
	}
}
