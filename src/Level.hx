import en.collectibles.HealthUp;
import en.collectibles.SecondWind;
import en.collectibles.ViridescentWings;
import en.enemy.Sslug;
import dn.data.SavedData;
import en.hazard.Spike;
import en.hazard.Door;
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
  public var lightGrp:Array<GameLight>;
  public var eventGrp:Array<en.Event>;
  public var bgm:hxd.snd.Channel;
  public var startX:Int;
  public var startY:Int;
  public var mask:h2d.Bitmap;

  var invalidated = true;

  public var currentCheckpoint:Checkpoint;

  public function new(?level:LDTkProj_Level, startX = -1, startY = -1) {
    super(Game.ME);
    ME = this;
    this.startX = startX;
    this.startY = startY;
    createRootInLayers(Game.ME.scroller, Const.DP_BG);
    if (level != null) {
      data = level;
    }
    bgm = hxd.Res.music.pixel_sphere_wav.play(true);
    #if debug
    bgm.stop();
    #end
    createGroups();
    createEntities();
    Game.ME.camera.recenter();
    // Delete checkpoint on level start
    if (SavedData.exists(CHK_COORDS)) {
      SavedData.delete(CHK_COORDS);
    }
  }

  public function createGroups() {
    collectibleGrp = [];
    hazardGrp = [];
    checkpointGrp = [];
    enemyGrp = [];
    lightGrp = [];
    eventGrp = [];
  }

  public function createEntities() {
    /**
     * A player entity must be placed within the game 
     * stage in order to spawn a player.
     */
    for (player in data.l_Entities.all_Player) {
      // If checkpoint was reached restart at checkpoint position instead
      // Or Game over set in main game
      var plHero = null;
      if (Game.ME.resumeGameOver && SavedData.exists(CHK_COORDS)) {
        var result = SavedData.load(CHK_COORDS, {x: 0, y: 0});
        plHero = new Hero(result.x, result.y);
        Game.ME.resumeGameOver = false;
        #if debug
        trace('Start with checkpoint coordinates');
        #end
      } else {
        if (startX != -1) {
          trace(startX);
          #if debug
          trace('Start with exit coordinates ');
          #end
          plHero = new Hero(startX, startY);
        } else {
          #if debug
          trace('Start with player entity coordinates.');
          #end
          plHero = new Hero(player.cx, player.cy);
        }
      }
      this.hero = plHero;
    }

    // Events
    for (lEvent in data.l_Entities.all_Event) {
      eventGrp.push(new en.Event(lEvent));
    }

    // Enemies
    for (lEnemy in data.l_Entities.all_Enemy) {
      createEnemy(lEnemy);
    }

    // Collectibles
    for (heart in data.l_Entities.all_Heart) {
      collectibleGrp.push(new Heart(heart.cx, heart.cy));
    }

    for (healthUp in data.l_Entities.all_HealthUp) {
      var identifier = '${data.uid}-${healthUp.cx}-${healthUp.cy}';
      if (!Game.ME.permExists(identifier)) {
        var hUp = new HealthUp(healthUp.cx, healthUp.cy);
        collectibleGrp.push(hUp);
      }
    }

    for (gKey in data.l_Entities.all_GameKey) {
      var identifier = '${data.uid}-${gKey.cx}-${gKey.cy}';
      if (!Game.ME.permExists(identifier)) {
        collectibleGrp.push(new Key(gKey));
      }
    }

    for (lVWing in data.l_Entities.all_ViridescentWings) {
      var identifier = '${data.uid}-${lVWing.cx}-${lVWing.cy}';
      if (!Game.ME.permExists(identifier)) {
        collectibleGrp.push(new ViridescentWings(lVWing));
      }
    }

    for (lSWind in data.l_Entities.all_SecondWind) {
      var identifier = '${data.uid}-${lSWind.cx}-${lSWind.cy}';
      if (!Game.ME.permExists(identifier)) {
        collectibleGrp.push(new SecondWind(lSWind));
      }
    }

    // Hazards
    for (bPad in data.l_Entities.all_BouncePad) {
      hazardGrp.push(new BouncePad(bPad));
    }

    for (lSpike in data.l_Entities.all_Spike) {
      hazardGrp.push(new Spike(lSpike));
    }

    for (lDoor in data.l_Entities.all_Door) {
      hazardGrp.push(new Door(lDoor));
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

    for (lLight in data.l_Entities.all_Light) {
      lightGrp.push(new GameLight(lLight));
    }
  }

  public function createEnemy(enemy:Entity_Enemy) {
    var enemyType = enemy.f_EnemyType;
    switch (enemyType) {
      case Ziggle:
        var enemy = new Ziggle(enemy);
        enemyGrp.push(enemy);
      case Sslug:
        var enemy = new Sslug(enemy);
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
    var tileGroup = data.l_Background.render();
    data.l_Background2.render(tileGroup);
    data.l_AutoTiles.render(tileGroup);

    /**
     * Rendering of the decoration tiles within the scene.
     */
    data.l_Decoration.render(tileGroup);

    data.l_Decoration2.render(tileGroup);

    root.addChild(tileGroup);
    // Add mask over scene
    // mask = new h2d.Bitmap(h2d.Tile.fromColor(0x0, 1, 1, 1), root);
    // mask.alpha = 0.6;
    // var g = new h2d.Graphics(root);
    // g.beginFill(0xffffff, 1);
    // g.drawCircle(hero.cx, hero.cy + 30, h() / 3);
    // g.endFill();
    // g.blendMode = Add;
    // g.alpha = 0.5;

    // g.blendMode = Multiply;
    // g.blendMode = Erase;
    // mask.blendMode = ;
    dn.Process.resizeAll();
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
      && collectible.cy == y && collectible.isAlive());
  }

  public function collidedCollectible(x:Int, y:Int) {
    return collectibleGrp.filter((collectible) -> return collectible.cx == x
      && collectible.cy == y && collectible.isAlive())
      .first();
  }

  /**
   * Return true when the grid coordinate of another element
   * overlaps with the grid coordinate of a collectible.
   * @param x 
   * @param y 
   */
  public function hasAnyEnemyCollision(x:Int, y:Int) {
    return enemyGrp.exists((enemy) -> return enemy.cx == x && enemy.cy == y
      && enemy.isAlive());
  }

  public function enemyCollided(x:Int, y:Int) {
    return enemyGrp.filter((enemy) -> return enemy.cx == x && enemy.cy == y
      && enemy.isAlive())
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
   * Returns an event if you are within the radius of that event. 
   * @param x 
   * @param y 
   */
  public function eventCollided(x:Int, y:Int) {
    return eventGrp.filter((event) -> {
      return M.dist(event.cx, event.cy, x, y) < event.eventRadius;
    }).first();
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

  public function collidedDoor(x:Int, y:Int):en.hazard.Door {
    return cast hazardGrp.filter((hazard) -> return hazard.cx == x
      && (hazard.cy == y || hazard.cy + 1 == y)
      && Std.isOfType(hazard, en.hazard.Door))
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
      Game.ME.pause();
      new Pause();
    }

    // Process Game over process
    // TODO: Test this functionality next
    if (hero != null && !hero.isAlive()) {
      Game.ME.pause();
      new GameOver();
    }
  }

  override function postUpdate() {
    super.postUpdate();

    if (invalidated) {
      invalidated = false;
      render();
    }
  }

  override function onResize() {
    super.onResize();
    if (mask != null) {
      mask.scaleX = M.ceil(w());
      mask.scaleY = M.ceil(h());
    }
  }

  override function onDispose() {
    // Dispose of all entities at the end of the level
    // Anything not in the root will not be disposed
    for (enemy in enemyGrp) {
      enemy.dispose();
    }

    for (event in eventGrp) {
      event.dispose();
    }

    for (hazard in hazardGrp) {
      hazard.dispose();
    }

    for (checkpoint in checkpointGrp) {
      checkpoint.dispose();
    }

    for (collectible in collectibleGrp) {
      collectible.dispose();
    }

    for (light in lightGrp) {
      light.dispose();
    }

    hero.dispose();

    super.onDispose();
    bgm.stop();
  }
}