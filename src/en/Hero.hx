package en;

import dn.heaps.Controller.ControllerAccess;

class Hero extends Entity {
	var ct:ControllerAccess;

	public function new(x:Int, y:Int) {
		super(x, y);
		var g = new h2d.Graphics(spr);
		g.beginFill(0xffffff);
		g.drawRect(0, 0, 16, 16);

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
}
