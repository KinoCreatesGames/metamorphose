package en.hazard;

/**
 * Exit which starts the move from one level to the next within the game.
 * 
 */
class Exit extends Hazard {
  public var lvlId:Int = 0;
  public var startPoint:Vec2;

  public function new(exit:Entity_Exit) {
    super(exit.cx, exit.cy);
    lvlId = exit.f_lvlId;
    startPoint = new Vec2(exit.f_startX, exit.f_startY);
  }
}