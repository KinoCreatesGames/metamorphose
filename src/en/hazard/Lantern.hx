package en.hazard;

/**
 * A lantern, that when the player passes through it, their
 * dash gets refreshed. There is a cooldown until this can be 
 * refreshed again.
 */
class Lantern extends Hazard {
  public function new(eLan:Entity_Lantern) {
    super(eLan.cx, eLan.cy);
    var tile = hxd.Res.img.dash_lantern.toTile();
    var g = new h2d.Graphics(spr);
    g.beginTileFill(0, 0, tile.width, tile.height);
    g.drawRect(0, 0, 16, 16);
    g.endFill();

    spr.y -= tile.height;
  }
}