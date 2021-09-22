package en.enemy;

class Ziggle extends Enemy {
	public var pathPoints:Array<tools.Vec2>;
	public var looping:Bool;
	public var pointIndex = 0;
	public var speed:Float;

	/**
	 * Wait time between destinations per point.
	 */
	public var waitTime:Float;

	public function new(enemy:Entity_Enemy) {
		super(enemy.cx, enemy.cy);
		looping = true;
		speed = 0.05;
		pathPoints = enemy.f_Path.map((pathPoint) -> {
			return new Vec2(pathPoint.cx, pathPoint.cy);
		});
		// setSprite();
	}

	public function setSprite() {
		var g = new h2d.Graphics(spr);
		g.beginFill(0x101010, 1);
		g.drawRect(0, 0, 16, 16);
		g.endFill();
	}

	override public function update() {
		super.update();
		followPath();
	}

	public function followPath() {
		var point = pathPoints[pointIndex % pathPoints.length];
		if (point.x != cx || point.y != cy) {
			// Follow the path by checking the distance from point
			var dest = new Vec2(point.x - cx, point.y - cy).normalize();
			dx = dest.x * speed;

			dy = dest.y * speed;
		} else {
			pointIndex++;
		}
	}
}
