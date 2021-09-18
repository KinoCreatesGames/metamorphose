package en;

import dn.heaps.Controller.ControllerAccess;

class Hero extends Entity {
	var ct:ControllerAccess;

	public var isOnFloor:Bool;
	public var canJump:Bool;
	public var jumpCount:Int = 0;

	public var canDoubleJump(get, never):Bool;

	inline function get_canDoubleJump() {
		return jumpCount < 2;
	}

	public var canGlide:Bool;
	public var canFly:Bool;

	public function new(x:Int, y:Int) {
		super(x, y);
		var g = new h2d.Graphics(spr);
		g.beginFill(0xffffff);
		g.drawRect(0, 0, 16, 16);
		isOnFloor = false;
		canJump = false;

		ct = Main.ME.controller.createAccess('hero');
	}

	override function dispose() {
		super.dispose();
		ct.dispose();
	}

	override function update() {
		if (ct.upPressed() || ct.isAnyKeyPressed([K.UP, K.W]) && canJump) {
			jump();
		}
		if (ct.leftDown() || ct.isKeyboardDown(K.LEFT)) {
			dx = -(0.1 * tmod);
		}

		if (ct.rightDown() || ct.isKeyboardDown(K.RIGHT)) {
			dx = 0.1 * tmod;
		}
		super.update();
	}

	public function jump() {
		jumpCount++;
		dy = (-0.9 * tmod);
	}

	override function fixedUpdate() {
		if (!isOnFloor) {
			applyPhysics();
		}
		handleCollisions();
		super.fixedUpdate();
	}

	public function handleCollisions() {
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
			dy = M.fabs(dy);
		}

		// Down

		if (level.hasAnyCollision(cx, cy + 1) && yr >= 0.1 || level.hasAnyCollision(cx + M.round(xr), cy + 1)) {
			// Stop vector movement
			// Slowly move out of the coordinate
			isOnFloor = true;
			canJump = true;
			jumpCount = 0;
			// dy = 0;

			// dy = (-1 * M.fabs(dy));
			dy = 0;
			// If cy is still in object (yr)
			yr = 0.1;
		} else {
			canJump = false;
			isOnFloor = false;
		}
	}

	public function applyPhysics() {
		dy += 0.1;
	}
}
