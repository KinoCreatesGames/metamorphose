package en.enemy;

class Ziggle extends Enemy {
  /**
   * Wait time between destinations per point.
   */
  public var waitTime:Float;

  public function new(enemy:Entity_Enemy) {
    super(enemy.cx, enemy.cy);
    state = new State(idle);
    looping = true;
    speed = 0.05;
    pathPoints = enemy.f_Path.map((pathPoint) -> {
      return new Vec2(pathPoint.cx, pathPoint.cy);
    });
    // setSprite();
  }

  public function idle() {
    followPath();
    if (inLineOfSight()) {
      state.currentState = attacking;
    }
  }

  public function attacking() {
    if (!inLineOfSight()) {
      state.currentState = idle;
    }
    // Follow Player or move toward position
    var dxNorm = M.fabs(Level.ME.hero.cx - cx);
    dx = speed * (M.sign(dxNorm) * M.fabs(dxNorm / dxNorm));
  }

  override function setSprite() {
    var zigger = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS,
      hxd.Res.img.zigger2_aseprite.toAseprite());

    spr.set(zigger);
    // Necessary for making sure that the sprite touches the floor when
    // added to the game with new information
    spr.setCenterRatio(0.5, 0.5);
    spr.anim.playAndLoop('walk');
  }

  override public function update() {
    super.update();
    state.update();
    if (dx != 0) {
      dir = M.sign(dx);
    }
  }

  public function followPath() {
    var point = pathPoints[pointIndex % pathPoints.length];
    if (point.x != cx || point.y != cy) {
      // Follow the path by checking the distance from point
      var dest = new Vec2(point.x - cx, point.y - cy).normalize();
      dx = dest.x * speed;

      dy = dest.y * speed;
    } else {
      pointIndex++;
    }
  }
}