package en.hazard;

class MovingPlatform extends Hazard {
  public var pathPoints:Array<tools.Vec2>;
  public var looping:Bool;
  public var pointIndex = 0;
  public var platformSpeed:Float;
  public var id:String;
  public var player:Hero;

  /**
   * Wait time between destinations per point.
   */
  public var waitTime:Float;

  public function new(movingPlat:Entity_MovingPlatform) {
    super(movingPlat.cx, movingPlat.cy);
    id = '${movingPlat.cx}_${movingPlat.cy}';
    looping = true;
    platformSpeed = 0.05;
    waitTime = 3;

    pathPoints = movingPlat.f_path.map((pathPoint) -> {
      return new Vec2(pathPoint.cx, pathPoint.cy);
    });
    setSprite();
  }

  public function setSprite() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0x101010, 1);
    g.drawRect(0, 0, 32, 16);
    g.endFill();
    g.y -= 16;
  }

  override public function fixedUpdate() {
    super.fixedUpdate();

    followPath();
  }

  public function followPath() {
    var point = pathPoints[pointIndex % pathPoints.length];
    if (point.x != cx || point.y != cy) {
      // Follow the path by checking the distance from point
      var dest = new Vec2(point.x - cx, point.y - cy).normalize();
      dx = dest.x * platformSpeed;

      dy = dest.y * platformSpeed;
      // Fixes issue with collision on platforms with this setup
    } else {
      if (!Game.ME.delayer.hasId('platformStop' + id)) {
        Game.ME.delayer.addS('platformStop' + id, () -> {
          pointIndex++;
        }, waitTime);
      }
    }
    if (player != null) {
      // player.yr = 1;
      if (player.plat != null) {
        player.dx = dx;
        player.dy = dy;
      }
      if (M.fabs(player.cy - cy) > 1 || M.fabs(player.cx - cx) > 1) {
        player.plat = null;
        player = null;
      }
    }
  }
}