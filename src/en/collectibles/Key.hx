package en.collectibles;

/**
 * Key for unlocking the doors in the game 
 * when you interact with them.
 */
class Key extends Collectible {
	public function new(key:Entity_GameKey) {
		super(key.cx, key.cy);
	}

	override public function setSprite() {
		var g = new h2d.Graphics(spr);

		g.beginFill(0xff00ff, 0.8);
		g.drawRect(0, 0, 16, 16);
		g.endFill();
	}
}
