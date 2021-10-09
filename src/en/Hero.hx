package en;

import dn.heaps.assets.Aseprite;
import dn.data.SavedData;
import en.hazard.Door;
import en.hazard.MovingPlatform;
import dn.heaps.filter.PixelOutline;
import en.collectibles.WingBeat;
import en.hazard.Exit;
import dn.heaps.Controller.ControllerAccess;

/**
 * TODO: Add in dash time to prevent clamping dash when inputs
 * are entered.
 */
class Hero extends Entity {
  public var camera(get, never):Camera;

  #if macro
  var anims = Aseprite.getDict(hxd.Res.img.mc_first);
  #end

  inline function get_camera()
    return game.camera;

  var ct:ControllerAccess;

  public var isOnFloor:Bool;
  public var canJump:Bool;
  public var jumpCount:Int = 0;
  public var attackUnlock:Bool;
  public var isDashing(get, never):Bool;
  public var keys:Int = 0;
  public var health:Int = 3;
  public var plat:MovingPlatform;
  public var isInvincible:Bool;

  public static inline var DASH_FORCE:Float = 1.2;
  public static inline var DASH_TIME:Float = 0.25;
  public static inline var MAX_SPEED:Float = 0.125;
  public static var HEALTH_CAP:Int = 3;
  public static inline var INVINCIBLE_TIME:Float = 1.5;
  public static inline var KNOCKBACK_FORCE:Float = 0.5;
  public static inline var ATTACK_TIME:Float = 0.5;

  public var indicator:h2d.Graphics;

  /**
   * Knockback cool down period before setting direction back
   */
  public static inline var KB_CD:Float = 0.3;

  public var dashDir:Vec2 = new Vec2(0, 0);

  inline function get_isDashing() {
    return dashTimer > 0;
  }

  public var dashCount:Int = 0;
  public var dashTimer:Float;

  public var dashUnlock:Bool;
  public var doubleJumpUnlock:Bool;
  public var canDoubleJump(get, never):Bool;

  inline function get_canDoubleJump() {
    return jumpCount < 2;
  }

  public var canGlide:Bool;
  public var canFly:Bool;

  public function new(x:Int, y:Int) {
    super(x, y);
    // Debug drags entity location, therefore in the final build we'd shift sprite position up
    // To offset the position in the game to make it more natural
    // Assuming platformer 0.5 would be the halfway point for the feet so offset by half sprite size
    spr.filter = new PixelOutline(0xff70af, 1);
    // var g = new h2d.Graphics(spr);
    // g.beginFill(0xffffff);
    // g.drawRect(0, 0, 16, 16);
    // g.y -= Const.GRID * 0.5;

    isOnFloor = false;
    canJump = false;
    #if debug
    doubleJumpUnlock = true;
    dashUnlock = true;
    #else
    doubleJumpUnlock = false;
    dashUnlock = false;
    #end
    // Add in pixel outline shader
    setupIndicator();
    setupAnimations();
    ct = Main.ME.controller.createAccess('hero');
    camera.trackEntity(this, true);
    loadPlayerInfo();
    Game.ME.invalidateHud();
  }

  public function setupIndicator() {
    var tile = hxd.Res.img.indicator.toTile();
    indicator = new h2d.Graphics(spr);
    var scale = 2;
    indicator.beginTileFill(0, 0, scale, scale, tile);
    indicator.drawRect(0, 0, tile.width * scale, tile.height * scale);
    indicator.endFill();
    indicator.y -= tile.height * (scale + 1.2);
    indicator.x -= (tile.width * 0.5);
    indicator.visible = false;
  }

  public function setupAnimations() {
    var hero = Aseprite.convertToSLib(Const.FPS,
      hxd.Res.img.mc_first.toAseprite());
    spr.set(hero);
    spr.anim.registerStateAnim('hurt', 12, 1, () -> cd.has('knockback'));
    spr.anim.registerStateAnim('attack', 2, 1, () -> cd.has('attacking'));
    spr.anim.registerStateAnim('jump', 3, 1, () -> {
      return !isOnFloor;
    });
    spr.anim.registerStateAnim('run', 1, 1, () -> {
      return dx != 0 && plat == null;
    });
    spr.anim.registerStateAnim('idle', 0);
    spr.setCenterRatio();
  }

  override function dispose() {
    super.dispose();
    ct.dispose();
  }

  override function update() {
    updateInvincible();
    updateControls();
    eventCollisions();
    super.update();
  }

  public function updateInvincible() {
    // Flash Character every couple frames
    if (isInvincible) {
      // spr.alpha = 1;
      if (!cd.has('invincible')) {
        cd.setF('invincible', 5, () -> {
          spr.alpha = 0;
        });
      } else {
        spr.alpha = 1;
      }
    } else {
      spr.alpha = 1;
    }
  }

  public function updateControls() {
    if (ct.leftDown() || ct.isKeyboardDown(K.LEFT)) {
      if (!isDashing) {
        dx = M.fclamp((dx - (0.1 * tmod)), -MAX_SPEED, MAX_SPEED);
      }

      dashDir.x = -1;
    }

    if (ct.rightDown() || ct.isKeyboardDown(K.RIGHT)) {
      if (!isDashing) {
        dx = M.fclamp((dx + (0.1 * tmod)), -MAX_SPEED, MAX_SPEED);
      }
      dashDir.x = 1;
    }

    if (ct.upPressed() || ct.isAnyKeyPressed([K.UP, K.W])
      && (canJump || (canDoubleJump && doubleJumpUnlock))) {
      jump();
    }

    // Attack
    // TODO:Use different button as W and Jump also map to A
    if (ct.isAnyKeyPressed([K.K, K.X])) {
      attack();
    }

    if (ct.bPressed()
      || ct.isAnyKeyPressed([K.Z, K.J])
      && dashUnlock
      && dashCount > 0) {
      if (ct.upDown() || ct.isAnyKeyDown([K.UP, K.W])) {
        dashDir.y = -1;
      }
      if (ct.downDown() || ct.isAnyKeyDown([K.DOWN, K.S])) {
        dashDir.y = 1;
      }
      dash();
    }
    dashDir.x = 0;
    dashDir.y = 0;
    if (!cd.has('knockback')) {
      dir = M.sign(dx);
    }
  }

  /**
   * Registers a collision in the next cell over based on enemies in the level
   */
  public function attack() {
    // Based off player direction and what not
    // aka DashDir
    if (!cd.has('attacking')) {
      cd.setS('attacking', ATTACK_TIME);
      hxd.Res.sound.attack_hit.play();
      if (level.hasAnyEnemyCollision(cx + M.round(dir), cy)) {
        var enemy = level.enemyCollided(cx + M.round(dir), cy);
        // Take enemy health
        enemy.takeDamage();
        hxd.Res.sound.attack_hit_enemy.play();
        // Add attacking sound
      }
    }
  }

  public function jump() {
    detachPlat();
    isOnFloor = false;
    jumpCount++;
    dy = 0;
    dy = (-0.7 * tmod);
    setSquashX(0.6);
    hxd.Res.sound.jump_wav.play();
  }

  public function bounce() {
    // Reset jump count + pause
    jumpCount = 0;
    isOnFloor = false;
    dy = 0;
    dy = (-1.4 * tmod);
    setSquashX(0.4);
    hxd.Res.sound.bounce_pad_wav.play();
  }

  /**
   * Dashing mechanic allowing the player to dash around the screen
   */
  public function dash() {
    dashTimer = DASH_TIME;

    if (dashDir.x == 0 && dashDir.y == 0) {
      dashDir.x = 1;
    }

    // trace('${dashDir.x}, ${dashDir.y}');
    dx = ((dashDir.x * DASH_FORCE)) * tmod;
    dy = 0;
    dy = ((dashDir.y * DASH_FORCE)) * tmod;
    hxd.Res.sound.dash_sound_one.play();
    setSquashX(0.8);
    dashCount = 0;
    cd.setS('dashing', DASH_TIME, () -> {
      dashTimer = 0;
    });
  }

  public function takeDamage(value:Int) {
    if (!isInvincible && !isDashing) {
      health = M.iclamp(health - value, 0, M.T_INT32_MAX);
      // Screen Shake
      Game.ME.camera.shakeS(0.5, 0.5);
      Game.ME.invalidateHud();
      hxd.Res.sound.hit_sfx.play();
      if (health == 0) {
        // Destroy / Kill the Object
        die();
      }
      isInvincible = true;
      cd.setS('invincibleTime', INVINCIBLE_TIME, () -> {
        isInvincible = false;
      });
      knockBack();
    }
  }

  public function knockBack() {
    // Apply force in the opposite direction of the current direction
    dx = 0;
    dy = 0;
    dx += (-1 * dir * KNOCKBACK_FORCE);
    dy = (-1 * (KNOCKBACK_FORCE));
    cd.setS('knockback', KB_CD);
  }

  public function die() {
    this.destroy();
  }

  override function fixedUpdate() {
    handleCollisions();
    super.fixedUpdate();
    if (plat == null) {
      applyPhysics();
    }
  }

  public function handleCollisions() {
    entityCollisions();
  }

  public function entityCollisions() {
    collectibleCollisions();
    hazardCollisions();
    checkpointCollisions();
    enemyCollisions();
  }

  public function eventCollisions() {
    var event = level.eventCollided(cx, cy);
    if (event != null && !Game.ME.eventExists(event.eventName)) {
      // If button pressed
      indicator.visible = true;
      if (ct.bPressed() || ct.isAnyKeyPressed([K.Z, K.K, K.X])) {
        // Run Event
        var msgWin = Game.ME.msgWin;
        if (msgWin != null && !msgWin.win.visible) {
          // Run Event
          var depotEvent = depot.DepotData.Dialogue.lines.getByFn((line) ->
            line.name == event.eventName);
          var allText = depotEvent.text.map((text) -> text.str);
          // Send Event to the save data before finishing
          Game.ME.saveEvent(event.eventName);
          msgWin.show();
          msgWin.sendMsgs(allText);
          Game.ME.pause();
        }
      }
    } else {
      indicator.visible = false;
    }
  }

  /**
   * Sets the current checkpoint once you touch
   */
  public function checkpointCollisions() {
    if (level.hasAnyCheckpointCollision(cx, cy)) {
      var checkpoint = level.checkpointCollided(cx, cy);
      // var collectibleType = Type.getClass(collectible);
      // Set the current active checkpoint
      if (level.currentCheckpoint == null
        || level.currentCheckpoint.id != checkpoint.id) {
        level.currentCheckpoint = checkpoint;
        hxd.Res.sound.checkpoint_two.play();
        // Save Checkpoint information
        SavedData.save(CHK_COORDS, {x: checkpoint.cx, y: checkpoint.cy});
        #if debug
        trace('Touched checkpoint');
        #end
      }
    }
  }

  public function hazardCollisions() {
    if (level.hasAnyHazardCollision(cx, cy)) {
      var hazard = level.collidedHazard(cx, cy);
      var hazardType = Type.getClass(hazard);
      switch (hazardType) {
        case en.hazard.Exit:
          // Start new level
          var exit:Exit = cast hazard;
          game.nextLevel(exit.lvlId, Std.int(exit.startPoint.x),
            Std.int(exit.startPoint.y));
        case en.hazard.BouncePad:
          // Apply speed in the y axis
          var bouncePad:en.hazard.BouncePad = cast hazard;
          bouncePad.bounce();
          bounce();
        case en.hazard.Lantern:
          // Reset dash on touch
          dashReset();
        case en.hazard.Spike:
          // Take damage from spike
          takeDamage(1);
        case _:
          // Do nothing
      }
    }
    doorCollisions();
    movingPlatformCollision();
  }

  /**
   * Resets the dash and pops the player up slightly
   */
  public function dashReset() {
    dashCount = 1;
    dy += -(0.35 * tmod);
  }

  public function doorCollisions() {
    if (level.collidedDoor(cx - 1, cy) != null
      || level.collidedDoor(cx + 1, cy) != null) {
      var lftHazard = level.collidedHazard(cx - 1, cy);

      var rightHazard = level.collidedHazard(cx + 1, cy);

      if (lftHazard != null && Std.isOfType(lftHazard, en.hazard.Door)) {
        var door:Door = cast lftHazard;
        if (!door.unlocked && this.keys > 0) {
          door.unlocked = true;
          this.keys -= 1;
          Game.ME.invalidateHud();
        }
        if (door.unlocked) {
          // Can pass through
        } else {
          xr = 0.5;
          dx = 0;
          // Reject and move backwards
        }
      }
      if (rightHazard != null && Std.isOfType(rightHazard, en.hazard.Door)) {
        var door:Door = cast rightHazard;
        if (!door.unlocked && this.keys > 0) {
          door.unlocked = true;
          this.keys -= 1;
        }
        if (door.unlocked) {
          // Can pass through
        } else {
          xr = 0.1;
          dx = 0;
          // Reject and move backwards
        }
      }
    }
  }

  public function enemyCollisions() {
    if (level.hasAnyEnemyCollision(cx, cy)) {
      // Take damage when the player touches an enemy in game
      takeDamage(1);
    }
  }

  public function collectibleCollisions() {
    if (level.hasAnyCollectibleCollision(cx, cy)) {
      var collectible = level.collidedCollectible(cx, cy);
      var collectibleType = Type.getClass(collectible);
      switch (collectibleType) {
        case en.collectibles.Heart:
          // Restore player health by 1
          health = M.iclamp(health + 1, 0, HEALTH_CAP);
          Game.ME.invalidateHud();
        case en.collectibles.HealthUp:
          // Increases Health and completely restores the player
          // health
          HEALTH_CAP++;
          health = M.iclamp(HEALTH_CAP, 0, HEALTH_CAP);
          Game.ME.invalidateHud();
        case en.collectibles.WingBeat:
          attackUnlock = true;
          savePlayerInfo();
        case en.collectibles.Key:
          keys += 1;
          Game.ME.invalidateHud();
          savePlayerInfo();
        case en.collectibles.SecondWind:
          // Unlocks the double jump
          doubleJumpUnlock = true;
          savePlayerInfo();
        case en.collectibles.ViridescentWings:
          dashUnlock = true;
          savePlayerInfo();
        case _:
          // do nothing
      }
      hxd.Res.sound.collect_collectible.play();
      collectible.destroy();
    }
  }

  /**
   * Saves the player information to the game data.
   * So that when the player is moving from scene to scene,
   * we can provide the current state of the player 
   * at any given point in time.
   */
  public function savePlayerInfo() {
    // SavedData.save(PLAYER_INFO, {
    Game.ME.playerState = {
      unlockedDash: dashUnlock,
      unlockedDoubleJump: doubleJumpUnlock,
      levelId: Game.ME.level.uniqId,
      health: health,
      keys: keys
    }
    // });
  }

  public function loadPlayerInfo() {
    // if (SavedData.exists(PLAYER_INFO)) {
    //   var data = SavedData.load(PLAYER_INFO, {
    //     unlockedDash: Bool,
    //     unlockedDoubleJump: Bool,
    //     levelId: Int,
    //     health: Int,
    //     keys: Int
    //   });
    var data = Game.ME.playerState;
    // Set the player flags
    if (data != null) {
      dashUnlock = data.unlockedDash;
      doubleJumpUnlock = data.unlockedDoubleJump;
      health = data.health;
    }

    // }
  }

  public function movingPlatformCollision() {
    // Left
    if (level.hasAnyMPlatCollision(cx - 1, cy) && xr <= 0.3) {
      xr = 0.3;
      dx = 0;
      // dx = M.fabs(dx);
    }

    // Right
    if (level.hasAnyMPlatCollision(cx + 1, cy) && xr >= 0.1) {
      // push back to previous cell
      xr = 0.1;
      dx = 0;
      // dx = (-1 * M.fabs(dx));
    }

    // Up
    if (level.hasAnyMPlatCollision(cx, cy - 1)
      || level.hasAnyMPlatCollision(cx + M.round(xr), cy - 1)) {
      // Set some squash for when you touch the ceiling

      // setSquashY(0.8);
      dy = M.fabs(dy);
    }

    // Down
    if (level.hasAnyMPlatCollision(cx, cy + 1)
      && yr >= 0. || level.hasAnyMPlatCollision(cx + M.round(xr), cy + 1)
        && yr >= 0.5) {
      // Handle squash and stretch for entities in the game

      var mPlat:MovingPlatform = cast level.collidedMPlat(cx, cy + 1);
      isOnFloor = true;
      canJump = true;

      dashCount = 1;
      jumpCount = 0;

      if (mPlat != null) {
        mPlat.player = this;
        this.plat = mPlat;
      } else {
        detachPlat();
      }
    }
  }

  public function detachPlat() {
    if (plat != null) {
      plat.player = null;
      plat.fixedUpdate();
      plat = null;
    }
  }

  override function onPreStepX() {
    super.onPreStepX();
    // Left
    if (level.hasAnyCollision(cx - 1, cy) && xr <= 0.3) {
      xr = 0.3;
      dx = 0;
      // dx = M.fabs(dx);
    }

    // Right
    if (level.hasAnyCollision(cx + 1, cy) && xr >= 0.1) {
      // push back to previous cell
      xr = 0.1;
      dx = 0;
      // dx = (-1 * M.fabs(dx));
    }
  }

  public function lrLevelCollisions() {}

  override function onPreStepY() {
    super.onPreStepY();
    udLevelCollisions();
  }

  public function udLevelCollisions() {
    // Up
    if (level.hasAnyCollision(cx, cy - 1)
      || level.hasAnyCollision(cx + M.round(xr), cy - 1)) {
      // Set some squash for when you touch the ceiling
      setSquashY(0.8);
      dy = M.fabs(dy);
    }

    // Down

    if (level.hasAnyCollision(cx, cy + 1)
      && yr >= 0.5
      || level.hasAnyCollision(cx + M.round(xr), cy + 1)
      && yr >= 0.5) {
      // Handle squash and stretch for entities in the game
      if (level.hasAnyCollision(cx, cy + M.round(yr + 0.3)) && !isOnFloor) {
        setSquashY(0.6);
      }

      isOnFloor = true;
      canJump = true;

      dashCount = 1;
      jumpCount = 0;
      // dy = 0;

      // dy = (-1 * M.fabs(dy));
      // We should be moved up by the moving platform by taking in the
      // mPlatform velocity
      dy = 0;
      // If cy is still in object (yr)
      yr = 0.5;
    } else {
      canJump = false;
      isOnFloor = false;
    }
  }

  public function applyPhysics() {
    dy += 0.05;
  }
}