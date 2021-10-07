package en;

/**
 * Events that show up in game so that the player
 * can interact with them and read them.
 */
class Event extends Entity {
  public var eventRadius:Int;
  public var eventName:String;

  public function new(lEvent:Entity_Event) {
    super(lEvent.cx, lEvent.cy);
    eventName = lEvent.f_eventName;
    eventRadius = lEvent.f_radius;
  }
}