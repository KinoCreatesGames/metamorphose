package ui;

import h2d.Graphics;

class Hud extends dn.Process {
  public var game(get, never):Game;

  inline function get_game()
    return Game.ME;

  public var fx(get, never):Fx;

  inline function get_fx()
    return Game.ME.fx;

  public var level(get, never):Level;

  inline function get_level()
    return Game.ME.level;

  var flow:h2d.Flow;
  var invalidated = true;

  var health:Graphics;

  public function new() {
    super(Game.ME);

    createRootInLayers(game.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

    flow = new h2d.Flow(root);
    health = new h2d.Graphics(flow);
  }

  override function onResize() {
    super.onResize();
    root.setScale(Const.UI_SCALE);
  }

  public inline function invalidate()
    invalidated = true;

  function render() {}

  /**
   * Draw hearts based on current hero HP
   */
  public function drawHearts() {
    if (Game.ME.level != null) {
      health.clear();
      var plHealth = Game.ME.level.hero.health;
      var tile = hxd.Res.img.heart.toTile();
      health.beginTileFill(0, 0, 1, 1, tile);
      health.drawRect(0, 0, tile.width * plHealth, tile.height * plHealth);
    }
  }

  override function postUpdate() {
    super.postUpdate();

    if (invalidated) {
      invalidated = false;
      render();
    }
  }
}