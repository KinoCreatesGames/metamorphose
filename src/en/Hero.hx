package en;

import dn.heaps.Controller.ControllerAccess;

class Hero extends Entity {
	var ct:ControllerAccess;

	public var isOnFloor:Bool;

	public function new(x:Int, y:Int) {
		super(x, y);
		var g = new h2d.Graphics(spr);
		g.beginFill(0xffffff);
		g.drawRect(0, 0, 16, 16);
		isOnFloor = false;

		ct = Main.ME.controller.createAccess('hero');
	}

	override function dispose() {
		super.dispose();
		ct.dispose();
	}

	override function update() {
		super.update();

		if (ct.leftDown() || ct.isKeyboardDown(K.LEFT)) {
			dx -= 0.1 * tmod;
		}

		if (ct.rightDown() || ct.isKeyboardDown(K.RIGHT)) {
			dx += 0.1 * tmod;
		}
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if (!isOnFloor) {
			applyPhysics();
		}
		handleCollisions();
	}

	public function handleCollisions() {
		// Up

		// Down
		if (level.hasAnyCollsion(cx, cy + 1)) {
			// Stop vector movement
			// Slowly move out of the coordinate
			isOnFloor = true;
			// dy = 0;
			dy *= M.fabs(dy);
		} else {
			isOnFloor = false;
		}
		// Left

		// Right
	}

	public function applyPhysics() {
		dy += 0.05;
	}
}
