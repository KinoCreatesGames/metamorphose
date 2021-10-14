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
    var lightTile = hxd.Res.img.light_three.toTile();
    var g = new h2d.Graphics(spr);
    var lightG = new h2d.Graphics(spr);
    g.beginTileFill(0, 0, tile.width, tile.height);
    g.drawRect(0, 0, 16, 16);
    g.endFill();
    lightG.beginTileFill(0, 0, 1, 1, lightTile);
    lightG.setColor(0xffff00, 1);
    lightG.drawRect(0, 0, lightTile.width, lightTile.height);
    lightG.endFill();

    lightG.blendMode = h2d.BlendMode.Add;
    lightG.alpha = 0.5;
    lightG.y -= lightTile.height * 0.55;
    lightG.x -= lightTile.width * 0.5;

    spr.y -= tile.height;
  }
}