package en;

import dn.heaps.filter.PixelOutline;
import en.collectibles.WingBeat;
import en.hazard.Exit;
import dn.heaps.Controller.ControllerAccess;

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
	public var health:Int = 3;

	public static inline var DASH_FORCE:Float = 1.2;
	public static inline var DASH_TIME:Float = 1.5;
	public static inline var MAX_SPEED:Float = 0.1;
	public static inline var HEALTH_CAP:Int = 3;

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
		if (ct.leftDown() || ct.isKeyboardDown(K.LEFT)) {
			dx = M.fclamp((dx - (0.1 * tmod)), -MAX_SPEED, MAX_SPEED);
			dashDir.x = -1;
		}

		if (ct.rightDown() || ct.isKeyboardDown(K.RIGHT)) {
			dx = M.fclamp((dx + (0.1 * tmod)), -MAX_SPEED, MAX_SPEED);
			dashDir.x = 1;
		}

		if (ct.upPressed() || ct.isAnyKeyPressed([K.UP, K.W]) && (canJump || (canDoubleJump && doubleJumpUnlock))) {
			jump();
		}

		if (ct.bPressed() || ct.isAnyKeyPressed([K.Z, K.J]) && dashUnlock && dashCount > 0) {
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
		super.update();
	}

	public function jump() {
		jumpCount++;
		dy = 0;
		dy = (-0.7 * tmod);
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
		health = M.iclamp(health - value, 0, M.T_INT32_MAX);
		// Screen Shake
		Game.ME.camera.shakeS(0.5, 0.5);
		hxd.Res.sound.hit_sfx.play();
		if (health == 0) {
			// Destroy / Kill the Object
			die();
		}
	}

	public function die() {
		this.destroy();
	}

	override function fixedUpdate() {
		if (!isOnFloor) {
			applyPhysics();
		}
		handleCollisions();
		super.fixedUpdate();
	}

	public function handleCollisions() {
		entityCollisions();
		levelCollisions();
	}

	public function entityCollisions() {
		collectibleCollisions();
		hazardCollisions();
		checkpointCollisions();
	}

	public function checkpointCollisions() {
		if (level.hasAnyCheckpointCollision(cx, cy)) {
			var checkpoint = level.checkpointCollided(cx, cy);
			// var collectibleType = Type.getClass(collectible);
			// Set the current active checkpoint
			level.currentCheckpoint = checkpoint;
			#if debug
			trace('Touched checkpoint');
			#end
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
				// Do nothing

				case _:
					// Do nothing
			}
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
				case _:
					// do nothing
			}
			collectible.destroy();
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
		if (level.hasAnyCollision(cx, cy - 1) || level.hasAnyCollision(cx + M.round(xr), cy - 1)) {
			// Set some squash for when you touch the ceiling
			setSquashY(0.8);
			dy = M.fabs(dy);
		}

		// Down

		if (level.hasAnyCollision(cx, cy + 1) && yr >= 0.5 || level.hasAnyCollision(cx + M.round(xr), cy + 1) && yr >= 0.5) {
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
