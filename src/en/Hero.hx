package en;

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
  public static inline var DASH_TIME:Float = 1.5;
  public static inline var MAX_SPEED:Float = 0.1;
  public static inline var HEALTH_CAP:Int = 3;
  public static inline var INVINCIBLE_TIME:Float = 1.5;

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
    var g = new h2d.Graphics(spr);
    g.beginFill(0xffffff);
    g.drawRect(0, 0, 16, 16);
    g.y -= Const.GRID * 0.5;

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

    ct = Main.ME.controller.createAccess('hero');
    camera.trackEntity(this, true);
  }

  override function dispose() {
    super.dispose();
    ct.dispose();
  }

  override function update() {
    updateInvincible();
    updateControls();
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
    if (ct.aPressed() || ct.isAnyKeyPressed([K.K, K.X])) {
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
  }

  /**
   * Registers a collision in the next cell over based on enemies in the level
   */
  public function attack() {
    // Based off player direction and what not
    // aka DashDir
    if (level.hasAnyEnemyCollision(cx + M.round(dashDir.x), cy)) {
      var enemy = level.enemyCollided(cx + M.round(dashDir.x), cy);
      // Take enemy health
      enemy.takeDamage();
    }
  }

  public function jump() {
    detachPlat();
    isOnFloor = false;
    jumpCount++;
    dy = 0;
    dy = (-0.7 * tmod);
    hxd.Res.sound.jump_wav.play();
  }

  public function bounce() {
    // Reset jump count + pause
    jumpCount = 0;
    isOnFloor = false;
    dy = 0;
    dy = (-1.2 * tmod);
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

    dashCount = 0;
  }

  public function takeDamage(value:Int) {
    if (!isInvincible) {
      health = M.iclamp(health - value, 0, M.T_INT32_MAX);
      // Screen Shake
      Game.ME.camera.shakeS(0.5, 0.5);
      hxd.Res.sound.hit_sfx.play();
      if (health == 0) {
        // Destroy / Kill the Object
        die();
      }
      isInvincible = true;
      cd.setS('invincibleTime', INVINCIBLE_TIME, () -> {
        isInvincible = false;
      });
    }
  }

  public function die() {
    this.destroy();
  }

  override function fixedUpdate() {
    handleCollisions();
    super.fixedUpdate();
  }

  public function handleCollisions() {
    levelCollisions();
    entityCollisions();
  }

  public function entityCollisions() {
    collectibleCollisions();
    hazardCollisions();
    checkpointCollisions();
    enemyCollisions();
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
          game.nextLevel(exit.lvlId);
        case en.hazard.BouncePad:
          // Apply speed in the y axis
          bounce();
        case en.hazard.Lantern:
          // Reset dash on touch
          dashReset();

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
    if (level.hasAnyHazardCollision(cx - 1, cy)
      || level.hasAnyHazardCollision(cx + 1, cy)) {
      var lftHazard = level.collidedHazard(cx - 1, cy);

      var rightHazard = level.collidedHazard(cx + 1, cy);

      if (lftHazard != null && Std.isOfType(lftHazard, en.hazard.Door)) {
        var door:Door = cast lftHazard;
        if (door.unlocked) {
          // Can pass through
        } else {
          xr = 0.3;
          dx = 0;
          // Reject and move backwards
        }
      }
      if (rightHazard != null && Std.isOfType(rightHazard, en.hazard.Door)) {
        var door:Door = cast rightHazard;
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
        case en.collectibles.WingBeat:
          attackUnlock = true;

        case en.collectibles.ViridescentWings:
          dashUnlock = true;
        case en.collectibles.Key:
          keys += 1;

        case _:
          // do nothing
      }
      collectible.destroy();
    }
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

  public function levelCollisions() {
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
      if (plat == null) {
        applyPhysics();
      }
    }
  }

  public function applyPhysics() {
    dy += 0.05;
  }
}