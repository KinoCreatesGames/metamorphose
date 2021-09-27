package en.hazard;

/**
 * A spike in the game which does damage to the player on contact
 */
class Spike extends Hazard {
  public function new(spike:Entity_Spike) {
    super(spike.cx, spike.cy);
    var tile = hxd.Res.img.spike.toTile();
    var graphic = new h2d.Graphics(spr);
    graphic.beginTileFill(0, 0, 1, 1, tile);
    graphic.endFill();
  }
}