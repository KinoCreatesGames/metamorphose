package en.hazard;

/**
 * Door which is unlocked by keys when the player interacts with them
 * in the game. Can't pass through if the door is locked.
 */
class Door extends Hazard {
  public var unlocked:Bool;

  public function new(door:Entity_Door) {
    super(door.cx, door.cy);
    this.unlocked = door.f_unlocked;
  }
}