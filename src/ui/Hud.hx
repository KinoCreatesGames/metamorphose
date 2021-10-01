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
  var key:Graphics;
  var keyText:h2d.Text;

  public function new() {
    super(Game.ME);

    createRootInLayers(game.root, Const.DP_UI);
    root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

    flow = new h2d.Flow(root);
    createUIElements();
  }

  public function createUIElements() {
    health = new h2d.Graphics(flow);
    keyText = new h2d.Text(Assets.fontSmall, flow);
    keyText.text = 'x${0}';
    key = new h2d.Graphics(flow);
  }

  override function onResize() {
    super.onResize();
    root.setScale(Const.UI_SCALE);
  }

  public inline function invalidate()
    invalidated = true;

  function render() {
    drawKeys();
    drawHearts();
  }

  /**
   * Draw keys that you have obtained in the game.
   */
  public function drawKeys() {
    if (Game.ME.level != null) {
      key.clear();
      var tile = hxd.Res.img.game_key.toTile();
      key.beginTileFill(0, 0, 1, 1, tile);
      key.drawRect(0, 0, tile.width, tile.height);
      key.endFill();
      keyText.text = 'x${Game.ME.level.hero.keys}';
    }
  }

  /**
   * Draw hearts based on current hero HP
   */
  public function drawHearts() {
    if (Game.ME.level != null) {
      health.clear();
      var plHealth = Game.ME.level.hero.health;

      var tile = hxd.Res.img.heart.toTile();
      for (i in 0...plHealth) {
        var scale = 2;
        health.beginTileFill(i * tile.width * scale, 0, scale, scale, tile);
        health.drawRect(i * tile.width * scale, 0, tile.width * scale,
          tile.height * scale);
      }
      health.endFill();
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