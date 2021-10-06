class GameLight extends Entity {
  public function new(light:Entity_Light) {
    super(light.cx, light.cy);

    var tile = hxd.Res.img.light_three.toTile();

    var g = new h2d.Graphics(spr);
    g.beginTileFill(0, 0, 1, 1, tile);
    g.setColor(0x00ffff, 1);
    g.drawRect(0, 0, tile.width, tile.height);
    g.endFill();

    g.blendMode = h2d.BlendMode.Add;
    g.alpha = 0.5;
    g.y -= tile.height * 0.55;
    g.x -= tile.width * 0.5;
  }
}