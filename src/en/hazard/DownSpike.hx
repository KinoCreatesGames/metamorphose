package en.hazard;

/**
 * A spike in the game which does damage to the player on contact
 * The down spike in the game.
 */
class DownSpike extends Hazard {
  public function new(spike:Entity_DownSpike) {
    super(spike.cx, spike.cy);
    var tile = hxd.Res.img.spike.toTile();
    var graphic = new h2d.Graphics(spr);
    graphic.beginTileFill(0, 0, 1, 1, tile);
    graphic.drawRect(0, 0, tile.width, tile.height);
    graphic.endFill();
    graphic.scaleY = -1 * graphic.scaleY;
    graphic.y -= (tile.height);
    spr.y -= tile.height; // Doesn't seem to have an effect
    xr = 0;
  }
}