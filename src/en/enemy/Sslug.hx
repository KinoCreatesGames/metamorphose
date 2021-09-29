package en.enemy;

class Sslug extends Enemy {
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
    var sslugAse = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS,
      hxd.Res.img.sslug_aseprite.toAseprite());

    spr.set(sslugAse);
    spr.anim.playAndLoop('walk');
  }

  override public function update() {
    super.update();
    state.update();
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