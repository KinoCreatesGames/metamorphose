package en.hazard;

class MovingPlatform extends Hazard {
  public var pathPoints:Array<tools.Vec2>;
  public var looping:Bool;
  public var pointIndex = 0;
  public var platformSpeed:Float;
  public var initialWait = 3;
  public var id:String;
  public var player:Hero;

  /**
   * Wait time between destinations per point.
   */
  public var waitTime:Float;

  public var oneShot:Bool;
  public var reachedFinalDestination:Bool;

  public function new(movingPlat:Entity_MovingPlatform) {
    super(movingPlat.cx, movingPlat.cy);
    id = '${movingPlat.cx}_${movingPlat.cy}';
    looping = true;
    platformSpeed = 0.05;
    waitTime = 3;
    oneShot = movingPlat.f_oneShot;
    reachedFinalDestination = false;

    pathPoints = movingPlat.f_path.map((pathPoint) -> {
      return new Vec2(pathPoint.cx, pathPoint.cy);
    });

    cd.setS('initialWait', initialWait);

    setSprite();
  }

  public function setSprite() {
    var assetTile = hxd.Res.maps.final_tileset_png.toTile();
    assetTile.setPosition(176, 16);
    var g = new h2d.Graphics(spr);
    g.beginTileFill(0, 0, 1, 1, assetTile);
    g.drawRect(0, 0, 32, 16);
    g.endFill();
    g.x -= 8;
    g.y -= 18;
  }

  override public function fixedUpdate() {
    super.fixedUpdate();
    if (!cd.has('initialWait')) {
      followPath();
    }
  }

  public function followPath() {
    var point = pathPoints[pointIndex % pathPoints.length];
    if (point.x != cx || point.y != cy && !reachedFinalDestination) {
      // Follow the path by checking the distance from point
      var dest = new Vec2(point.x - cx, point.y - cy).normalize();
      dx = dest.x * platformSpeed;

      dy = dest.y * platformSpeed;
      // Fixes issue with collision on platforms with this setup
    } else {
      // Hit the final point
      if (pointIndex == (pathPoints.length - 1) && oneShot) {
        reachedFinalDestination = true;
      }
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
      // if (M.dist(player.cx, player.cy, cx, cy) > 2.4) {
      //   trace(M.dist(player.cx, player.cy, cx, cy));
      //   player.plat = null;
      //   player = null;
      // }
      // if (M.fabs(player.cy - cy) > 1 || M.fabs(player.cx - cx) > 1) {
      //   player.plat = null;
      //   player = null;
      // }
    }
  }

  override function preUpdate() {
    super.preUpdate();

    if (player != null) {
      // player.yr = 1;

      if (player != null && player.plat != null) {
        player.dx = dx;
        player.dy = dy;
      }

      if (M.fabs(player.cy - cy) > 2
        || (M.fabs(player.cx - cx) > 1 && M.fabs(player.cx - (cx + 1)) > 1)) {
        trace('release');
        trace(M.fabs(player.cy - cy));
        player.plat = null;
        player = null;
      }
    }
  }
}