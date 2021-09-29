package en;

/**
 * Base Enemy class that is used to as a base for any enemy type
 */
class Enemy extends Entity {
  public var health:Int = 3;
  public var isOnFloor:Bool;
  public var sightRange:Float;
  public var state:State;

  public var pathPoints:Array<tools.Vec2>;
  public var looping:Bool;
  public var pointIndex = 0;
  public var speed:Float;

  /**
   * Whether to apply physics or not to the enemy.
   * This allows for variation between enemies that can fly or ones
   * that are stuck to the ground
   */
  public var grounded:Bool;

  public function new(x:Int, y:Int) {
    super(x, y);
    grounded = true;
    setSprite();
  }

  public function setSprite() {
    var graphics = new h2d.Graphics(spr);
    graphics.beginFill(0xff0000);
    graphics.drawRect(0, 0, 16, 16);
    graphics.y -= Const.GRID * 0.5;
    sightRange = 3;
  }

  public function takeDamage(value:Int = 1) {
    health = M.iclamp(health - value, 0, M.T_INT32_MAX);
    if (health == 0) {
      // Die
      this.destroy();
    }
  }

  override public function fixedUpdate() {
    if (!isOnFloor && grounded) {
      applyPhysics();
    }
    handleCollision();
    super.fixedUpdate();
  }

  public function inLineOfSight() {
    if (Level.ME.hero != null || !Level.ME.hero.destroyed) {
      var hero = Level.ME.hero;
      var distance = M.dist(hero.cx, hero.cy, this.cx, this.cy);
      return M.fabs(distance) < sightRange;
    }
    return false;
  }

  public function handleCollision() {
    levelCollision();
  }

  public function levelCollision() {
    // Left
    if (level.hasAnyCollision(cx - 1, cy) && xr <= 0.3) {
      xr = 0.3;
      dx = 0;
      // dx = M.fabs(dx);
    }

    // Right
    if (level.hasAnyCollision(cx + 1, cy) && xr >= 0.1) {
      // push back to previous cell
      xr = 0.1;
      dx = 0;
      // dx = (-1 * M.fabs(dx));
    }

    // Up
    if (level.hasAnyCollision(cx, cy - 1)
      || level.hasAnyCollision(cx + M.round(xr), cy - 1)) {
      // Set some squash for when you touch the ceiling
      setSquashY(0.8);
      dy = M.fabs(dy);
    }

    // Down

    if (level.hasAnyCollision(cx, cy + 1)
      && yr >= 0.5
      || level.hasAnyCollision(cx + M.round(xr), cy + 1)
      && yr >= 0.5) {
      // Handle squash and stretch for entities in the game
      if (level.hasAnyCollision(cx, cy + M.round(yr + 0.3)) && !isOnFloor) {
        setSquashY(0.6);
      }
      isOnFloor = true;

      // dy = 0;

      // dy = (-1 * M.fabs(dy));
      dy = 0;
      // If cy is still in object (yr)
      yr = 0.5;
    } else {
      isOnFloor = false;
    }
  }

  public function applyPhysics() {
    dy += 0.05;
  }
}