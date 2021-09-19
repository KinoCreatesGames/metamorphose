package en.collectibles;

class Heart extends Collectible {
	override public function setSprite() {
		var tile = h2d.Tile.fromColor(0xff008f, 8, 8, 1);
		var g = new h2d.Graphics(spr);
		g.tile = tile;
		max_sin = tile.width * 0.5;
	}
}
