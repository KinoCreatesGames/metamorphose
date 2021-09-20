package en.hazard;

/**
 * Exit which starts the move from one level to the next within the game.
 * 
 */
class Exit extends Hazard {
	public var lvlId:Int = 0;

	public function new(exit:Entity_Exit) {
		super(exit.cx, exit.cy);
		lvlId = exit.f_lvlId;
	}
}
