package en.hazard;

/**
 * A lantern, that when the player passes through it, their
 * dash gets refreshed. There is a cooldown until this can be 
 * refreshed again.
 */
class Lantern extends Hazard {
	public function new(eLan:Entity_Lantern) {
		super(eLan.cx, eLan.cy);
	}
}
