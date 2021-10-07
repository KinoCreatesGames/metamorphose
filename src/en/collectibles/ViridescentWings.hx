package en.collectibles;

/**
 * Dash Ability in the game that allows the 
 * player to start dashing around in the game.
 */
class ViridescentWings extends Collectible {
  public function new(vwing:Entity_ViridescentWings) {
    super(vwing.cx, vwing.cy);
  }

  override public function setSprite() {
    var tile = hxd.Res.maps.final_tileset_png.toTile();
    tile.setPosition(272, 48);
    var size = 16;
    var g = new h2d.Graphics(spr);

    g.beginTileFill(0, 0, 1, 1, tile);
    g.drawRect(0, 0, size, size);
    g.endFill();
    g.y -= (size - size * 0.25);
    spr.y -= size;
    xr = 0;
    max_sin = size * 0.5;
  }
}