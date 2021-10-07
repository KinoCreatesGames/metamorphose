package en.collectibles;

/**
 * Unlocks the double jump ability in the game allowing the player
 * to traverse the environment with more precision.
 */
class SecondWind extends Collectible {
  public function new(swind:Entity_SecondWind) {
    super(swind.cx, swind.cy);
  }

  override public function setSprite() {
    var tile = hxd.Res.maps.final_tileset_png.toTile();
    tile.setPosition(256, 48);
    var size = 16;
    var g = new h2d.Graphics(spr);
    // g.beginTileFill(0, 0, 1, 1, tile);
    g.beginFill(0xffA0ff, 1);
    g.drawRect(0, 0, size, size);
    g.endFill();
    g.y -= (size - size * 0.25);
    spr.y -= size;
    xr = 0;
    max_sin = size * 0.5;
  }
}