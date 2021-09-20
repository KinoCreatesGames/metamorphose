package en.collectibles;

/**
 * Used to save the checkpoints for the individual hero within the game.
 * We use this to record the information and current position.
 */
class Checkpoint extends Entity {
	/**
	 * Takes in the grid cx, cy column information to be placed on the map.
	 * Records a checkpoint when the player interacts with it and saves their
	 * current location progres.
	 * @param x 
	 * @param y 
	 */
	public function new(x:Int, y:Int) {
		super(x, y);
		var g = new h2d.Graphics(spr);
		g.beginFill(0xa0a0ff);
		g.drawRect(0, 0, 16, 16);
		g.endFill();
	}
}
