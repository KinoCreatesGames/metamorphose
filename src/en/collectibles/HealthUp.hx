package en.collectibles;

/**
 * Adds a permanent health upgrade to the player when picked up
 */
class HealthUp extends Collectible {
  public var levelUID:String;

  override public function setSprite() {
    var tile = hxd.Res.img.heart_gold.toTile();
    var g = new h2d.Graphics(spr);
    g.beginTileFill(0, 0, 1, 1, tile);
    g.drawRect(0, 0, tile.width, tile.height);
    g.endFill();
    g.y -= (tile.height - tile.height * 0.25);
    xr = 0;
    max_sin = tile.width * 0.5;
  }
}