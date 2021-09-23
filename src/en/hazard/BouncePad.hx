package en.hazard;

/**
 * Bounce pad, when the player touches this, they will get a sudden
 * boost of speed and be launched into the air at a high speed.
 */
class BouncePad extends Hazard {
	public function new(eBouncePad:Entity_BouncePad) {
		super(eBouncePad.cx, eBouncePad.cy);
	}
}
