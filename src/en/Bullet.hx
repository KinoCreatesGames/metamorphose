package en;

class Bullet extends Entity {
  public var fireDir:Vec2;
  public var speed:Float;

  /**
   * Based on fixed update
   */
  public static inline var ERASE_TIME:Int = 60;

  public function new(x:Int, y:Int) {
    super(x, y);
    fireDir = new Vec2(0, 0);
    speed = 0;
    setSprite();
  }

  public function setFireDir(x:Int, y:Int) {
    fireDir.x = x;
    fireDir.y = y;
  }

  public function setSpd(amount:Float) {
    speed = amount;
  }

  public function setSprite() {
    var g = new h2d.Graphics(spr);
    g.beginFill(0xffffff, 1);
    g.drawCircle(0, 0, 4);
    g.endFill();
  }

  override function update() {
    super.update();
    dx = fireDir.x * speed * tmod;
    dy = fireDir.y * speed * tmod;
  }

  override function fixedUpdate() {
    super.fixedUpdate();
    if (!cd.has('stayAlive')) {
      this.destroy();
    }
    handleCollision();
  }

  public function handleCollision() {
    if (Game.ME.level != null) {
      var level = Game.ME.level;
      // If collide with enemy implode bullet
      if (level.hasAnyEnemyCollision(cx, cy)) {
        var enemy = level.enemyCollided(cx, cy);
        enemy.takeDamage(1);
        this.destroy();
      }
    }
  }
}