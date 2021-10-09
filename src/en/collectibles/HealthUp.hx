package en.collectibles;

/**
 * Adds a permanent health upgrade to the player when picked up
 */
class HealthUp extends Collectible {
  override public function setSprite() {
    var tile = hxd.Res.img.heart.toTile();
    var g = new h2d.Graphics(spr);
    g.beginTileFill(0, 0, 1, 1, tile);
    g.drawRect(0, 0, tile.width, tile.height);
    g.endFill();
  }
}