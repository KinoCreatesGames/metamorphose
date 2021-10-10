package en.enemy;

/**
 * Final boss in the game. Floating enemy that moves around the field.
 * Has several elements to watch out for when fighting.
 * Touching them does not do damage to the player. 
 */
class Boss extends Enemy {
  public static inline var HEALTH_CAP:Int = 20;

  /**
   * True if at less than 50% health.
   */
  public var danger(get, never):Bool;

  public inline function get_danger() {
    return (health / HEALTH_CAP) < 0.5;
  }

  /**
   * True if at less than 25% health.
   */
  public var emergency(get, never):Bool;

  public inline function get_emergency() {
    return (health / HEALTH_CAP) < 0.25;
  }

  public var healthy(get, never):Bool;

  public inline function get_healthy() {
    return (health / HEALTH_CAP) > 0.5;
  }

  public function new(enemy:Entity_Enemy) {
    super(enemy.cx, enemy.cy);
    sightRange = 5;
    state = new State(idle);
  }

  public function attacking() {
    if (!inLineOfSight()) {
      state.currentState = idle;
    }
    if (emergency) {} else if (danger) {
      if (!cd.has('laser')) {
        laser();
      }
    } else if (healthy) {
      if (!cd.has('slice')) {
        slice();
      }
    }
  }

  public function dashAttak() {}

  /**
   * Fires a laser that covers the entire floor level. 
   * Straight line only.
   */
  public function laser() {
    cd.setS('laser', 3);
  }

  /**
   * Wave that goes a short distance.
   * Has a quick turn around time.
   */
  public function slice() {
    cd.setS('slice', 2);
  }

  public function idle() {
    if (inLineOfSight()) {
      state.currentState = attacking;
    }
  }

  override public function update() {
    super.update();
    state.update();
    if (dx != 0) {
      dir = (-1 * M.sign(dx));
    }
  }
}