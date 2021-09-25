import en.enemy.Ziggle;
import en.hazard.MovingPlatform;
import en.collectibles.Key;
import en.Enemy;
import en.collectibles.Checkpoint;
import en.hazard.Exit;
import en.hazard.BouncePad;
import en.hazard.Hazard;
import en.collectibles.Collectible;
import en.collectibles.Heart;
import en.Hero;

class Level extends dn.Process {
  public static var ME:Level;

  var game(get, never):Game;

  inline function get_game()
    return Game.ME;

  var fx(get, never):Fx;

  inline function get_fx()
    return Game.ME.fx;

  /** Level grid-based width**/
  public var cWid(get, never):Int;

  inline function get_cWid()
    return 16;

  /** Level grid-based height **/
  public var cHei(get, never):Int;

  inline function get_cHei()
    return 16;

  /** Level pixel width**/
  public var pxWid(get, never):Int;

  inline function get_pxWid()
    return cWid * Const.GRID;

  /** Level pixel height**/
  public var pxHei(get, never):Int;

  inline function get_pxHei()
    return cHei * Const.GRID;

  public var data:LDTkProj_Level;

  public var hero:Hero;

  public var collectibleGrp:Array<Collectible>;
  public var hazardGrp:Array<Hazard>;
  public var checkpointGrp:Array<Checkpoint>;
  public var enemyGrp:Array<Enemy>;
  public var bgm:hxd.snd.Channel;

  var invalidated = true;

  public var currentCheckpoint:Checkpoint;

  public function new(?level:LDTkProj_Level) {
    super(Game.ME);
    ME = this;
    createRootInLayers(Game.ME.scroller, Const.DP_BG);
    if (level != null) {
      data = level;
    }
    bgm = hxd.Res.music.pixel_sphere_wav.play(true);
    createGroups();
    createEntities();
    Game.ME.camera.recenter();
  }

  public function createGroups() {
    collectibleGrp = [];
    hazardGrp = [];
    checkpointGrp = [];
    enemyGrp = [];
  }

  public function createEntities() {
    for (player in data.l_Entities.all_Player) {
      // trace('Created player, ${player.cx}, ${player.cy}');
      // TODO: Use cx, cy the grid coordinates for player spawning

      var hero = new Hero(player.cx, player.cy);
      this.hero = hero;
    }

    // Enemies
    for (lEnemy in data.l_Entities.all_Enemy) {
      createEnemy(lEnemy);
    }

    // Collectibles
    for (heart in data.l_Entities.all_Heart) {
      var heart = new Heart(heart.cx, heart.cy);
      collectibleGrp.push(heart);
    }

    for (gKey in data.l_Entities.all_GameKey) {
      var key = new Key(gKey);
      collectibleGrp.push(key);
    }

    // Hazards
    for (bPad in data.l_Entities.all_BouncePad) {
      var bouncePad = new BouncePad(bPad);
      hazardGrp.push(bouncePad);
    }

    for (mPlat in data.l_Entities.all_MovingPlatform) {
      var movingPlatform = new MovingPlatform(mPlat);
      hazardGrp.push(movingPlatform);
    }

    // Exits and Checkpoints

    for (lExit in data.l_Entities.all_Exit) {
      var exit = new Exit(lExit);
      hazardGrp.push(exit);
    }

    for (lCheckpoint in data.l_Entities.all_Checkpoint) {
      var checkpoint = new Checkpoint(lCheckpoint);
      checkpointGrp.push(checkpoint);
    }
  }

  public function createEnemy(enemy:Entity_Enemy) {
    var enemyType = enemy.f_EnemyType;
    switch (enemyType) {
      case Ziggle:
        var enemy = new Ziggle(enemy);
        enemyGrp.push(enemy);
      case _:
        // Do nothing
    }
  }

  /** TRUE if given coords are in level bounds **/
  public inline function isValid(cx, cy)
    return cx >= 0 && cx < cWid && cy >= 0 && cy < cHei;

  /** Gets the integer ID of a given level grid coord **/
  public inline function coordId(cx, cy)
    return cx + cy * cWid;

  /** Ask for a level render that will only happen at the end of the current frame. **/
  public inline function invalidate() {
    invalidated = true;
  }

  function render() {
    // Placeholder level render
    root.removeChildren();
    // Render Auto Layer
    var tileGroup = data.l_AutoTiles.render();

    root.addChild(tileGroup);
    // for (cx in 0...cWid)
    // 	for (cy in 0...cHei) {
    // 		var g = new h2d.Graphics(root);
    // 		if (cx == 0 || cy == 0 || cx == cWid - 1 || cy == cHei - 1)
    // 			g.beginFill(0xffcc00);
    // 		else
    // 			g.beginFill(Color.randomColor(rnd(0, 1), 0.5, 0.4));
    // 		g.drawRect(cx * Const.GRID, cy * Const.GRID, Const.GRID, Const.GRID);
    // 	}
  }

  // Collision detection against the level layout

  /**
   * Collision detection between the elements on the level.  
   * Level information is available to all entities to check.
   * Returns true if the position overlaps a level tile 
   * @param x 
   * @param y 
   */
  public function hasAnyCollision(x:Int, y:Int) {
    return data.l_AutoBase.getInt(x, y) > 0;
  }

  /**
   * Return true when the grid coordinate of another element
   * overlaps with the grid coordinate of a collectible.
   * @param x 
   * @param y 
   */
  public function hasAnyCollectibleCollision(x:Int, y:Int) {
    return collectibleGrp.exists((collectible) -> return collectible.cx == x
      && collectible.cy == y);
  }

  public function collidedCollectible(x:Int, y:Int) {
    return collectibleGrp.filter((collectible) -> return collectible.cx == x
      && collectible.cy == y)
      .first();
  }

  /**
   * Return true when the grid coordinate of another element
   * overlaps with the grid coordinate of a collectible.
   * @param x 
   * @param y 
   */
  public function hasAnyEnemyCollision(x:Int, y:Int) {
    return enemyGrp.exists((collectible) -> return collectible.cx == x
      && collectible.cy == y);
  }

  public function enemyCollided(x:Int, y:Int) {
    return enemyGrp.filter((collectible) -> return collectible.cx == x
      && collectible.cy == y)
      .first();
  }

  /**
   * Return true when the grid coordinate of another element
   * overlaps with the grid coordinate of a checkpoint.
   * @param x 
   * @param y 
   */
  public function hasAnyCheckpointCollision(x:Int, y:Int) {
    return checkpointGrp.exists((collectible) -> return collectible.cx == x
      && collectible.cy == y);
  }

  public function checkpointCollided(x:Int, y:Int) {
    return checkpointGrp.filter((collectible) -> return collectible.cx == x
      && collectible.cy == y)
      .first();
  }

  /**
   * Return true when the grid coordinate of another element
   * overlaps with the grid coordinate of a hazard.
   * @param x 
   * @param y 
   */
  public function hasAnyHazardCollision(x:Int, y:Int) {
    return hazardGrp.exists((hazard) ->
      return hazard.cx == x && hazard.cy == y);
  }

  /**
   * Checks platform collides.
   * Note that if you collide with m platform, we need to check two columns rather
   * than 1.
   * @param x 
   * @param y 
   */
  public function hasAnyMPlatCollision(x:Int, y:Int) {
    return hazardGrp.exists((hazard) -> return (hazard.cx == x
      || hazard.cx + 1 == x)
      && hazard.cy == y
      && Std.isOfType(hazard, en.hazard.MovingPlatform));
  }

  /**
   * Checks platform collides.
   * Note that if you collide with m platform, we need to check two columns rather
   * than 1.
   * @param x 
   * @param y 
   */
  public function collidedMPlat(x:Int, y:Int) {
    return hazardGrp.filter((hazard) -> return (hazard.cx == x
      || hazard.cx + 1 == x)
      && hazard.cy == y
      && Std.isOfType(hazard, en.hazard.MovingPlatform))
      .first();
  }

  public function collidedHazard(x:Int, y:Int) {
    return hazardGrp.filter((hazard) -> return hazard.cx == x && hazard.cy == y)
      .first();
  }

  override public function update() {
    super.update();
    // Pause
    if (Game.ME.ca.isKeyboardPressed(K.ESCAPE)) {
      hxd.Res.sound.pause_in.play();
      pause();
      new Pause();
    }
  }

  override function postUpdate() {
    super.postUpdate();

    if (invalidated) {
      invalidated = false;
      render();
    }
  }

  override function onDispose() {
    super.onDispose();
    bgm.stop();
  }
}