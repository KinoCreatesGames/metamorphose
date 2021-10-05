package en.collectibles;

/**
 * Unlocks the double jump ability in the game allowing the player
 * to traverse the environment with more precision.
 */
class SecondWind extends Collectible {
  override public function setSprite() {
    var tile = hxd.Res.img.heart.toTile();
    var g = new h2d.Graphics(spr);
    // g.beginTileFill(0, 0, 1, 1, tile);
    g.beginFill(0xffA0ff, 1);
    g.drawRect(0, 0, tile.width, tile.height);
    g.endFill();
    g.y -= (tile.height - tile.height * 0.25);
    spr.y -= tile.height;
    xr = 0;
    max_sin = tile.width * 0.5;
  }
}